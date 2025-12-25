import 'package:supabase_flutter/supabase_flutter.dart';

final SupabaseClient _supabase = Supabase.instance.client;

// Generic sign up with basic profile data
Future<AuthResponse> signUpBasic({
  required String email,
  required String password,
  required String username,
  required String phone,
}) async {
  final response = await _supabase.auth.signUp(
    email: email,
    password: password,
    data: {
      'full_name': username,
      'phone': phone,
    },
  );
  return response;
}

Future<AuthResponse> signIn({
  required String email,
  required String password,
}) async {
  final response = await _supabase.auth.signInWithPassword(
    email: email,
    password: password,
  );
  return response;
}

Future<void> signOut() async {
  await _supabase.auth.signOut();
}

Future<void> resetPassword({required String email}) async {
  await _supabase.auth.resetPasswordForEmail(email);
}

String _generateFamilyId() {
  final ts = DateTime.now().millisecondsSinceEpoch;
  return 'MED-${ts.toRadixString(36).toUpperCase()}';
}

// Registers a patient and returns the generated family_id
Future<String> signUpPatient({
  required String email,
  required String password,
  required String name,
  String? age,
  required String phone,
}) async {
  final String familyId = _generateFamilyId();

  final response = await _supabase.auth.signUp(
    email: email,
    password: password,
    data: {'full_name': name, 'user_role': 'patient'},
  );

  if (response.user == null) {
    throw Exception('Sign up failed');
  }

  final userId = response.user!.id;

  // Create profile master record
  await _supabase.from('profiles').insert({
    'id': userId,
    'full_name': name,
    'user_role': 'patient',
  });

  // Insert patient details with generated family_id
  await _supabase.from('patients').insert({
    'id': userId,
    'family_id': familyId,
    if (age != null && age.trim().isNotEmpty) 'age': int.tryParse(age.trim()),
    'phone': phone,
  });

  return familyId;
}

// Sign up specifically for Caregivers
Future<void> signUpCaregiver({
  required String email,
  required String password,
  required String name,
  required String phone,
  required String familyIdFromParent, // Inputted by caregiver
}) async {
  // 1. First, check if the Family ID actually exists
  final patientData = await _supabase
      .from('patients')
      .select('id')
      .eq('family_id', familyIdFromParent)
      .maybeSingle();

  if (patientData == null) {
    throw Exception("Family ID not found. Please check with your parent.");
  }

  // 2. Sign up user
  final response = await _supabase.auth.signUp(
    email: email,
    password: password,
    data: {'full_name': name, 'user_role': 'caregiver'},
  );

  if (response.user != null) {
    final userId = response.user!.id;

    // 2.1 Create profile master record
    await _supabase.from('profiles').insert({
      'id': userId,
      'full_name': name,
      'user_role': 'caregiver',
    });

    // 3. Insert into caregivers table
    await _supabase.from('caregivers').insert({
      'id': userId,
      'phone': phone,
    });

    // 4. Create the link between them
    await _supabase.from('patient_caregiver_link').insert({
      'patient_id': patientData['id'],
      'caregiver_id': userId,
    });
  }
}
