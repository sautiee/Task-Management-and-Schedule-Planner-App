import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:taskmanagement/components/my_textfield.dart';
import 'package:taskmanagement/components/signin_button.dart';
import 'package:taskmanagement/components/square_tile.dart';
import 'package:taskmanagement/services/auth_service.dart';

class LoginPage extends StatefulWidget {
  final Function()? onTap;
  
  const LoginPage({
    super.key,
    required this.onTap,
    });

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // Sign In method
  void signIn() async {
    // Show loading circle
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Center(
          child: CircularProgressIndicator(
            color: Theme.of(context).colorScheme.primary,
          ),
        );
      }
    );

    // Try Sign in
    try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      if (!mounted) return;

      // Remove loading dialog
      Navigator.pop(context);

    } on FirebaseAuthException catch (e) {

      if (!mounted) return;
      Navigator.pop(context);

      // Show error message
      showErrorMessage(e.code);
    } catch (e) {
        if (!mounted) return;
        Navigator.pop(context);
        //Navigator.pop(context);
        showErrorMessage("An unexpected error occured.");
      }
  }

  void wrongEmailMessage() {
    showDialog(
      context: context,
      builder: (context) {
        return const AlertDialog(
          title: Text("Wrong email, Try again."),
        );
      }
    );
  }

  void wrongPasswordMessage() {
    showDialog(
      context: context,
      builder: (context) {
        return const AlertDialog(
          title: Text("Wrong passowrd, Try again."),
        );
      }
    );
  }

  void showErrorMessage(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Error"),
          content: Text(message),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
          
              // Logo
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Image.asset(
                      "assets/images/taskmanagementlogotransparent.png",
                      width: 150,
                      height: 150,
                      fit: BoxFit.contain,
                    ),
              ),
          
              SizedBox(height: 20,),
          
              // Welcome back
              Text(
                "Welcome back, you\'ve been missed.",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
          
              SizedBox(height: 20,),
          
              // Username
              MyTextField(
                controller: emailController,
                hintText: 'Email',
                obscureText: false,
                icon: Icons.email,
              ),
          
              SizedBox(height: 20,),
          
              // Password
              MyTextField(
                controller: passwordController,
                hintText: 'Password',
                obscureText: true,
                icon: Icons.lock,
              ),
          
              //SizedBox(height: 10,),
          
              /*// Forgot password?
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: widget.onTap,
                      child: Text(
                        "Forgot Password?",
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                    ),
                  ],
                ),
              ),*/
          
              SizedBox(height: 20,),
          
              // Sign in button
              SignInButton(
                text: "Sign in",
                onTap: signIn,
              ),
          
              SizedBox(height: 20,),
          
              // Continue with... (ex. Google)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Row(
                  children: [
                    Expanded(
                      child: Divider(
                        thickness: 0.5,
                        color: Colors.grey[500],
                      ),
                    ),
                
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        "Or continue with",
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w500
                        ),
                        ),
                    ),
                
                    Expanded(
                      child: Divider(
                        thickness: 0.5,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
          
              SizedBox(height: 55,),
          
              // Google sign-in
              SquareTile(
                imagepath: "assets/images/Googlelogo.png",
                onTap: () => AuthService().signInWithGoogle(),
                ),
          
              SizedBox(height: 50,),
          
              // Not a member? Register now
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Not a member?"),
                  SizedBox(width: 5,),
                  GestureDetector(
                    onTap: widget.onTap,
                    child: Text(
                      "Register now",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                  )
                ],
              )
          
            ],
          ),
        ),
      ),
    );
  }
}