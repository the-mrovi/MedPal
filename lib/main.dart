import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:medpal/constants.dart';
import 'package:medpal/screens/welcome_screen.dart';
import 'package:medpal/screens/add_routine_screen.dart';
import 'package:medpal/screens/add_medicine_screen.dart';

// 1. GLOBAL VARIABLE
// This allows you to access the database from any screen in your app.
final supabase = Supabase.instance.client;

Future<void> main() async {
  // 2. REQUIRED BINDING
  // This must be called before initializing Supabase to prevent errors.
  WidgetsFlutterBinding.ensureInitialized();

  // 3. INITIALIZE SUPABASE
  await Supabase.initialize(
    // Your Project URL
    url: 'https://rgmcjnfnfvzcerswtsym.supabase.co',

    // Your Anon Public Key (The long text you provided)
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJnbWNqbmZuZnZ6Y2Vyc3d0c3ltIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjY1ODE1ODksImV4cCI6MjA4MjE1NzU4OX0.vugpk78AC44TRDB5W7hV2BvqnTIG5mpZlepjdSkmTSo',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MedPal',
      theme: ThemeData(
        primaryColor: primaryColor,
        scaffoldBackgroundColor: Colors.white,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        colorScheme: ColorScheme.fromSwatch().copyWith(secondary: accentColor),
      ),
      home: const WelcomeScreen(),
      routes: {
        AddRoutineScreen.routeName: (_) => const AddRoutineScreen(),
        AddMedicineScreen.routeName: (_) => const AddMedicineScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
