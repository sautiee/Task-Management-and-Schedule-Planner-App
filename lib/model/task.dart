import 'package:flutter/material.dart';

class Task {
  String? id;
  String? taskText;
  bool isCompleted;
  String? priority;
  DateTime? date;
  String? time;
  String category;
  String? url;
  final int? notificationId;

  Task({
    required this.id,
    required this.taskText,
    this.isCompleted = false,
    required this.priority,
    required this.date,
    required this.time,
    required this.category,
    this.url,
    this.notificationId,
  });

  static List<Task> taskList() {
    return [
      Task(id: '0', taskText: "Welcome!", isCompleted: false, priority: "None", date: DateTime.now(), time: TimeOfDay.now().toString(), category: "Main", url: '', notificationId: 0),
      Task(id: '1', taskText: "This is a completed task.", isCompleted: true, priority: "Medium", date: DateTime.now(), time: TimeOfDay.now().toString(), category: "Main", url: '', notificationId: 1),
    ];
  }
}