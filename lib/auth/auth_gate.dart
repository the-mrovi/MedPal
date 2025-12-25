import 'package:flutter/material.dart';
import 'package:medpal/screens/home_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:medpal/screens/login_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  // Function to fetch the user's role from the database
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
        // 1. Loading State
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final session = snapshot.data?.session;

        // 2. If NOT logged in, show Login Screen
        if (session == null) {
          return const LoginScreen();
        }

        // 3. If logged in, find their role to redirect to the correct home
        return FutureBuilder<String?>(
          future: _getUserRole(session.user.id),
          builder: (context, roleSnapshot) {
            if (roleSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(body: Center(child: CircularProgressIndicator()));
            }

            final role = roleSnapshot.data;

            if (role == 'patient') {
              return const HomeScreen();
            } else if (role == 'caregiver') {
              return const HomeScreen();
            } else {
              // Fallback if role isn't set yet (common during first-time signup)
              return const Scaffold(body: Center(child: Text("Setting up your profile...")));
            }
          },
        );
      },
    );
  }
}