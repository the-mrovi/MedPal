import 'package:flutter/material.dart';
import 'package:medpal/constants.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ResetPasswordOTPScreen extends StatefulWidget {
  final String email;
  const ResetPasswordOTPScreen({super.key, required this.email});

  @override
  State<ResetPasswordOTPScreen> createState() => _ResetPasswordOTPScreenState();
}

class _ResetPasswordOTPScreenState extends State<ResetPasswordOTPScreen> {
  final _otpCtrl = TextEditingController();
  final _newPassCtrl = TextEditingController();
  bool _loading = false;

  Future<void> _verifyAndReset() async {
    final otp = _otpCtrl.text.trim();
    final newPassword = _newPassCtrl.text.trim();

    if (otp.length < 6 || newPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the code and new password')),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      // 1. Verify the OTP
      await Supabase.instance.client.auth.verifyOTP(
        email: widget.email,
        token: otp,
        type: OtpType.recovery,
      );

      // 2. Update to new password
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(password: newPassword),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password reset successful!')),
      );
      
      // Return to Login screen
      Navigator.popUntil(context, (route) => route.isFirst);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Verification failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('Verify Code'), backgroundColor: Colors.white, foregroundColor: Colors.black, elevation: 0),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Text('Enter the 6-digit code sent to ${widget.email}'),
            const SizedBox(height: 20),
            TextField(
              controller: _otpCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Reset Code', filled: true, fillColor: secondaryColor),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _newPassCtrl,
              obscureText: true,
              decoration: InputDecoration(labelText: 'New Password', filled: true, fillColor: secondaryColor),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _loading ? null : _verifyAndReset,
              style: ElevatedButton.styleFrom(backgroundColor: primaryColor, minimumSize: const Size(double.infinity, 50)),
              child: _loading ? const CircularProgressIndicator(color: Colors.white) : const Text('Update Password', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}