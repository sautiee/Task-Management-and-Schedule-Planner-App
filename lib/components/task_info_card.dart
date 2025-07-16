import 'package:flutter/material.dart';

class TaskInfoCard extends StatefulWidget {
  final String title;
  final String hintText;
  final controller;
  final IconData icon;
  
  const TaskInfoCard({
    super.key,
    required this.icon,
    required this.title,
    required this.hintText,
    required this.controller,
    });

  @override
  State<TaskInfoCard> createState() => _TaskInfoCardState();
}

class _TaskInfoCardState extends State<TaskInfoCard> {
  @override
  Widget build(BuildContext context) {
    return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 20, top: 20),
                  child: Row(
                    children: [
                      Icon(widget.icon),
                      SizedBox(width: 5,),
                      Text(
                        widget.title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 20),
                    child: TextField(
                      style: const TextStyle(fontSize: 15), 
                      controller: widget.controller,
                      decoration: InputDecoration(
                        hintText: widget.hintText,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Theme.of(context).colorScheme.onPrimary)
                        ),
                        labelStyle: TextStyle(fontSize: 15),
                        hintStyle: TextStyle(fontSize: 15),
                      ),
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                    ),
                  ),
              ],
            );
  }
}