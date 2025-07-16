import 'package:flutter/material.dart';
import 'package:popover/popover.dart';
import 'package:taskmanagement/components/task_info_card.dart';
import 'package:taskmanagement/data/database.dart';
import 'package:taskmanagement/widgets/priority_items.dart';
import 'package:taskmanagement/widgets/reminders.dart';

class TaskInfo extends StatefulWidget {
  final TextEditingController controller;
  final TextEditingController urlController;
  final String initialText;
  final String? initialUrl;
  final void Function(String updatedText, String updatedPriority, String taskURL, String updatedCategory,) onSave;
  final String initialPriority;
  final String initialCategory;
  final TaskDatabase db;

  const TaskInfo({
    super.key,
    required this.controller,
    required this.initialText,
    required this.onSave,
    required this.initialPriority,
    required this.urlController,
    required this.initialUrl,
    required this.initialCategory,
    required this.db,
  });

  @override
  State<TaskInfo> createState() => _TaskInfoState();
}

class _TaskInfoState extends State<TaskInfo> {
  // Priorities
  String selectedPriority = "None"; //default value
  
  String selectedCategory = "";

  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();

  DateTime defaultDate = DateTime.now();
  TimeOfDay defaultTime = TimeOfDay.now();

  int selectedNumber = 1;
  int selectedUnitIndex = 0;

  int? reminderValue;
  String? reminderUnit;

  final List<String> timeUnits = ["hour", "minute", "day", "week"];

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


  // Set controller to initial task text
  @override
  void initState() {
    super.initState();
    widget.controller.text = widget.initialText;
    widget.urlController.text = widget.initialUrl ?? '';
    selectedPriority = widget.initialPriority;
    selectedCategory = widget.initialCategory;
    selectedDate = defaultDate ?? DateTime.now();
    selectedTime = defaultTime ?? TimeOfDay.now();
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

  
  @override
Widget build(BuildContext context) {
  return SizedBox(
    child: Stack(
      children: [
        SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // Dropdown (centered)
              Padding(
                padding: const EdgeInsets.only(top: 15, left: 20, right: 20),
                child: SizedBox(
                  width: 200,
                  child: DropdownButtonFormField<String>(
                    value: selectedCategory,
                    onChanged: (String? newValue) async {
                      if (newValue == "Add new...") {
                        final newCategory = await _showAddCategoryDialog();
                        if (newCategory != null && newCategory.trim().isNotEmpty) {
                          final trimmed = newCategory.trim();
                          if (!widget.db.category.contains(trimmed)) {
                            setState(() {
                              widget.db.addCategory(trimmed);
                              selectedCategory = trimmed;
                            });
                          } else {
                            setState(() {
                              selectedCategory = trimmed;
                            });
                          }
                        }
                      } else {
                        setState(() {
                          selectedCategory = newValue!;
                        });
                      }
                    },
                    decoration: InputDecoration(
                      labelText: "Category",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
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
              ),
              // Text Field
              TaskInfoCard(
                icon: Icons.task_alt,
                title: "Task name",
                controller: widget.controller,
                hintText: "Enter task name...",
              ),
              // URL Field with red asterisk "optional" indicator
              Stack(
                children: [
                  TaskInfoCard(
                    icon: Icons.link,
                    title: "Url",
                    controller: widget.urlController,
                    hintText: "Enter a URL (optional)",
                  ),
                  Positioned(
                    top: 20,
                    right: 20,
                    child: Text(
                      "*",
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              // Reminder Edit Button
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 20.0),
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    foregroundColor: Theme.of(context).colorScheme.onSecondary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  ),
                  icon: const Icon(Icons.alarm),
                  label: Text(
                    reminderValue != null && reminderUnit != null
                      ? "Reminder: $reminderValue $reminderUnit${reminderValue! > 1 ? 's' : ''} before"
                      : "Set Reminder",
                    style: const TextStyle(fontSize: 15),
                  ),
                  onPressed: () async {
                    // Show the Reminders dialog
                    final result = await showDialog<Map<String, dynamic>>(
                      context: context,
                      builder: (context) => Reminders(),
                    );
                    if (result != null) {
                      setState(() {
                        // Update local state with new reminder info
                        selectedDate = result['selectedDate'] ?? selectedDate;
                        selectedTime = result['selectedTime'] ?? selectedTime;
                        reminderValue = result['selectedReminder']?['number'];
                        reminderUnit = result['selectedReminder']?['unit'];
                        // You can also store repeatInterval if you want
                      });
                    }
                  },
                ),
              ),
              // Show current reminder if set
              if (reminderValue != null && reminderUnit != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.alarm, color: Theme.of(context).colorScheme.primary, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            "Reminder: $reminderValue $reminderUnit${reminderValue! > 1 ? 's' : ''} before",
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            icon: Icon(Icons.clear, color: Colors.redAccent, size: 20),
                            tooltip: "Clear reminder",
                            onPressed: () {
                              setState(() {
                                reminderValue = null;
                                reminderUnit = null;
                              });
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.schedule, size: 18),
                          const SizedBox(width: 6),
                          Text(
                            "Due: ${selectedDate.toLocal().toString().split(' ')[0]} at ${selectedTime.format(context)}",
                            style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 80), // Space for the FAB
            ],
          ),
        ),
        // Priority Flag FAB (top right)
        Positioned(
          top: 16,
          left: 16,
          child: FloatingActionButton.small(
            heroTag: "priorityFlag",
            backgroundColor: Theme.of(context).colorScheme.surface,
            foregroundColor: _getPriorityColor(selectedPriority, context),
            elevation: 4,
            onPressed: () async {
              final priority = await showPopover(
                context: context,
                bodyBuilder: (context) => PriorityItems(),
                width: 200,
                height: 200,
                arrowDxOffset: -160,
                direction: PopoverDirection.top,
                backgroundColor: Theme.of(context).colorScheme.surface,
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
            child: Icon(
              Icons.flag,
              color: _getPriorityColor(selectedPriority, context),
            ),
          ),
        ),
        // Save FAB (bottom right)
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton.extended(
            heroTag: "saveBtn",
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
            elevation: 4,
            onPressed: () {
              widget.onSave(
                widget.controller.text,
                selectedPriority,
                widget.urlController.text,
                selectedCategory,
                // Optionally pass reminderValue, reminderUnit, selectedDate, selectedTime, etc.
              );
            },
            icon: const Icon(Icons.save),
            label: const Text(
              "Save",
              style: TextStyle(fontSize: 16),
            ),
          ),
        ),
      ],
    ),
  );
}

}
