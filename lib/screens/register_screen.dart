import 'package:flutter/material.dart';
import 'package:medpal/constants.dart';
import 'package:medpal/screens/choose_role_screen.dart';
import 'package:medpal/auth/auth_service.dart'; // Ensure this matches your project structure

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // Controllers for input fields
  final _usernameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();

  bool _loading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  // Handle Standard Email/Password Registration
  Future<void> _doRegister() async {
    final username = _usernameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final phone = _phoneCtrl.text.trim();
    final password = _passwordCtrl.text;
    final confirm = _confirmPasswordCtrl.text;

    if (username.isEmpty || email.isEmpty || phone.isEmpty || password.isEmpty) {
      _showSnackBar('Please fill in all fields');
      return;
    }

    if (password != confirm) {
      _showSnackBar('Passwords do not match');
      return;
    }

    setState(() => _loading = true);
    try {
      final response = await AuthService.instance.signUpBasic(
        email: email,
        password: password,
        username: username,
        phone: phone,
      );

      if (!mounted) return;

      if (response.user != null) {
        // For email signup, we manually move to role selection
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ChooseRoleScreen(userId: response.user!.id),
          ),
        );
      }
    } catch (e) {
      _showSnackBar('Registration failed: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // Handle Google OAuth Registration
  Future<void> _continueWithGoogle() async {
    setState(() => _loading = true);
    try {
      // Logic: Just trigger the sign-in. AuthGate is listening and will 
      // automatically redirect the user once the browser returns.
      await AuthService.instance.signInWithGoogle();
    } catch (e) {
      if (!mounted) return;
      _showSnackBar('Google login failed: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white, 
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Create Account',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Join MedPal to manage your health.',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
            const SizedBox(height: 30),
            
            _buildTextField(_usernameCtrl, 'Username', icon: Icons.person_outline),
            const SizedBox(height: 15),
            _buildTextField(_emailCtrl, 'Email', icon: Icons.email_outlined, keyboard: TextInputType.emailAddress),
            const SizedBox(height: 15),
            _buildTextField(_phoneCtrl, 'Phone', icon: Icons.phone_outlined, keyboard: TextInputType.phone),
            const SizedBox(height: 15),
            _buildTextField(
              _passwordCtrl, 
              'Password', 
              icon: Icons.lock_outline, 
              obscure: _obscurePassword,
              isPassword: true,
              toggleVisibility: () => setState(() => _obscurePassword = !_obscurePassword),
            ),
            const SizedBox(height: 15),
            _buildTextField(_confirmPasswordCtrl, 'Confirm Password', icon: Icons.lock_reset, obscure: true),
            
            const SizedBox(height: 30),
            
            ElevatedButton(
              onPressed: _loading ? null : _doRegister,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                minimumSize: const Size(double.infinity, 55),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Register', style: TextStyle(color: Colors.white, fontSize: 18)),
            ),
            
            const SizedBox(height: 20),
            const Row(
              children: [
                Expanded(child: Divider()),
                Padding(padding: EdgeInsets.symmetric(horizontal: 10), child: Text("OR")),
                Expanded(child: Divider()),
              ],
            ),
            const SizedBox(height: 20),
            
            OutlinedButton.icon(
              onPressed: _loading ? null : _continueWithGoogle,
              icon: Image.asset('assets/images/google.png', height: 24),
              label: const Text('Continue with Google', style: TextStyle(color: Colors.black87, fontSize: 16)),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 55),
                side: const BorderSide(color: Colors.grey),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController ctrl, 
    String label, {
    required IconData icon,
    bool obscure = false,
    bool isPassword = false,
    VoidCallback? toggleVisibility,
    TextInputType? keyboard,
  }) {
    return TextField(
      controller: ctrl,
      obscureText: obscure,
      keyboardType: keyboard,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: primaryColor),
        suffixIcon: isPassword 
            ? IconButton(
                icon: Icon(obscure ? Icons.visibility_off : Icons.visibility),
                onPressed: toggleVisibility,
              )
            : null,
        filled: true,
        fillColor: secondaryColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}