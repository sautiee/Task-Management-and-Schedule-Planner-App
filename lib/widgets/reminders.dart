import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:taskmanagement/widgets/reminders_dialog.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart' show RepeatInterval;

class Reminders extends StatefulWidget {
  const Reminders({super.key});

  @override
  State<Reminders> createState() => _RemindersState();
}

class _RemindersState extends State<Reminders> {
  bool useAbsoluteTime = false; 
  DateTime? selectedAbsoluteTime; 
  
  int selectedNumber = 1;
  int selectedUnitIndex = 0;

  TimeOfDay selectedTime = TimeOfDay.now();

  DateTime selectedDate = DateTime.now();

  final List<String> timeUnits = ["hour", "minute", "day", "week"];

  RepeatInterval? _repeatInterval;
  
  bool reminderEnabled = false;

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

  // ignore: body_might_complete_normally_nullable
  Future<DateTime?> _selectDate() async {
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

  @override
  Widget build(BuildContext context) {
    String currentUnit = timeUnits[selectedUnitIndex];
    List<int> currentNumbers = getNumberRangeForUnit(currentUnit);

    if (selectedNumber > currentNumbers.length) {
      selectedNumber = currentNumbers.last;
    }

    String timeSelected =
        "$selectedNumber $currentUnit${selectedNumber > 1 ? 's' : ''}";

    String timeText = "${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}";
    String reminderTimeText = "$timeSelected before";

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Theme.of(context).colorScheme.surface,
      title: Row(
        children: [
          Icon(Icons.alarm, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            "Set Reminder",
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
      content: SizedBox(
        width: 380, // <-- Set your desired width here
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Date
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Theme.of(context).colorScheme.secondary,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () async {
                    final DateTime? pickedDate = await _selectDate();
                    if (pickedDate != null) {
                      setState(() {
                        selectedDate = pickedDate;
                      });
                    }
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.calendar_month, size: 22, color: Theme.of(context).colorScheme.primary),
                          SizedBox(width: 8),
                          Text(
                            "Date:",
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSecondary,
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 17,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Time
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Theme.of(context).colorScheme.secondary,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () async {
                    final TimeOfDay? timeOfDay = await showTimePicker(
                      context: context,
                      initialTime: selectedTime,
                      initialEntryMode: TimePickerEntryMode.dial,
                    );
                    if (timeOfDay != null) {
                      setState(() {
                        selectedTime = timeOfDay;
                      });
                    }
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.watch_later, size: 22, color: Theme.of(context).colorScheme.primary),
                          SizedBox(width: 8),
                          Text(
                            "Time:",
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSecondary,
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        timeText,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 17,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Reminders
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Theme.of(context).colorScheme.secondary,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () async {
                    final result = await showDialog<Map<String, dynamic>>(
                      context: context,
                      builder: (context) => RemindersDialog(
                        initialNumber: selectedNumber,
                        initialUnitIndex: selectedUnitIndex,
                        timeUnits: timeUnits,
                        getNumberRangeForUnit: getNumberRangeForUnit,
                      ),
                    );

                    if (result != null && result['cleared'] == true) {
                      setState(() {
                        reminderEnabled = false;
                      });
                    } else if (result != null) {
                      setState(() {
                        selectedNumber = result['number'];
                        selectedUnitIndex = result['unitIndex'];
                        reminderEnabled = true;
                      });
                    }
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.alarm, size: 22, color: Theme.of(context).colorScheme.primary),
                          SizedBox(width: 8),
                          Text(
                            "Reminder:",
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSecondary,
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        reminderEnabled ? reminderTimeText : "None",
                        style: TextStyle(
                          color: reminderEnabled
                              ? Theme.of(context).colorScheme.primary
                              : Colors.grey,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Repeat Interval
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Theme.of(context).colorScheme.secondary,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: DropdownButtonFormField<RepeatInterval>(
                  dropdownColor: Theme.of(context).colorScheme.secondary,
                  borderRadius: BorderRadius.circular(15),
                  icon: Icon(Icons.repeat, color: Theme.of(context).colorScheme.primary),
                  value: _repeatInterval,
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 1.3),
                    ),
                    labelText: "Repeat",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: [
                    DropdownMenuItem(
                      value: null,
                      child: Text("No repeat"),
                    ),
                    DropdownMenuItem(
                      value: RepeatInterval.daily,
                      child: Text("Daily"),
                    ),
                    DropdownMenuItem(
                      value: RepeatInterval.weekly,
                      child: Text("Weekly"),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _repeatInterval = value;
                    });
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          child: Text(
            "Cancel",
            style: TextStyle(fontSize: 15),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        ElevatedButton(
          child: Text("OK"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onPressed: () => Navigator.of(context).pop(
            {
              'selectedDate': selectedDate,
              'selectedTime': selectedTime,
              'selectedReminder': {
                'number': selectedNumber,
                'unit': timeUnits[selectedUnitIndex],
              },
              'repeatInterval': _repeatInterval,
            },
          ),
        ),
      ],
    );
  }
}
