import 'package:flutter/material.dart';
import 'screens/settings/settings_screen.dart'; // Import Settings Screen
import 'screens/prescription/history_screen.dart'; // Import History Screen
import 'screens/auth/welcome_screen.dart'; // Import Welcome Screen
import 'screens/auth//login_screen.dart'; // Import Log-in Screen
import 'screens/auth/signup_screen.dart'; // Import Sign-up Screen
import 'screens/home/home_screen.dart'; // Import Home Screen

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pharma Scan',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => WelcomeScreen(), // Welcome Page
        '/login': (context) => LoginPage(), // Log-In Page
        '/signup': (context) => SignupPage(), // Sign-Up Page
        '/home': (context) => HomeScreen(), // Home Page
        '/prescription_history': (context) => HistoryScreen(), // History Screen
        '/settings': (context) => SettingsScreen(), // Settings
      },
    );
  }
}