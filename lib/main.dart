import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_instagram_clone/screens/feed_screen.dart';
import 'package:flutter_instagram_clone/screens/home_screen.dart';
import 'package:flutter_instagram_clone/screens/login_screen.dart';
import 'package:flutter_instagram_clone/screens/signup_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  Widget _getScreenId() {
    return StreamBuilder<FirebaseUser>(
      stream: FirebaseAuth.instance.onAuthStateChanged,
      builder: (BuildContext context, snapshot) {
        if (snapshot.hasData) {
          return HomeScreen(userId: snapshot.data.uid);
        } else {
          return LoginScreen();
        }
      },
    );
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Instagram Clone',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryIconTheme: Theme.of(context).primaryIconTheme.copyWith(
          color: Colors.black,
        ),
      ),
      home: _getScreenId(),
      routes: {
        LoginScreen.id: (context) => LoginScreen(),
        SignupScreen.id: (context) => SignupScreen(),
        FeedScreen.id: (context) => FeedScreen(),
      },
    );
  }
}
