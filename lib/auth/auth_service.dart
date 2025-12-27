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
      // DYNAMIC REDIRECT: Automatically gets your current local port
      redirectUrl = Uri.base.origin;
    } else {
      // MOBILE REDIRECT: Scheme for your Android phone
      redirectUrl = 'io.supabase.medpal://login-callback/';
    }

    await _supabase.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: redirectUrl,
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

  Future<void> sendPasswordResetEmail({
    required String email,
    String? redirectTo,
  }) async {
    await _supabase.auth.resetPasswordForEmail(email, redirectTo: redirectTo);
  }

  // Helper for unique IDs
  String _generateFamilyId() {
    final ts = DateTime.now().millisecondsSinceEpoch;
    return 'MED-${ts.toRadixString(36).toUpperCase()}';
  }

  // 3. Profile Completion
  Future<String> completePatientProfileForCurrentUser(String userId) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('No user found');

    final meta = user.userMetadata ?? {};
    final name = (meta['full_name'] ?? 'User').toString();
    final phone = (meta['phone'] ?? '').toString();
    final familyId = _generateFamilyId();

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
  }

  Future<String> completeCaregiverProfileForCurrentUser({
    required String familyIdFromParent,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('Not authenticated.');

    final meta = user.userMetadata ?? {};
    final name = (meta['full_name'] ?? 'Caregiver').toString();
    final phone = (meta['phone'] ?? '').toString();

    final patientData = await _supabase
        .from('patients')
        .select('id')
        .eq('family_id', familyIdFromParent.trim().toUpperCase())
        .maybeSingle();

    if (patientData == null) throw Exception('Family ID not found');

    await _supabase.from('profiles').upsert({
      'id': user.id,
      'full_name': name,
      'user_role': 'caregiver',
    });
    await _supabase.from('caregivers').upsert({'id': user.id, 'phone': phone});
    await _supabase.from('patient_caregiver_link').upsert({
      'patient_id': patientData['id'],
      'caregiver_id': user.id,
    });

    final patientProfile = await _supabase
        .from('profiles')
        .select('full_name')
        .eq('id', patientData['id'])
        .maybeSingle();
    return (patientProfile?['full_name'] ?? 'Patient').toString();
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

// Top-level helpers for your screens
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
Future<String> completePatientProfileForCurrentUser(String userId) =>
    AuthService.instance.completePatientProfileForCurrentUser(userId);
Future<String> completeCaregiverProfileForCurrentUser({
  required String familyIdFromParent,
}) => AuthService.instance.completeCaregiverProfileForCurrentUser(
  familyIdFromParent: familyIdFromParent,
);
Future<String?> getCurrentUserRole() =>
    AuthService.instance.getCurrentUserRole();
Future<String?> getCurrentUserId() => AuthService.instance.getCurrentUserId();
