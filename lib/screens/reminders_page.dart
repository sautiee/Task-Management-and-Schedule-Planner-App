import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class RemindersPage extends StatefulWidget {
  const RemindersPage({Key? key}) : super(key: key);

  @override
  State<RemindersPage> createState() => _RemindersPageState();
}

class _RemindersPageState extends State<RemindersPage> {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  List<PendingNotificationRequest> _pendingReminders = [];

  @override
  void initState() {
    super.initState();
    _loadReminders();
  }

  Future<void> _loadReminders() async {
    final reminders = await flutterLocalNotificationsPlugin.pendingNotificationRequests();
    setState(() {
      _pendingReminders = reminders;
    });
  }

  Future<void> _cancelReminder(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
    _loadReminders();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Reminder cancelled'),
          duration: Duration(seconds: 2),
          backgroundColor: Theme.of(context).colorScheme.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reminders', style: TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Theme.of(context).colorScheme.onSurface), // <-- Custom icon
          onPressed: () => Navigator.of(context).pop(),
          tooltip: 'Back',
        ),
      ),
      body: _pendingReminders.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_off, size: 64, color: Theme.of(context).colorScheme.primary.withOpacity(0.4)),
                  const SizedBox(height: 18),
                  Text(
                    'No Pending Reminders',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'You have no scheduled reminders.',
                    style: TextStyle(
                      fontSize: 15,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: _pendingReminders.length,
              itemBuilder: (context, index) {
                final reminder = _pendingReminders[index];
                return Card(
                  elevation: 2.5,
                  color: Theme.of(context).colorScheme.secondary,
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    leading: Icon(Icons.alarm, color: Theme.of(context).colorScheme.primary),
                    title: Text(reminder.title ?? 'No Title'),
                    subtitle: Text(reminder.body ?? ''),
                    trailing: IconButton(
                      icon: Icon(Icons.cancel, color: Colors.red),
                      tooltip: 'Cancel Reminder',
                      onPressed: () => _cancelReminder(reminder.id),
                    ),
                  ),
                );
              },
            ),
    );
  }
}