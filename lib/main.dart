import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:someone_talking/BottomNavigationBar.dart';
import 'package:someone_talking/views/auth/RegistrationView.dart';

import 'views/auth/LoginView.dart';

Future<bool> isLoggedIn() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('jwtToken') != null;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final loggedIn = await isLoggedIn();
  runApp(MyApp(loggedIn: loggedIn));
}

class MyApp extends StatelessWidget {
  final bool loggedIn;
  const MyApp({super.key, required this.loggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Someone Talking',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.cyan),
      ),
      debugShowCheckedModeBanner: false,
      home: loggedIn ? const MainNavigationView() : const LoginView(),
      routes: {
        '/login': (context) => const LoginView(),
        '/registration': (context) => const RegistrationView(),
      },
    );
  }
}
