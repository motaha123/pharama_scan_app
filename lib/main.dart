import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:pharma_scan/screens/prescription/history_screen.dart';
import 'package:pharma_scan/screens/settings/settings_screen.dart';
import 'package:pharma_scan/screens/auth/welcome_screen.dart';
import 'package:pharma_scan/screens/auth/login_screen.dart';
import 'package:pharma_scan/screens/auth/signup_screen.dart';
import 'package:pharma_scan/screens/home/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('ar')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
            title: 'Pharma Scan',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Poppins',
      ),

      home: const WelcomeScreen(),
      routes: {
        '/login': (context) =>  LoginPage(),
        '/signup': (context) =>  SignupPage(),
        '/home': (context) =>  HomeScreen(),
        '/settings': (context) => SettingsScreen(),
        '/history': (context) => HistoryScreen(),
      },
      onGenerateRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => const WelcomeScreen(),
        );
      },
    );
  }
}
