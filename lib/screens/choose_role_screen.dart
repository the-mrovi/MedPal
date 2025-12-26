import 'package:flutter/material.dart';
import 'package:medpal/constants.dart';
import 'package:medpal/screens/caregiver_screen.dart';
import 'package:medpal/screens/home_screen.dart';
import 'package:medpal/auth/auth_service.dart' as auth;

class ChooseRoleScreen extends StatefulWidget {
  final String userId;

  const ChooseRoleScreen({super.key, required this.userId});

  @override
  State<ChooseRoleScreen> createState() => _ChooseRoleScreenState();
}

class _ChooseRoleScreenState extends State<ChooseRoleScreen> {
  bool _loading = false;

  Future<void> _choosePatient() async {
    if (widget.userId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Missing User ID')),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      final familyId = await auth.completePatientProfileForCurrentUser(widget.userId);
      
      if (!mounted) return;

      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          title: const Text('Your Family ID'),
          content: Text('Share this code with your caregiver to link your accounts:\n\n$familyId'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Got it'),
            )
          ],
        ),
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Setup failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Hello! Choose who you are',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: primaryColor),
              ),
              const SizedBox(height: 80),
              
              ElevatedButton(
                onPressed: _loading ? null : _choosePatient,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  minimumSize: const Size(double.infinity, 60),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _loading 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('I am a Patient', style: TextStyle(color: Colors.white, fontSize: 18)),
              ),
              
              const SizedBox(height: 20),
              const Text('OR', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: () {
                  // FIXED: Navigates to FamilyIdScreen instead of skipping to Home
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FamilyIdScreen(userId: widget.userId),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: primaryColor,
                  side: const BorderSide(color: primaryColor, width: 2),
                  minimumSize: const Size(double.infinity, 60),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('I am a Caregiver', style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}