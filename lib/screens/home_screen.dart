import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:medpal/constants.dart';
import 'package:medpal/auth/auth_service.dart';
import 'package:medpal/screens/welcome_screen.dart';
import 'package:medpal/screens/add_routine_screen.dart';
import 'package:medpal/screens/add_medicine_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    // Current date formatting for the header
    String formattedDate = DateFormat('EEEE, MMM d • h:mm a').format(DateTime.now());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('MedPal', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: primaryColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await AuthService.instance.signOut();
              if (!mounted) return;
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            
            // 1. Welcome Header
            const Text(
              'Welcome to MedPal',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.black87),
            ),
            
            const SizedBox(height: 8),
            Text(
              formattedDate,
              style: const TextStyle(fontSize: 16, color: Colors.black54, fontWeight: FontWeight.w500),
            ),
            
            const SizedBox(height: 40),

            // 2. Instruction Text
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                'Let’s set up your daily routine and medicines to get started.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, height: 1.4, color: Colors.black87),
              ),
            ),
            
            const SizedBox(height: 40),

            // 3. Family ID Section - Added safety check to prevent Null error
            FutureBuilder<String?>(
              future: AuthService.instance.getMyFamilyIdIfPatient(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) return const SizedBox(height: 40);
                
                final familyId = snapshot.data ?? 'Not Assigned';

                return Column(
                  children: [
                    const Text('Your Family ID', style: TextStyle(color: Colors.black38, fontSize: 12)),
                    SelectableText(
                      familyId,
                      style: const TextStyle(fontWeight: FontWeight.bold, color: primaryColor, fontSize: 16),
                    ),
                    const SizedBox(height: 30),
                  ],
                );
              }
            ),

            // 4. Set Daily Routine Card
            _buildActionCard(
              title: 'Set Daily Routine',
              icon: Icons.wb_sunny_outlined,
              backgroundColor: primaryColor,
              textColor: Colors.white,
              onTap: () => Navigator.of(context).pushNamed(AddRoutineScreen.routeName),
              trailing: const Icon(Icons.chevron_right, color: Colors.white),
            ),

            const SizedBox(height: 16),

            // 5. Add Medicine Card
            _buildActionCard(
              title: 'Add Your First Medicine',
              icon: Icons.medical_services_outlined,
              backgroundColor: Colors.white,
              textColor: Colors.black87,
              borderColor: Colors.black12,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AddMedicineScreen()),
              ),
              trailing: Icon(Icons.add_circle, color: Colors.grey.shade300),
            ),

            const SizedBox(height: 32),
            const Text(
              'We will remind you automatically once you are set up.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black38, fontSize: 13),
            ),
          ],
        ),
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.black26,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.medication_liquid), label: 'Medicines'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: 'Schedule'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  // Reusable helper widget for action cards
  Widget _buildActionCard({
    required String title,
    required IconData icon,
    required Color backgroundColor,
    required Color textColor,
    Color? borderColor,
    required VoidCallback onTap,
    required Widget trailing,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
          border: borderColor != null ? Border.all(color: borderColor) : null,
          boxShadow: backgroundColor == Colors.white
              ? [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))]
              : null,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: textColor == Colors.white ? Colors.white.withOpacity(0.2) : primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: textColor == Colors.white ? Colors.white : primaryColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }
}