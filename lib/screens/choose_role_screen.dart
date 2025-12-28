import 'package:flutter/material.dart';
import 'package:medpal/constants.dart';
import 'package:medpal/screens/caregiver_screen.dart';
import 'package:medpal/screens/home_screen.dart';
 // Ensure this matches your filename
import 'package:medpal/auth/auth_service.dart' as auth;

class ChooseRoleScreen extends StatefulWidget {
  final String userId;

  const ChooseRoleScreen({super.key, required this.userId});

  @override
  State<ChooseRoleScreen> createState() => _ChooseRoleScreenState();
}

class _ChooseRoleScreenState extends State<ChooseRoleScreen> {
  bool _loading = false;

  // Handle Patient Role Selection
  Future<void> _choosePatient() async {
    if (widget.userId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Missing User ID')),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      // Calls the fixed AuthService method that uses userId directly
      final familyId = await auth.completePatientProfileForCurrentUser(widget.userId);
      
      if (!mounted) return;

      // Show the Family ID to the user so they can share it
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          title: const Text('Your Family ID'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Share this code with your caregiver to link your accounts:'),
              const SizedBox(height: 15),
              SelectableText(
                familyId,
                style: const TextStyle(
                  fontSize: 22, 
                  fontWeight: FontWeight.bold, 
                  color: primaryColor,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Got it'),
            )
          ],
        ),
      );

      if (!mounted) return;

      // Navigate to Home and clear the stack
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
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
                'Welcome to MedPal+',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28, 
                  fontWeight: FontWeight.bold, 
                  color: primaryColor,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Please select your role to continue',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 60),
              
              // Patient Option
              ElevatedButton(
                onPressed: _loading ? null : _choosePatient,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  minimumSize: const Size(double.infinity, 60),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                ),
                child: _loading 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      'I am a Patient', 
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
              ),
              
              const SizedBox(height: 25),
              const Text(
                'OR', 
                style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 25),

              // Caregiver Option
              OutlinedButton(
                onPressed: _loading ? null : () {
                  // Navigate to the Family ID input screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FamilyIdScreen(userId: widget.userId),
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: primaryColor, width: 2),
                  minimumSize: const Size(double.infinity, 60),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text(
                  'I am a Caregiver', 
                  style: TextStyle(color: primaryColor, fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}