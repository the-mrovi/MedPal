// Sign up specifically for Patients
import 'package:supabase_flutter/supabase_flutter.dart';

final SupabaseClient _supabase = Supabase.instance.client;

Future<AuthResponse> signUpPatient({
  required String email,
  required String password,
  required String name,
  required String age,
  required String phone,
}) async {
  // 1. Generate a random Family ID
  final String familyId =
      "MED-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}";

  // 2. Sign up with metadata for the trigger
  final response = await _supabase.auth.signUp(
    email: email,
    password: password,
    data: {'full_name': name, 'user_role': 'patient'},
  );

  // 3. Manually insert the patient-specific data
  if (response.user != null) {
    await _supabase.from('patients').insert({
      'id': response.user!.id,
      'family_id': familyId,
      'age': int.parse(age),
      'phone': phone,
    });
  }
  return response;
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
    // 3. Insert into caregivers table
    await _supabase.from('caregivers').insert({
      'id': response.user!.id,
      'phone': phone,
    });

    // 4. Create the link between them
    await _supabase.from('patient_caregiver_link').insert({
      'patient_id': patientData['id'],
      'caregiver_id': response.user!.id,
    });
  }
}
