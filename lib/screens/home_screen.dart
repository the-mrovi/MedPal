import 'package:flutter/material.dart';
import 'package:medpal/constants.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('MedPal'),
        backgroundColor: primaryColor,
        automaticallyImplyLeading: false,
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
