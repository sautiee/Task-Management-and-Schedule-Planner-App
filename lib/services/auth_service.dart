import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {

  // Google Sign in
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Begin sign in process
      final GoogleSignInAccount? gUser = await GoogleSignIn().signIn();

      // If the user cancels, return null
      if (gUser == null) return null;

      // Obtain auth details from request
      final GoogleSignInAuthentication gAuth = await gUser.authentication;

      // Create new credentials
      final credential = GoogleAuthProvider.credential(
        accessToken: gAuth.accessToken,
        idToken: gAuth.idToken,
      );

      // Sign in
      return await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (e) {
      // Optionally, print or log the error
      print('Google sign-in error: $e');
      return null;
    }
  }

  // Get current user profile image
  Widget getProfileImage() {
    final photoUrl = FirebaseAuth.instance.currentUser?.photoURL;
    if (photoUrl != null && photoUrl.isNotEmpty) {
      return ClipOval(
        child: Image.network(
          photoUrl,
          height: 100,
          width: 100,
          fit: BoxFit.cover,
        ),
      );
    } else {
      return Icon(Icons.account_circle, size: 100, color: Colors.grey[400]);
    }
  }
}