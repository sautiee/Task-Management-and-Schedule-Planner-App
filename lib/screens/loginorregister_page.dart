import 'package:flutter/material.dart';
import 'package:taskmanagement/screens/login_page.dart';
import 'package:taskmanagement/screens/register_page.dart';

class LoginOrRegesterPage extends StatefulWidget {
  const LoginOrRegesterPage({super.key});

  @override
  State<LoginOrRegesterPage> createState() => _LoginOrRegesterPageState();
}

class _LoginOrRegesterPageState extends State<LoginOrRegesterPage> {
  // Show login page first
  bool showLoginPage = true;

  // Toggle between Login and Register pages
  void togglePages() {
    setState(() {
      showLoginPage = !showLoginPage;
    });
  }


  @override
  Widget build(BuildContext context) {
    if (showLoginPage) {
      return LoginPage(onTap: togglePages);    
    }
    else {
      return RegisterPage(onTap: togglePages,);
    }
  }
}