import 'package:flutter/material.dart';

class DeleteChip extends StatefulWidget {
  const DeleteChip({super.key});

  @override
  State<DeleteChip> createState() => _DeleteChipState();
}

class _DeleteChipState extends State<DeleteChip> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(50),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary,
        ),
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}