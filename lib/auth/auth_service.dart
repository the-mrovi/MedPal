import 'package:supabase_flutter/supabase_flutter.dart';

final SupabaseClient _supabase = Supabase.instance.client;

// 1. Google Sign In
Future<void> signInWithGoogle() async {
  await _supabase.auth.signInWithOAuth(
    OAuthProvider.google,
    // Ensure this matches the redirect URL configured in your Supabase Dashboard
    redirectTo: 'io.supabase.medpal://login-callback/',
  );
}

// 2. Generic sign up: Saves name and phone to metadata
Future<AuthResponse> signUpBasic({
  required String email,
  required String password,
  required String username,
  required String phone,
}) async {
  return await _supabase.auth.signUp(
    email: email,
    password: password,
    data: {'full_name': username, 'phone': phone},
  );
}

// 3. Standard Sign In
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

// 4. Completes Patient Profile
Future<String> completePatientProfileForCurrentUser(String userId) async {
  final session = _supabase.auth.currentSession;

  if (session == null) {
    throw Exception(
      'Authentication session not found. Please verify your email or check Supabase settings.',
    );
  }

  final user = session.user;
  final meta = user.userMetadata ?? {};

  final name = (meta['full_name'] ?? 'User').toString();
  final phone = (meta['phone'] ?? '').toString();
  final familyId = _generateFamilyId();

  try {
    await _supabase.from('profiles').upsert({
      'id': userId,
      'full_name': name,
      'user_role': 'patient',
    });

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

// 5. Completes Caregiver Profile: Links to patient by family_id
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
      .eq('family_id', familyIdFromParent.trim().toUpperCase())
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

    await _supabase.from('caregivers').upsert({'id': user.id, 'phone': phone});

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

/// Returns the currently authenticated user's id, or null if not signed in.
Future<String?> getCurrentUserId() async {
  return _supabase.auth.currentUser?.id;
}
