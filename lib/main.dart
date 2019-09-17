import 'package:flutter/material.dart';
import 'package:flutter_instagram_clone/screens/login_screen.dart';
import 'package:flutter_instagram_clone/screens/signup_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Instagram Clone',
      debugShowCheckedModeBanner: false,
      home: LoginScreen(),
      routes: {
        LoginScreen.id: (context) => LoginScreen(),
        SignupScreen.id: (context) => SignupScreen(),
      },
    );
  }
}
