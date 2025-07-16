import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:popover/popover.dart';
import 'package:taskmanagement/data/database.dart';
import 'package:taskmanagement/widgets/priority_items.dart';
import 'package:taskmanagement/widgets/reminders.dart';

class DialogBox extends StatefulWidget {
  final controller;
  final urlController;
  final void Function(DateTime selectedDate, String priority, int? reminderValue, String? reminderUnit, TimeOfDay selectedTime, String category, DateTime defaultDate, TimeOfDay defaultTime, String? url, RepeatInterval? repeatInterval) onSave;
  final VoidCallback onCancel;
  final TaskDatabase db;
  final defaultDate;
  final defaultTime;

  const DialogBox({
    super.key,
    required this.controller,
    required this.urlController,
    required this.onSave,
    required this.onCancel,
    required this.db,
    this.defaultDate,
    this.defaultTime,
  });

  @override
  State<DialogBox> createState() => _DialogBoxState();
}

class _DialogBoxState extends State<DialogBox> {
  bool useAbsoluteTime = false; 
  DateTime? selectedAbsoluteTime; 
  
  int selectedNumber = 1;
  int selectedUnitIndex = 0;

  TimeOfDay selectedTime = TimeOfDay.now();

  final List<String> timeUnits = ["hour", "minute", "day", "week"];
  final List<String> categories = ["Main", "Life", "Personal", "Urgent"];

  @override
  void initState() {
    super.initState();
    widget.db.loadData(); // load categories
    category = widget.db.category[0];
    selectedDate = widget.defaultDate ?? DateTime.now();
    selectedTime = widget.defaultTime ?? TimeOfDay.now();
  }

  // Generate list based on what unit was selected
  List<int> getNumberRangeForUnit(String unit) {
    switch (unit) {
      case 'minute':
      case 'hour':
        return List.generate(60, (index) => index + 1); // 1–60
      case 'day':
        return List.generate(365, (index) => index + 1); // 1–365
      case 'week':
        return List.generate(52, (index) => index + 1); // 1–52
      default:
        return List.generate(60, (index) => index + 1);
    }
  }
  
  int? reminderValue;
  String? reminderUnit;

  String category = "Main";

  String selectedPriority = "None"; //default value
  
  DateTime selectedDate = DateTime.now();

  DateTime defaultDate = DateTime.now();
  TimeOfDay defaultTime = TimeOfDay.now();

  String? url;
  Color _getPriorityColor(String priority, BuildContext context) {
    switch (priority) {
      case "High":
        return Colors.red;
      case "Medium":
        return Colors.amber;
      case "Low":
        return Colors.lightBlue;
      case "None":
        return Colors.grey;
      default:
        return Theme.of(context).colorScheme.primary;
    }
  }

  //datepicker for user to select date of task
  // ignore: unused_element
  void _selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2010),
      lastDate: DateTime(2050),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).colorScheme.primary,
              surface: Theme.of(context).colorScheme.surface,
              onPrimary: Theme.of(context).colorScheme.onPrimary,
              onSecondary: Theme.of(context).colorScheme.onSecondary,
              onSurface: Theme.of(context).colorScheme.onSurface,
            ),
            textTheme: TextTheme(
              titleLarge: TextStyle(fontSize: 20),
              titleMedium: TextStyle(fontSize: 15),
              titleSmall: TextStyle(fontSize: 15),
            ),
          ),
          child: child!,
          );
      }
    );

    // If user picks a date, update the selectedDate
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<String?> _showAddCategoryDialog() async {
    String newCategory = '';
    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Add Category"),
          content: TextField(
            autofocus: true,
            decoration: InputDecoration(hintText: "Enter new category"),
            onChanged: (value) => newCategory = value,
          ),
          actions: [
            TextButton(
              child: Text("Cancel"),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: Text("Add"),
              onPressed: () => Navigator.pop(context, newCategory),
            ),
          ],
        );
      },
    );
  }

  RepeatInterval? repeatInterval;

  @override
  Widget build(BuildContext context) {
    String currentUnit = timeUnits[selectedUnitIndex];
    List<int> currentNumbers = getNumberRangeForUnit(currentUnit);
    if (selectedNumber > currentNumbers.length) {
      selectedNumber = currentNumbers.last;
    }

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title
              Row(
                children: [
                  Icon(Icons.edit_note, color: Theme.of(context).colorScheme.primary, size: 28),
                  const SizedBox(width: 8),
                  Text(
                    "New Task",
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Task Name Input
              TextField(
                controller: widget.controller,
                decoration: InputDecoration(
                  labelText: "What do you want to do?",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  prefixIcon: Icon(Icons.task_alt_rounded, color: Theme.of(context).colorScheme.primary),
                ),
                maxLines: null,
                keyboardType: TextInputType.multiline,
              ),
              const SizedBox(height: 14),

              // URL Input
              Stack(
                children: [
                  TextField(
                    controller: widget.urlController,
                    decoration: InputDecoration(
                      labelText: "Add a URL (Optional)",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      prefixIcon: Icon(Icons.link, color: Theme.of(context).colorScheme.primary),
                    ),
                    maxLines: null,
                    keyboardType: TextInputType.url,
                  ),
                  Positioned(
                    top: 0,
                    right: 6,
                    child: Text(
                      "*",
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ]
              ),
              const SizedBox(height: 14),

              // Row: Date, Priority, Reminder
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Priority Picker
                  Builder(
                    builder: (context) => IconButton(
                      icon: Icon(Icons.flag, color: _getPriorityColor(selectedPriority, context)),
                      tooltip: "Set Priority",
                      onPressed: () async {
                        final priority = await showPopover(
                          context: context,
                          bodyBuilder: (context) => PriorityItems(),
                          width: 200,
                          height: 200,
                          direction: PopoverDirection.top,
                          backgroundColor: Theme.of(context).colorScheme.secondary,
                          transitionDuration: Duration(milliseconds: 150),
                          barrierColor: Colors.transparent,
                          transition: PopoverTransition.other,
                        );
                        if (priority != null) {
                          setState(() {
                            selectedPriority = priority.toString();
                          });
                        }
                      },
                    ),
                  ),
                  // Reminder Picker
                  IconButton(
                    icon: Icon(Icons.alarm, color: Theme.of(context).colorScheme.primary),
                    tooltip: "Set Reminder",
                    onPressed: () async {
                      final result = await showDialog<Map<String, dynamic>>(
                        context: context,
                        builder: (context) => const Reminders(),
                      );
                      if (result != null) {
                        setState(() {
                          selectedDate = result['selectedDate'];
                          selectedTime = result['selectedTime'];
                          if (result['selectedReminder'] != null) {
                            selectedNumber = result['selectedReminder']['number'];
                            selectedUnitIndex = timeUnits.indexOf(result['selectedReminder']['unit']);
                            reminderValue = selectedNumber;
                            reminderUnit = timeUnits[selectedUnitIndex];
                          } else {
                            reminderValue = null;
                            reminderUnit = null;
                          }
                          repeatInterval = result['repeatInterval'];
                        });
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Category Dropdown
              Row(
                children: [
                  Icon(Icons.category, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: category,
                      onChanged: (String? newValue) async {
                        if (newValue == "Add new...") {
                          final newCategory = await _showAddCategoryDialog();
                          if (newCategory != null && newCategory.trim().isNotEmpty) {
                            final trimmed = newCategory.trim();
                            if (!widget.db.category.contains(trimmed)) {
                              setState(() {
                                widget.db.addCategory(trimmed);
                                category = trimmed;
                              });
                            } else {
                              setState(() {
                                category = trimmed;
                              });
                            }
                          }
                        } else {
                          setState(() {
                            category = newValue!;
                          });
                        }
                      },
                      decoration: InputDecoration(
                        labelText: "Category",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                      items: [
                        ...widget.db.category.map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        DropdownMenuItem<String>(
                          value: "Add new...",
                          child: Row(
                            children: const [
                              Icon(Icons.add, size: 18),
                              SizedBox(width: 5),
                              Text("Add new..."),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: widget.onCancel,
                    child: Text("Cancel", style: TextStyle(color: Theme.of(context).colorScheme.primary)),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    icon: Icon(Icons.save_alt_rounded),
                    label: Text("Save"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () {
                      final inputUrl = widget.urlController.text.trim();
                      widget.onSave(
                        selectedDate,
                        selectedPriority,
                        reminderValue,
                        reminderUnit,
                        selectedTime,
                        category,
                        defaultDate,
                        defaultTime,
                        inputUrl,
                        repeatInterval, // <-- add this
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
