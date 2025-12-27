import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:medpal/screens/home_screen.dart';
import 'package:medpal/screens/login_screen.dart';
import 'package:medpal/screens/choose_role_screen.dart';
import 'package:medpal/auth/auth_service.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      // Listen to authentication state changes (login, logout, session refresh)
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        // Show a loader while checking the initial session
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final session = snapshot.data?.session;

        // 1. If no session exists, the user is not logged in. Send to LoginScreen.
        if (session == null) {
          return const LoginScreen();
        }

        // 2. If session exists, check if the user has a profile/role in the database.
        return FutureBuilder<String?>(
          future: AuthService.instance.getCurrentUserRole(),
          builder: (context, roleSnapshot) {
            // Show a loader while the database query is running
            if (roleSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            final role = roleSnapshot.data;

            // 3. If they have a role, they are a returning user. Send to HomeScreen.
            if (role == 'patient' || role == 'caregiver') {
              return const HomeScreen();
            } 
            
            // 4. If they have no role, they are a new user (usually from Google).
            // Send to ChooseRoleScreen to complete their profile setup.
            else {
              return ChooseRoleScreen(userId: session.user.id);
            }
          },
        );
      },
    );
  }
}