import 'package:flutter/material.dart';
import 'package:medpal/constants.dart';
import 'package:medpal/auth/auth_service.dart'; // Standard import to access the class
import 'package:medpal/screens/welcome_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MedPal', style: TextStyle(color: Colors.white)),
        backgroundColor: primaryColor,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            tooltip: 'Logout',
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              try {
                // FIX 1: Access signOut through the Singleton instance
                await AuthService.instance.signOut();
                if (!context.mounted) return;
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                  (route) => false,
                );
              } catch (e) {
                debugPrint('Logout error: $e');
              }
            },
          ),
        ],
      ),
      body: FutureBuilder<String?>(
        // FIX 2: Access role check through the Singleton instance
        future: AuthService.instance.getCurrentUserRole(),
        builder: (context, snapRole) {
          if (snapRole.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          final role = snapRole.data;
          
          if (role == 'patient') {
            return FutureBuilder<String?>(
              // FIX 3: Access family ID check through the Singleton instance
              future: AuthService.instance.getMyFamilyIdIfPatient(),
              builder: (context, snapFam) {
                if (snapFam.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final fam = snapFam.data ?? '-';
                return _InfoCard(
                  title: 'Welcome to MedPal!',
                  subtitle: 'Your Family ID',
                  value: fam,
                );
              },
            );
          } else if (role == 'caregiver') {
            return FutureBuilder<String?>(
              // FIX 4: Access patient name check through the Singleton instance
              future: AuthService.instance.getLinkedPatientNameIfCaregiver(),
              builder: (context, snapName) {
                if (snapName.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final name = snapName.data ?? 'Patient';
                return _InfoCard(
                  title: 'Welcome to MedPal!',
                  subtitle: "You're caregiver of",
                  value: name,
                );
              },
            );
          }
          return const Center(child: Text('Welcome to MedPal!'));
        },
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String value;
  
  const _InfoCard({
    required this.title,
    required this.subtitle,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 16, color: Colors.black54),
            ),
            const SizedBox(height: 8),
            SelectableText(
              value,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}