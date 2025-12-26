import 'package:supabase_flutter/supabase_flutter.dart';

final SupabaseClient _supabase = Supabase.instance.client;

// 1. Generic sign up: Saves name and phone to metadata
Future<AuthResponse> signUpBasic({
  required String email,
  required String password,
  required String username,
  required String phone,
}) async {
  return await _supabase.auth.signUp(
    email: email,
    password: password,
    data: {
      'full_name': username, 
      'phone': phone,
    },
  );
}

// 2. Standard Sign In
Future<AuthResponse> signIn({
  required String email,
  required String password,
}) async {
  return await _supabase.auth.signInWithPassword(
    email: email,
    password: password,
  );
}

Future<void> signOut() async {
  await _supabase.auth.signOut();
}

// Helper to generate the unique ID for patients
String _generateFamilyId() {
  final ts = DateTime.now().millisecondsSinceEpoch;
  return 'MED-${ts.toRadixString(36).toUpperCase()}';
}

// 3. Completes Patient Profile
// FIXED: Checks for active session to prevent "Not Authenticated" errors
Future<String> completePatientProfileForCurrentUser(String userId) async {
  final session = _supabase.auth.currentSession;
  
  // If session is null, it means the user isn't logged in yet 
  // (Likely "Confirm Email" is enabled in Supabase settings)
  if (session == null) {
    throw Exception('Authentication session not found. Please verify your email or check Supabase settings.');
  }

  final user = session.user;
  final meta = user.userMetadata ?? {};
  
  final name = (meta['full_name'] ?? 'User').toString();
  final phone = (meta['phone'] ?? '').toString();
  final familyId = _generateFamilyId();

  try {
    // Update the master profile
    await _supabase.from('profiles').upsert({
      'id': userId,
      'full_name': name,
      'user_role': 'patient',
    });

    // Create the patient entry with the Family ID
    await _supabase.from('patients').upsert({
      'id': userId,
      'family_id': familyId,
      'phone': phone,
    });

    return familyId;
  } catch (e) {
    throw Exception('Database Error: $e');
  }
}

// 4. Completes Caregiver Profile: Links to patient by family_id
Future<String> completeCaregiverProfileForCurrentUser({
  required String familyIdFromParent,
}) async {
  final session = _supabase.auth.currentSession;
  if (session == null) throw Exception('Not authenticated. Please log in.');

  final user = session.user;
  final meta = user.userMetadata ?? {};
  final name = (meta['full_name'] ?? 'Caregiver').toString();
  final phone = (meta['phone'] ?? '').toString();

  final patientData = await _supabase
      .from('patients')
      .select('id')
      .eq('family_id', familyIdFromParent)
      .maybeSingle();

  if (patientData == null) {
    throw Exception('Family ID not found');
  }
  
  final patientId = patientData['id'] as String;

  try {
    await _supabase.from('profiles').upsert({
      'id': user.id,
      'full_name': name,
      'user_role': 'caregiver',
    });

    await _supabase.from('caregivers').upsert({
      'id': user.id,
      'phone': phone,
    });

    await _supabase.from('patient_caregiver_link').upsert({
      'patient_id': patientId,
      'caregiver_id': user.id,
    });

    final profile = await _supabase
        .from('profiles')
        .select('full_name')
        .eq('id', patientId)
        .maybeSingle();

    return (profile?['full_name'] ?? 'Patient') as String;
  } catch (e) {
    throw Exception('Failed to link caregiver: $e');
  }
}

// --- Helper queries used by UI ---

/// Returns the current user's role from the profiles table.
Future<String?> getCurrentUserRole() async {
  final user = _supabase.auth.currentUser;
  if (user == null) return null;

  final profile = await _supabase
      .from('profiles')
      .select('user_role')
      .eq('id', user.id)
      .maybeSingle();

  return profile?['user_role'] as String?;
}

/// If the current user is a patient, returns their family_id.
Future<String?> getMyFamilyIdIfPatient() async {
  final user = _supabase.auth.currentUser;
  if (user == null) return null;

  final patient = await _supabase
      .from('patients')
      .select('family_id')
      .eq('id', user.id)
      .maybeSingle();

  return patient?['family_id'] as String?;
}

/// For caregivers, returns the linked patient's name.
Future<String?> getLinkedPatientNameIfCaregiver() async {
  final user = _supabase.auth.currentUser;
  if (user == null) return null;

  final link = await _supabase
      .from('patient_caregiver_link')
      .select('patient_id')
      .eq('caregiver_id', user.id)
      .maybeSingle();

  final patientId = link?['patient_id'] as String?;
  if (patientId == null) return null;

  final profile = await _supabase
      .from('profiles')
      .select('full_name')
      .eq('id', patientId)
      .maybeSingle();

  return profile?['full_name'] as String?;
}