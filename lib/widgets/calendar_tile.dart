import 'package:flutter/material.dart';

class CalendarTile extends StatelessWidget {
  final String taskName;
  final bool taskCompleted;
  final DateTime date;
  final String time;
  final VoidCallback? onTap;
  final VoidCallback? onCheck;

  const CalendarTile({
    super.key,
    required this.taskName,
    required this.taskCompleted,
    required this.date,
    required this.time,
    this.onTap,
    this.onCheck,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      child: Material(
        color: Theme.of(context).colorScheme.secondary.withOpacity(taskCompleted ? 0.7 : 1.0),
        borderRadius: BorderRadius.circular(10),
        elevation: 1.5,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 14),
            child: Row(
              children: [
                // Task name
                Expanded(
                  child: Text(
                    taskName,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: Theme.of(context).colorScheme.onSecondary,
                      decoration: taskCompleted ? TextDecoration.lineThrough : null,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // Time
                const SizedBox(width: 10),
                Icon(Icons.access_time, size: 16, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 3),
                Text(
                  time,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}