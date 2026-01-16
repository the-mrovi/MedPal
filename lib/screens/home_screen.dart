import 'package:flutter/material.dart';
import 'package:medpal/constants.dart';
import 'package:medpal/auth/auth_service.dart';
import 'package:medpal/screens/welcome_screen.dart';
import 'package:medpal/screens/add_routine_screen.dart';
import 'package:medpal/screens/add_medicine_screen.dart';

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
                // Clear the session via Singleton
                await AuthService.instance.signOut();

                if (!context.mounted) return;

                // Return to Welcome and clear the navigation stack
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
        future: AuthService.instance.getMyFamilyIdIfPatient(),
        builder: (context, snapFam) {
          if (snapFam.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final familyId = snapFam.data ?? '-';

          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Your Family ID',
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                  const SizedBox(height: 8),
                  SelectableText(
                    familyId,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: 180,
                    height: 44,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(
                        context,
                      ).pushNamed(AddRoutineScreen.routeName),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Routine',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: 180,
                    height: 44,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(
                        context,
                      ).pushNamed(AddMedicineScreen.routeName),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Add Medicine',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
