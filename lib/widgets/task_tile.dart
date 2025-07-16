import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:taskmanagement/constants/colors.dart';
import 'package:animated_line_through/animated_line_through.dart';
import 'package:url_launcher/url_launcher.dart';


class TaskTile extends StatelessWidget {
  final String taskName;
  final bool taskCompleted;
  final String? priority;
  final DateTime date;
  final String time;
  final String? taskURL;

  final Function(bool?)? onChanged;
  final Function(BuildContext)? deleteFunction;

  const TaskTile({
    super.key,
    required this.taskName,
    required this.taskCompleted,
    required this.onChanged,
    required this.deleteFunction,
    required this.priority,
    required this.date,
    required this.time,
    this.taskURL,
  });

  //get priority
  Color _getPriorityColor(String? priority) {
    switch (priority) {
      case "High":
        return Colors.red;
      case "Medium":
        return Colors.orange;
      case "Low":
        return Colors.lightBlue;
      case "None":
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  // For handling URLs
  // ignore: unused_element
  void _launchUrl(String urlString, BuildContext context) async {
    final Uri url = Uri.parse(urlString);

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
    else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not launch the URL')),
      );
    }
  }

  // Open moodle app
  Future<void> openMoodleApp(String urlString, BuildContext context) async {
    try {
      final cleaned = urlString.trim();
      final encodedUrl = Uri.encodeComponent(cleaned);
      final moodleUri = Uri.parse('moodlemobile://link=$encodedUrl');

      print("Launching Moodle URI: $moodleUri");

      if (await canLaunchUrl(moodleUri)) {
        await launchUrl(moodleUri);
        return;
      }

      final webUri = Uri.parse(cleaned);
      if (await canLaunchUrl(webUri)) {
        await launchUrl(webUri, mode: LaunchMode.externalApplication);
      } else {
        throw Exception("Can't open fallback web link.");
      }
    } catch (e) {
      print("Launch error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch the URL')),
      );
    }
  }

  @override
  @override
Widget build(BuildContext context) {
  final Color priorityColor = _getPriorityColor(priority);

  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 7),
    child: Slidable(
      endActionPane: ActionPane(
        motion: StretchMotion(),
        children: [
          SlidableAction(
            onPressed: deleteFunction,
            icon: Icons.delete,
            backgroundColor: colorRed,
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(12),
              bottomRight: Radius.circular(12),
            ),
          ),
        ],
      ),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: taskCompleted
              ? Theme.of(context).colorScheme.secondary.withValues(alpha: 0.5)
              : Theme.of(context).colorScheme.secondary,
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(12),
            bottomRight: Radius.circular(12),
            topLeft: Radius.circular(12),
            bottomLeft: Radius.circular(12),
            // No left radius, so the color bar and tile are flush
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Priority color bar
              Container(
                width: 7,
                height: double.infinity,
                decoration: BoxDecoration(
                  color: priorityColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                    // No right radius, so it fits flush with the tile
                  ),
                ),
              ),
              const SizedBox(width: 0), // Remove gap for seamless look

              // ...rest of your code...
              const SizedBox(width: 10),
              Transform.scale(
                scale: 1.25,
                child: Checkbox(
                  value: taskCompleted,
                  onChanged: onChanged,
                  activeColor: Theme.of(context).colorScheme.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),

              // Task info
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AnimatedLineThrough(
                        duration: const Duration(milliseconds: 200),
                        isCrossed: taskCompleted,
                        child: Text(
                          taskName,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSecondary,
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            letterSpacing: 0.1,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.calendar_today, size: 15, color: Theme.of(context).colorScheme.inversePrimary),
                          const SizedBox(width: 4),
                          Text(
                            "${date.day}/${date.month}/${date.year}",
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.inversePrimary,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Icon(Icons.access_time, size: 15, color: Theme.of(context).colorScheme.inversePrimary),
                          const SizedBox(width: 4),
                          Text(
                            time,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.inversePrimary,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Right side icons
              Row(
                children: [
                  if (taskURL != null && taskURL!.trim().isNotEmpty)
                    Tooltip(
                      message: 'Open link',
                      child: IconButton(
                        icon: Icon(Icons.link, color: Colors.blueAccent),
                        onPressed: () async {
                          final cleanUrl = taskURL!.trim();
                          await openMoodleApp(cleanUrl, context);
                        },
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.only(right: 10.0),
                    child: Icon(
                      Icons.flag_rounded,
                      size: 22,
                      color: priorityColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
}
