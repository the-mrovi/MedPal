import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  AuthService._privateConstructor();
  static final AuthService instance = AuthService._privateConstructor();

  final SupabaseClient _supabase = Supabase.instance.client;

  // 1. Unified Google Sign In
  Future<void> signInWithGoogle() async {
    String? redirectUrl;
    if (kIsWeb) {
      redirectUrl = Uri.base.origin;
    } else {
      redirectUrl = 'io.supabase.medpal://login-callback/';
    }

    await _supabase.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: redirectUrl,
      queryParams: {'prompt': 'select_account'},
    );
  }

  // 2. Email/Password Auth
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

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async => await _supabase.auth.signOut();

  // --- PASSWORD RESET (OTP FLOW) ---

  Future<void> sendPasswordResetOTP(String email) async {
    await _supabase.auth.resetPasswordForEmail(email);
  }

  Future<void> verifyOTPAndResetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    await _supabase.auth.verifyOTP(
      email: email,
      token: otp,
      type: OtpType.recovery,
    );
    await _supabase.auth.updateUser(UserAttributes(password: newPassword));
  }

  // 3. Updated Profile Completion (Fixed "User Not Found" error)

  Future<String> completePatientProfileForCurrentUser(String userId) async {
    // We remove the check for _supabase.auth.currentUser here.
    // We use the userId passed from the screen instead.

    final familyId =
        'MED-${DateTime.now().millisecondsSinceEpoch.toRadixString(36).toUpperCase()}';

    try {
      // Create profile record
      await _supabase.from('profiles').upsert({
        'id': userId,
        'user_role': 'patient',
      });

      // Create patient record
      await _supabase.from('patients').upsert({
        'id': userId,
        'family_id': familyId,
      });

      return familyId;
    } catch (e) {
      throw Exception('Database Error: $e');
    }
  }

  Future<String> completeCaregiverProfileForCurrentUser({
    required String userId, // Added userId parameter
    required String familyIdFromParent,
  }) async {
    // Find the patient linked to this family ID
    final patientData = await _supabase
        .from('patients')
        .select('id')
        .eq('family_id', familyIdFromParent.trim().toUpperCase())
        .maybeSingle();

    if (patientData == null) throw Exception('Family ID not found');

    try {
      // Create profile record
      await _supabase.from('profiles').upsert({
        'id': userId,
        'user_role': 'caregiver',
      });

      // Create caregiver record
      await _supabase.from('caregivers').upsert({'id': userId});

      // Link caregiver to patient
      await _supabase.from('patient_caregiver_link').upsert({
        'patient_id': patientData['id'],
        'caregiver_id': userId,
      });

      return "Linked Successfully";
    } catch (e) {
      throw Exception('Failed to link caregiver: $e');
    }
  }

  // --- Getters ---
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

  Future<String?> getCurrentUserId() async => _supabase.auth.currentUser?.id;

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
    if (link == null) return null;
    final profile = await _supabase
        .from('profiles')
        .select('full_name')
        .eq('id', link['patient_id'])
        .maybeSingle();
    return profile?['full_name'] as String?;
  }
}

// --- TOP-LEVEL HELPERS ---
Future<void> signInWithGoogle() => AuthService.instance.signInWithGoogle();
Future<AuthResponse> signUpBasic({
  required String email,
  required String password,
  required String username,
  required String phone,
}) => AuthService.instance.signUpBasic(
  email: email,
  password: password,
  username: username,
  phone: phone,
);
Future<AuthResponse> signIn({
  required String email,
  required String password,
}) => AuthService.instance.signIn(email: email, password: password);
Future<void> signOut() => AuthService.instance.signOut();

Future<void> sendPasswordResetOTP(String email) =>
    AuthService.instance.sendPasswordResetOTP(email);

Future<void> verifyOTPAndResetPassword({
  required String email,
  required String otp,
  required String newPassword,
}) => AuthService.instance.verifyOTPAndResetPassword(
  email: email,
  otp: otp,
  newPassword: newPassword,
);

Future<String> completePatientProfileForCurrentUser(String userId) =>
    AuthService.instance.completePatientProfileForCurrentUser(userId);

Future<String> completeCaregiverProfileForCurrentUser({
  required String userId, // Updated to pass userId
  required String familyIdFromParent,
}) => AuthService.instance.completeCaregiverProfileForCurrentUser(
  userId: userId,
  familyIdFromParent: familyIdFromParent,
);

Future<String?> getCurrentUserRole() =>
    AuthService.instance.getCurrentUserRole();
Future<String?> getCurrentUserId() => AuthService.instance.getCurrentUserId();
