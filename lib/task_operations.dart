// task_operations.dart
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:taskmanagement/data/database.dart';
import 'package:taskmanagement/services/noti_service.dart';

class TaskOperations {
  final TaskDatabase db;
  final Currency db2;
  final Box box1;
  final Box box2;
  final NotiService notiService;
  final BuildContext context;

  TaskOperations({
    required this.db,
    required this.db2,
    required this.box1,
    required this.box2,
    required this.notiService,
    required this.context,
  });

  String timeOfDayToString(TimeOfDay time) {
    return "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
  }

  TimeOfDay stringToTimeOfDay(String timeString) {
    final parts = timeString.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  void checkBoxChanged(bool? value, int index) async {
    bool isChecked = !db.taskList[index][1];
    bool rewardGiven = db.taskList[index][4];

    if (isChecked && !rewardGiven) {
      int currentAmount = box2.get("CURRENCY", defaultValue: 0);
      int newAmount = currentAmount + 50;
      box2.put("CURRENCY", newAmount);
      db.taskList[index][4] = true;
    }

    db.taskList[index][1] = !db.taskList[index][1];
    db.updateDatabase();
  }

  Future<void> saveNewTask({
    required TextEditingController textController,
    required TextEditingController urlController,
    required DateTime selectedDate,
    required String priority,
    required int? reminderValue,
    required String? reminderUnit,
    required TimeOfDay selectedTime,
    required String category,
    required DateTime defaultDate,
    required TimeOfDay defaultTime,
  }) async {
    final taskText = textController.text;
    final urlText = urlController.text.trim();
    final String? safeURL = urlText.isEmpty ? null : urlText;

    if (taskText.trim().isEmpty) return;

    final scheduledTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedTime.hour,
      selectedTime.minute,
    );

    DateTime reminderTime = scheduledTime;
    if (reminderValue != null && reminderUnit != null) {
      switch (reminderUnit) {
        case 'minute':
          reminderTime = scheduledTime.subtract(Duration(minutes: reminderValue));
          break;
        case 'hour':
          reminderTime = scheduledTime.subtract(Duration(hours: reminderValue));
          break;
        case 'day':
          reminderTime = scheduledTime.subtract(Duration(days: reminderValue));
          break;
        case 'week':
          reminderTime = scheduledTime.subtract(Duration(days: reminderValue * 7));
          break;
        default:
          reminderTime = scheduledTime.subtract(Duration(minutes: reminderValue));
      }
    }

    db.taskList.add([
      taskText,
      false,
      selectedDate,
      priority,
      false,
      timeOfDayToString(selectedTime),
      category,
      safeURL,
    ]);

    textController.clear();

    final notificationId = UniqueKey().hashCode;

    if (scheduledTime.isAfter(DateTime.now())) {
      await notiService.scheduleReminder(
        id: notificationId,
        title: taskText,
        body: "Reminder: $taskText is due soon!",
        scheduledTime: reminderTime,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Reminder scheduled for ${reminderTime.toLocal()}'),
          duration: Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
    }

    db.updateDatabase();
    Navigator.of(context).pop();
  }

  void deleteTask(int index) {
    final taskName = db.taskList[index][0];
    db.taskList.removeAt(index);
    db.updateDatabase();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Task "$taskName" deleted'),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.redAccent,
      ),
    );
  }
}
