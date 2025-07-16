import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:taskmanagement/screens/loginorregister_page.dart';
import 'package:taskmanagement/screens/main_page.dart';

class AuthePage extends StatelessWidget {
  const AuthePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // fade transition between login and main page
          return AnimatedSwitcher(
            duration: Duration(milliseconds: 400),
            child: snapshot.hasData
                ? MainPage()
                : LoginOrRegesterPage(),
          );
        },
      ),
    );
  }
}