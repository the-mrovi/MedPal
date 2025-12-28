import 'package:flutter/material.dart';
import 'package:medpal/constants.dart';
import 'package:medpal/screens/home_screen.dart';
import 'package:medpal/auth/auth_service.dart' as auth;

class FamilyIdScreen extends StatefulWidget {
  final String userId; 
  const FamilyIdScreen({super.key, required this.userId});

  @override
  State<FamilyIdScreen> createState() => _FamilyIdScreenState();
}

class _FamilyIdScreenState extends State<FamilyIdScreen> {
  final _familyCtrl = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _familyCtrl.dispose();
    super.dispose();
  }

  Future<void> _linkCaregiver() async {
    final code = _familyCtrl.text.trim();
    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the Family ID')),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      // FIXED: Added the userId parameter here
      final patientName = await auth.completeCaregiverProfileForCurrentUser(
        userId: widget.userId, 
        familyIdFromParent: code,
      );

      if (!mounted) return;

      // Show success dialog
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          title: const Text('Linked!'),
          content: Text('You are now the caregiver of $patientName.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );

      if (!mounted) return;

      // Navigate to Home and clear stack
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().contains('not found')
                ? 'Invalid Family ID. Please check the code and try again.'
                : 'Linking failed: $e',
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Text(
                'Please enter your\nFamily ID',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _familyCtrl,
                decoration: InputDecoration(
                  labelText: 'Family ID from patient',
                  hintText: 'e.g., MED-XXXXXX',
                  filled: true,
                  fillColor: secondaryColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loading ? null : _linkCaregiver,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Continue'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}