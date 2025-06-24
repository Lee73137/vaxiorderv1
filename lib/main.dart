import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vaxiorderv1/screens/homepage.dart';
import 'package:vaxiorderv1/screens/loginpage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final savedUserInfo = prefs.getString('UserName');

  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: savedUserInfo == null ? '/login' : '/home',
      routes: {
        '/login': (context) => const LoginPage(),
        '/home': (context) => const HomePage(),
      },
    ),
  );
}
