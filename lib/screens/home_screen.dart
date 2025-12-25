import 'package:flutter/material.dart';
import 'package:medpal/constants.dart';
import 'package:medpal/auth/auth_service.dart' as auth;
import 'package:medpal/screens/welcome_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('MedPal'),
        backgroundColor: primaryColor,
        automaticallyImplyLeading: true,
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              )
            : null,
        actions: [
          IconButton(
            tooltip: 'Logout',
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              try {
                await auth.signOut();
              } finally {
                if (!context.mounted) return;
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
      body: Center(
        child: Text(
          'Welcome to MedPal!',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: primaryColor,
          ),
        ),
      ),
    );
  }
}
