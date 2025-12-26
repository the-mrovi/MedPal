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
        title: const Text('MedPal', style: TextStyle(color: Colors.white)),
        backgroundColor: primaryColor,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            tooltip: 'Logout',
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              try {
                await auth.signOut();
                if (!context.mounted) return;
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                  (route) => false,
                );
              } catch (e) {
                // Handle logout error if any
              }
            },
          ),
        ],
      ),
      body: FutureBuilder<String?>(
        future: auth.getCurrentUserRole(),
        builder: (context, snapRole) {
          if (snapRole.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final role = snapRole.data;
          if (role == 'patient') {
            return FutureBuilder<String?>(
              future: auth.getMyFamilyIdIfPatient(),
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
              future: auth.getLinkedPatientNameIfCaregiver(),
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