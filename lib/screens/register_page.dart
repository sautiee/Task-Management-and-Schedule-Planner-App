import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:taskmanagement/components/my_textfield.dart';
import 'package:taskmanagement/components/signin_button.dart';
import 'package:taskmanagement/components/square_tile.dart';
import 'package:taskmanagement/services/auth_service.dart';

class RegisterPage extends StatefulWidget {
  final Function()? onTap;
  
  const RegisterPage({
    super.key,
    required this.onTap,
    });

  @override
  State<RegisterPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<RegisterPage> {
  // Controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // Sign Up method
  void signUp() async {
    // Show loading circle
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Center(
          child: CircularProgressIndicator(
            color: Theme.of(context).colorScheme.primary,
          ),
        );
      }
    );

    // Try Creating user
    try {
        // Check if password matches
        if (passwordController.text == confirmPasswordController.text) {
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: emailController.text,
            password: passwordController.text,
          );
        }
        else {
          // Show error message
          showErrorMessage("Passwords do not match");
        }

      Navigator.pop(context); // Remove circle indicator on success
    } on FirebaseAuthException catch (e) {

      Navigator.pop(context); // Remove circle indicator on failure to display messages

      // Show error message
      showErrorMessage(e.code);
    } catch (e) {
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
                      "assets/images/taskmanagementlogowhitebg.png",
                      width: 150,
                      height: 150,
                      fit: BoxFit.contain,
                    ),
              ),
          
              SizedBox(height: 20,),
          
              // Welcome back
              Text(
                "Let's create an account for you!",
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
              ),
          
              SizedBox(height: 20,),
          
              // Password
              MyTextField(
                controller: passwordController,
                hintText: 'Password',
                obscureText: true,
              ),
          
              SizedBox(height: 20,),

               // Confirm Password
              MyTextField(
                controller: confirmPasswordController,
                hintText: 'Confirm Password',
                obscureText: true,
              ),
          
              SizedBox(height: 20,),
          
              // Sign in button
              SignInButton(
                text: "Sign up",
                onTap: signUp,
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
                  Text("Already Have an account?"),
                  SizedBox(width: 5,),
                  GestureDetector(
                    onTap: widget.onTap,
                    child: Text(
                      "Login now",
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