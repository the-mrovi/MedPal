import 'package:flutter/material.dart';
import 'package:medpal/screens/home_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:medpal/screens/login_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  Future<String?> _getUserRole(String userId) async {
    final data = await Supabase.instance.client
        .from('profiles')
        .select('user_role')
        .eq('id', userId)
        .maybeSingle();
    return data?['user_role'] as String?;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final session = snapshot.data?.session;

        if (session == null) {
          return const LoginScreen();
        }

        return FutureBuilder<String?>(
          future: _getUserRole(session.user.id),
          builder: (context, roleSnapshot) {
            if (roleSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(body: Center(child: CircularProgressIndicator()));
            }

            final role = roleSnapshot.data;

            if (role == 'patient' || role == 'caregiver') {
              return const HomeScreen();
            } else {
              return const Scaffold(body: Center(child: Text("Setting up your profile...")));
            }
          },
        );
      },
    );
  }
}