import 'package:flutter/material.dart';

class DialogButton extends StatelessWidget {
  final String buttonName;
  final VoidCallback onPressed;

  const DialogButton({super.key, required this.buttonName, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20)
      ),
      onPressed: onPressed,
      color: const Color.fromARGB(255, 159, 159, 159),
      child: Text(buttonName,
      style: TextStyle(
        fontWeight: FontWeight.bold,
        color: Colors.white,
        letterSpacing: 1,
      )
      ),
    );
  }
}