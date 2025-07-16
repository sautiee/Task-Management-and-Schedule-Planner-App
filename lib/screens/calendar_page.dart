import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:intl/intl.dart';
import 'package:notifications/notifications.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:taskmanagement/data/database.dart';
import 'package:taskmanagement/services/tts_provider.dart';
import 'package:taskmanagement/widgets/calendar_tile.dart';
import 'package:taskmanagement/widgets/dialog_box.dart';
import 'package:taskmanagement/services/noti_service.dart';
import 'package:taskmanagement/widgets/streak_unlocked_dialog.dart';
import 'package:taskmanagement/widgets/task_info.dart';
import 'package:url_launcher/url_launcher.dart';

class CalendarPage extends StatefulWidget {

  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  // Firebase user
  final user = FirebaseAuth.instance.currentUser;

  // Initialize FlutterTts
  FlutterTts _flutterTts = FlutterTts();
  Map? _currentVoice;

  // Show completed tasks toggle
  bool _showCompletedTasks = true;
  
  // Notification Listener
  Notifications? _notifications;
  StreamSubscription<NotificationEvent>? _subscription;
  List<NotificationEvent> _log = [];
  bool started = false;
  
  // Initialize SpeechToText
  SpeechToText _speechToText = SpeechToText();
  bool _isListening = false;
  String _lastWords = "";
  
  // Initialize NotiService
  final NotiService _notiService = NotiService();

  // Text controllers
  final _textController = TextEditingController();
  final _urlController = TextEditingController();

  // Reference HIVE box
  final _box1 = Hive.box('box1');
  final _box2 = Hive.box('box2');
  final _box3 = Hive.box('box3');
  final _box4 = Hive.box('box4');
  
  // INIT: when app runs, we need to do a couple of checks.
  @override
  void initState() {

    //first time opening app -> create default data
    if (_box1.get("TASKLIST") == null) { //means this is the first time opening the app (no data stored)
      db.createInitialData();
    }
    else {
      //data already exists
      db.loadData();
    }

    if(_box2.get("CURRENCY") == null) {
      db2.createInitialData();
    }
    else {
      //data already exists
      db2.loadCurrency();
    }

    super.initState();

    // INIT NOTIS
    _notiService.initNotification();

    // INIT SPEECH-TO-TEXT
    _speechToText = SpeechToText();
    _initSpeech();

    // INIT TTS
    initTTS();
  }

  // INIT TTS
  void initTTS() async {
    try {
      var data = await _flutterTts.getVoices;
      List<Map> _voices = List<Map>.from(data);
      _voices = _voices.where((voice) => voice['name'].toString().contains('en-US')).toList();

      setState(() {
        _currentVoice = _voices.first; 
        setVoice(_currentVoice!);
      });
    } catch (e) {
      print("Error initializing TTS: $e");
    }
  }

  void setVoice(Map voice) {
    _flutterTts.setVoice({"name": voice["name"], "locale": voice["locale"]});
  }

  // Databases
  TaskDatabase db = TaskDatabase();
  Currency db2 = Currency();
  TasksCompleted db3 = TasksCompleted();
  
  // Change checkbox state
  void checkBoxChanged(bool? value, int index) async {
    bool isChecked = !db.taskList[index][1];
    bool rewardGiven = db.taskList[index][4];

    if (isChecked && !rewardGiven) {
      //get current value from database
      int currentAmount = _box2.get("CURRENCY", defaultValue: 0);
      int newAmount = currentAmount + 50;
      int earned = 50;

      switch (db.taskList[index][3]) {
        case 'High':
          newAmount += 50;
          earned += 50;
          break;
        case 'Medium':
          newAmount += 30;
          earned += 30;
          break;
        case 'Low':
          newAmount += 15;
          earned += 15;
          break;
        default:
          break;
      }

      //update the currency
      _box2.put("CURRENCY", newAmount);

      setState(() {
        db.taskList[index][4] = true;
      });
    }

    // Increment tasks completed counter if marking as completed
    if (isChecked && !db.taskList[index][1] && !rewardGiven) {
      int completedCount = _box3.get("TASKS_COMPLETED", defaultValue: 0);
      _box3.put("TASKS_COMPLETED", completedCount + 1);

      // XP and Level up logic
      int xp = _box4.get("XP", defaultValue: 0);
      int level = _box4.get("LEVEL", defaultValue: 1);
      const int xpPerTask = 40;
      const int xpToLevelUp = 100;

      xp += xpPerTask;

      // Carry over extra XP and allow for multiple level-ups if needed
      while (xp >= xpToLevelUp) {
        xp -= xpToLevelUp;
        level += 1;
      }
      _box4.put("LEVEL", level);
      _box4.put("XP", xp);

      // Streak logic
      int streak = _box3.get("STREAK", defaultValue: 0);
      String? lastDateStr = _box3.get("LAST_COMPLETED_DATE");
      DateTime? lastDate = lastDateStr != null ? DateTime.parse(lastDateStr) : null;
      DateTime today = DateTime.now();

      // Only count the date part (ignore time)
      DateTime todayDate = DateTime(today.year, today.month, today.day);

      if (lastDate != null) {
        DateTime lastDateOnly = DateTime(lastDate.year, lastDate.month, lastDate.day);
        if (todayDate.difference(lastDateOnly).inDays == 1) {
          // Consecutive day, increment streak
          streak += 1;
        } else if (todayDate.difference(lastDateOnly).inDays > 1) {
          // Missed a day, reset streak
          streak = 1;
        } // If same day, don't increment streak again
      } else {
        // First task ever completed
        streak = 1;
      }

      // Only update streak if this is the first task completed today
      if (lastDate == null || todayDate.difference(DateTime(lastDate.year, lastDate.month, lastDate.day)).inDays != 0) {
        _box3.put("STREAK", streak);
        _box3.put("LAST_COMPLETED_DATE", todayDate.toIso8601String());

        // Show streak unlocked dialog if streak == 1
        if (streak == 1) {
          await showStreakUnlockedDialog(context);
        }
      }
    }

    setState(() {
      db.taskList[index][1] = !db.taskList[index][1];
    });

    db.updateDatabase();
  }
  
  // Utility functions to conver TimeOfDay to String and vice versa 
  String timeOfDayToString(TimeOfDay time) {
  return "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
  }

  TimeOfDay stringToTimeOfDay(String timeString) {
    final parts = timeString.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  final player = AudioPlayer();

  Future<void> playSound() async {
    try {
      String audioPath = "audios/task-created.mp3";
      await player.play(AssetSource(audioPath));
    } catch (e) {
      print("Audio error: $e");
    }
  }

  // Save new task
  void saveNewTask(
  DateTime selectedDate,
  String priority,
  int? reminderValue,
  String? reminderUnit,
  TimeOfDay selectedTime,
  String category,
  DateTime defaultDate,
  TimeOfDay defaultTime,
  String? taskURL,
  RepeatInterval? repeatInterval,
) async {
    final notiService = NotiService();
    final taskText = _textController.text;
    final urlText = _urlController.text.trim();
    final String? safeURL = urlText.isEmpty ? null : urlText;
  
    
    // Don't proceed if the task is empty
    if (taskText.trim().isEmpty) return;

    // Combine date and time into DateTime object
    final scheduledTime = DateTime(
      //
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedTime.hour,
      selectedTime.minute,
    );

    // reminder offset
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

    // Unique id
    final notificationId = UniqueKey().hashCode;
    
    setState(() {
      db.taskList.add([
        taskText,
        false,
        selectedDate,
        priority,
        false, //reward given?
        timeOfDayToString(selectedTime), // store the selected time
        category, //store the categoty
        safeURL,
        notificationId,
      ]);
      _textController.clear();
    });
      print("Saved URL: $urlText");

    // Schedule future reminder
    if (scheduledTime.isAfter(DateTime.now()) && reminderValue != null && reminderUnit != null) {
      if (repeatInterval != null) {
        await notiService.scheduleRecurringReminder(
          id: notificationId,
          title: taskText,
          body: "Reminder: $taskText is due soon!",
          scheduledTime: reminderTime,
          repeatInterval: repeatInterval,
        );
      } else {
        await notiService.scheduleReminder(
          id: notificationId,
          title: taskText,
          body: "Reminder: $taskText is due soon!",
          scheduledTime: reminderTime,
        );
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Reminder scheduled for ${reminderTime.toLocal()}${repeatInterval != null ? " (recurring)" : ""}'),
          duration: Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
    }

    // TTS after saving the task
    final ttsEnabled = Provider.of<TtsProvider>(context, listen: false).ttsEnabled;
    if (ttsEnabled) {
      String ttsMessage = "Task '$taskText' saved successfully.";
      if (reminderValue != null && reminderUnit != null) {
        final reminderTimeString = DateFormat('EEEE, MMM d, h:mm a').format(reminderTime);
        ttsMessage += " Reminder set for $reminderTimeString.";
      }
      await _flutterTts.speak(ttsMessage);
    }

    Navigator.of(context).pop();
    db.updateDatabase();

    playSound(); // Play sound after saving the task 
  }

  // Seperate function to save a task from speech
  void saveNewTaskFromSpeech(String taskName, DateTime? dateTime) async {
    final dueDate = dateTime ?? DateTime.now();
    final dueTime = TimeOfDay.fromDateTime(dueDate);
    final formattedTime = timeOfDayToString(dueTime);
    final taskURL = ''; 

    final notificationId = UniqueKey().hashCode;

    setState(() {
      db.taskList.add([
        taskName,
        false,
        dueDate,
        'Normal',     // priority
        false,        // reward given
        formattedTime,
        'Main',       // category
        taskURL,
        notificationId,
      ]);
      _textController.clear();
    });

    db.updateDatabase();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Task "$taskName" saved from speech')),
    );

    // Schedule future reminder
    if (dateTime != null && dateTime.isAfter(DateTime.now())) {
      final int notificationId = UniqueKey().hashCode;
      await _notiService.scheduleReminder(
        id: notificationId,
        title: taskName,
        body: "Reminder: $taskName is due soon!",
        scheduledTime: dateTime,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Reminder scheduled for ${dateTime.toLocal()}'),
          duration: Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
    }

    // TTS after saving the task
    final ttsEnabled = Provider.of<TtsProvider>(context, listen: false).ttsEnabled;
    if (ttsEnabled) {
      String ttsMessage = "Task '$taskName' saved successfully.";
      if (dateTime != null && dateTime.isAfter(DateTime.now())) {
        final reminderTimeString = DateFormat('EEEE, MMM d, h:mm a').format(dateTime);
        ttsMessage += " Reminder set for $reminderTimeString.";
      }
      await _flutterTts.speak(ttsMessage);
    }
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch the app or URL.')),
      );
    }
  }

  String? checkUrl(String? input) {
    if (input == null) return null;

    final trimmed = input.trim();
    if (trimmed.startsWith('https://')) {
      return trimmed;
    }
    return null; // Set invalid url to null
  }

  void cancelDialogBox() {
    setState(() {
      _textController.clear();
    });
    Navigator.of(context).pop();
  }

  // Create new task
  void createNewTask(){
    _textController.clear();
    _urlController.clear();
    showModalBottomSheet(
      barrierColor: const Color.fromARGB(106, 62, 62, 62),
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(15), topRight: Radius.circular(15))
      ),
      sheetAnimationStyle: AnimationStyle(duration: Duration(milliseconds: 250)),
      context: context,
      builder: (context){
        final url = _urlController.text;
        final defaultDate = _speechDetectedDateTime?.toLocal() ?? DateTime.now();
        final defaultTime = _speechDetectedDateTime != null
          ? TimeOfDay.fromDateTime(_speechDetectedDateTime!)
          : TimeOfDay.now();
        
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom), //Makes the modal sheet move up with the keyboard
          child: SizedBox(
            height: 450,
            child: DialogBox(
              controller: _textController,
              onSave: saveNewTask,
              onCancel: cancelDialogBox, //dismisses the box
              db: db,
              defaultDate: defaultDate,
              defaultTime: defaultTime,
              urlController: _urlController,
            ),
          ),
        );
      }
    );
  }

  // Delete task 
  void deleteTask(int index) {
    final taskName = db.taskList[index][0];
    final notificationId = db.taskList[index][8];

    if (notificationId != null) {
      _notiService.cancelNotification(notificationId);
    }
    setState(() {
      db.taskList.removeAt(index);
    });
    db.updateDatabase();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Task "$taskName" deleted',
        style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  /// INIT speech to text
  void _initSpeech() async {
    _isListening = await _speechToText.initialize();
    setState(() {
      _isListening = false;
    });
  }

  /// Start speech recognition session
  void _startListening() async {
    if (_isListening = false) {
      bool available = await _speechToText.initialize(
        onStatus: (status) => print('Speech status: $status'),
        onError: (error) => print('Speech error: $error'),
      );

      if (!available) {
        setState(() => _isListening = true);
        _speechToText.listen(
          onResult: (val) => setState(() {
            _lastWords = val.recognizedWords;
          }),
        );
      } else {
        setState(() => _isListening = false);
        _speechToText.stop();
      }
    }


    await _speechToText.listen(onResult: _onSpeechResult);
    setState(() {
      _isListening = true;
    });
  }

  /// Stop speech services manually
  void _stopListening() async {
    await _speechToText.stop();
    setState(() {
      _isListening = false;
      _lastWords = '';
    });
  }

  DateTime? parseNaturalDate(String text) {
    final now = DateTime.now();
    final lower = text.toLowerCase();

    // Check for "tomorrow"
    if (lower.contains("tomorrow")) {
      return DateTime(now.year, now.month, now.day + 1);
    }

    // Check for days of week
    final days = {
      "monday": DateTime.monday,
      "tuesday": DateTime.tuesday,
      "wednesday": DateTime.wednesday,
      "thursday": DateTime.thursday,
      "friday": DateTime.friday,
      "saturday": DateTime.saturday,
      "sunday": DateTime.sunday,
    };

    for (final day in days.entries) {
      if (lower.contains("on ${day.key}")) {
        int today = now.weekday;
        int target = day.value;
        int diff = (target - today) % 7;
        return now.add(Duration(days: diff == 0 ? 7 : diff));
      }
    }

      return null; // fallback
    }

  TimeOfDay? parseTimeOfDay(String text) {
    // Allow am/pm with or without dots, case insensitive
    final timeReg = RegExp(
      r'\b(\d{1,2})(?::(\d{2}))?\s?(a\.?m\.?|p\.?m\.?)?\b',
      caseSensitive: false,
    );

    final match = timeReg.firstMatch(text);

    if (match != null) {
      int hour = int.parse(match.group(1)!);
      int minute = match.group(2) != null ? int.parse(match.group(2)!) : 0;
      String? periodRaw = match.group(3);

      if (periodRaw != null) {
        String period = periodRaw.replaceAll('.', '').toLowerCase(); // normalize "a.m." => "am"
        if (period == 'pm' && hour < 12) hour += 12;
        if (period == 'am' && hour == 12) hour = 0;
      }

      return TimeOfDay(hour: hour, minute: minute);
    }
    return null;
  }

  
  String? extractDateTimePhrase(String input) {
    // Absolute time (e.g., "at 5pm", "at 14:30", "at 7 am on Monday")
    final absoluteTimeReg = RegExp(
      r'(at\s+\d{1,2}(?::\d{2})?\s*(a\.?m\.?|p\.?m\.)?(\s+on\s+\w+)?\s*(tomorrow|today|on\s+\w+)?\b)',
      caseSensitive: false,
    );

    // Relative reminder (e.g., "in 10 minutes", "after 2 hours", "remind me in 1 day and 3 hours")
    final reminderRegExp = RegExp(
      r'(?:(?:remind me|set a reminder)\s*)?(?:in|after|for)?\s*((?:(?:\d+|one|two|three|four|five|six|seven|eight|nine|ten|eleven|twelve)\s*(?:minute|minutes|hour|hours|day|days|week|weeks)\s*(?:and\s*)?)*)',
      caseSensitive: false,
    );
    

    // Try absolute time first
    final absoluteMatch = absoluteTimeReg.firstMatch(input);
    if (absoluteMatch != null && absoluteMatch.group(0) != null && absoluteMatch.group(0)!.trim().isNotEmpty) {
      return absoluteMatch.group(0);
    }

    // Try relative reminder
    final reminderMatch = reminderRegExp.firstMatch(input);
    if (reminderMatch != null && reminderMatch.group(0) != null && reminderMatch.group(0)!.trim().isNotEmpty) {
      return reminderMatch.group(0);
    }

    // No match
    return null;
  }

  DateTime? _speechDetectedDateTime;

  /// Callback for recognized words
  void _onSpeechResult(SpeechRecognitionResult result) {
  final rawText = result.recognizedWords;

  setState(() {
    _lastWords = "${result.recognizedWords}";
  });

  if (result.finalResult) {
    _stopListening();
    _isListening = false; // <-- Make sure this is set BEFORE closing the dialog

    final dateTimePhrase = extractDateTimePhrase(rawText);
    DateTime? scheduledDateTime;

    if (dateTimePhrase != null) {
      final phraseLower = dateTimePhrase.toLowerCase();

      if (phraseLower.startsWith('at')) {
        DateTime? parsedDate = parseNaturalDate(dateTimePhrase);
        TimeOfDay? parsedTime = parseTimeOfDay(dateTimePhrase);

        parsedDate ??= DateTime.now();
        parsedTime ??= TimeOfDay.now();

        scheduledDateTime = DateTime(
          parsedDate.year,
          parsedDate.month,
          parsedDate.day,
          parsedTime.hour,
          parsedTime.minute,
        );
      } else {
        scheduledDateTime = _parseRelativeReminder(dateTimePhrase);
      }
    }

    scheduledDateTime ??= DateTime.now();

    // Remove "remind me to", "set a reminder to", etc.
    String commandlessText = cleanSpeechCommand(rawText);

    // Remove the date/time phrase if present
    final cleanedText = dateTimePhrase != null
        ? commandlessText.replaceAll(dateTimePhrase, '').trim()
        : commandlessText;

    final capitalizedText = cleanedText.isNotEmpty
        ? cleanedText[0].toUpperCase() + cleanedText.substring(1)
        : '';

    if (!mounted) return;
    setState(() {
      _textController.text = capitalizedText;
      _speechDetectedDateTime = scheduledDateTime;
    });

    // Pop bottom modal sheet
    Future.delayed(Duration(milliseconds: 300), () {
      if (mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    });

    saveNewTaskFromSpeech(capitalizedText, scheduledDateTime);
    _isListening = false; // Reset listening state
  }
}

  // Helper to parse relative reminders like "in 10 minutes", "after 2 hours"
  DateTime _parseRelativeReminder(String phrase) {
    final now = DateTime.now();
    final reg = RegExp(
      r'(\d+|one|two|three|four|five|six|seven|eight|nine|ten|eleven|twelve)\s*(minute|minutes|hour|hours|day|days|week|weeks)',
      caseSensitive: false,
    );
    final numberWords = {
      'one': 1, 'two': 2, 'three': 3, 'four': 4, 'five': 5,
      'six': 6, 'seven': 7, 'eight': 8, 'nine': 9, 'ten': 10,
      'eleven': 11, 'twelve': 12,
    };

    int totalMinutes = 0;
    for (final match in reg.allMatches(phrase)) {
      String numStr = match.group(1)!.toLowerCase();
      int value = int.tryParse(numStr) ?? numberWords[numStr] ?? 0;
      String unit = match.group(2)!.toLowerCase();
      if (unit.startsWith('minute')) totalMinutes += value;
      if (unit.startsWith('hour')) totalMinutes += value * 60;
      if (unit.startsWith('day')) totalMinutes += value * 60 * 24;
      if (unit.startsWith('week')) totalMinutes += value * 60 * 24 * 7;
    }
    return now.add(Duration(minutes: totalMinutes > 0 ? totalMinutes : 1));
  }

  String cleanSpeechCommand(String input) {
    final patterns = [
      RegExp(r'^\s*remind me to\s*', caseSensitive: false),
      RegExp(r'^\s*remind me\s*', caseSensitive: false),
      RegExp(r'^\s*set a reminder to\s*', caseSensitive: false),
      RegExp(r'^\s*set a reminder\s*', caseSensitive: false),
      RegExp(r'^\s*reminder to\s*', caseSensitive: false),
      RegExp(r'^\s*reminder\s*', caseSensitive: false),
      RegExp(r'^\s*to\s*', caseSensitive: false),
    ];
    String result = input.trim();
    for (final pattern in patterns) {
      result = result.replaceFirst(pattern, '');
    }
    return result.trim();
  }

  void showSpeechModal() {
  // Start listening before showing the dialog
  if (!_speechToText.isListening) {
    _speechToText.listen(
      onResult: (result) {
        setState(() {
          _lastWords = result.recognizedWords;
        });

        if (result.finalResult) {
          _onSpeechResult(result);
        }
      },
    );
  }

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Theme.of(context).colorScheme.surface,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.mic, size: 40, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 12),
            Text(
              _speechToText.isListening ? "Listening..." : "Processing...",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                _stopListening();
                Navigator.of(context).pop();
              },
              child: Text("Cancel"),
            ),
          ],
        ),
      );
    },
  );
}

  String selectedCategory = "Main";
  
  DateTime today = DateTime.now(); // default value

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    startListening();
  }

  void onData(NotificationEvent event) {
    setState(() {
      _log.add(event);
    });
    print(event.toString());
  }

  void startListening() {
    _notifications = Notifications();
    try {
      _subscription = _notifications!.notificationStream!.listen(onData);
      setState(() => started = true);
      print("Listening to notifications...");
    } on NotificationException catch (exception) {
      print(exception);
    }
  }

  void stopListening() {
    _subscription?.cancel();
    setState(() => started = false);
    print("Stopped listening to notifications.");
  }
  
  void _onDaySelected(DateTime day, DateTime focusedDay) {
    setState(() {
      today = day;
    });
  }

  //to show tasks for selected day
  List taskListForDay(DateTime day) {
    return db.taskList.where((task) => isSameDay(task[2], day) && task[1] == false).toList();
  }

  // Get events for day
  List<Map<String, dynamic>> _getEventsForDay(DateTime day) {
    return db.taskList
        .where((task) => isSameDay(task[2], day) && !task[1])
        .map((task) => {
              'task': task,
              'overdue': isTaskOverdue(task),
            })
        .toList();
  }

  // Overdue tasks
  bool isTaskOverdue(List task) {
    final DateTime dueDate = task[2];
    final TimeOfDay dueTime = stringToTimeOfDay(task[5]);
    final DateTime dueDateTime = DateTime(
      dueDate.year, dueDate.month, dueDate.day, dueTime.hour, dueTime.minute,
    );
    return !task[1] && dueDateTime.isBefore(DateTime.now());
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Theme.of(context).colorScheme.surface,
    floatingActionButton: FloatingActionButton(
      backgroundColor: Theme.of(context).colorScheme.primary,
      foregroundColor: Theme.of(context).colorScheme.onPrimary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      onPressed: createNewTask,
      child: Icon(Icons.add, size: 28),
      elevation: 6,
    ),
    body: Column(
      children: [
        // Calendar Card
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
          child: Material(
            elevation: 2.5,
            borderRadius: BorderRadius.circular(18),
            color: Theme.of(context).colorScheme.secondary,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: TableCalendar(
                eventLoader: (day) => _getEventsForDay(day),
                locale: "en_US",
                rowHeight: 48,
                headerStyle: HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  titleTextStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  leftChevronIcon: Icon(Icons.chevron_left, color: Theme.of(context).colorScheme.primary),
                  rightChevronIcon: Icon(Icons.chevron_right, color: Theme.of(context).colorScheme.primary),
                ),
                availableGestures: AvailableGestures.all,
                selectedDayPredicate: (day) => isSameDay(day, today),
                calendarStyle: CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  markerDecoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  markerMargin: EdgeInsets.only(top: 5, left: 2),
                  markerSize: 6,
                  markersMaxCount: 3,
                  weekendTextStyle: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                  ),
                  outsideDaysVisible: false,
                ),
                focusedDay: today,
                firstDay: DateTime(2010),
                lastDay: DateTime(2050),
                onDaySelected: _onDaySelected,
              ),
            ),
          ),
        ),
        // Section Title
        Padding(
          padding: const EdgeInsets.only(top: 8, left: 18, bottom: 2),
          child: Row(
            children: [
              Icon(Icons.task_alt, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                'Due tasks:',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${taskListForDay(today).length}',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        // Task List
        Expanded(
          child: taskListForDay(today).isEmpty
              ? Center(
                  // ...empty state...
                )
              : Column(
                  children: taskListForDay(today)
                      .asMap()
                      .entries
                      .map((entry) {
                        int index = db.taskList.indexOf(entry.value);
                        var task = entry.value;
                        return AnimatedSwitcher(
                          duration: Duration(milliseconds: 100),
                          child: GestureDetector(
                            key: ValueKey(task),
                            child: CalendarTile(
                              taskName: task[0],
                              taskCompleted: task[1],
                              date: task[2],
                              time: task[5],
                              onTap: () {
                                final taskText = db.taskList[index][0];
                                final priorityLevel = db.taskList[index][3];
                                final taskURL = db.taskList[index][7];
                                final category = db.taskList[index][6];

                                showModalBottomSheet(
                                  barrierColor: const Color.fromARGB(65, 62, 62, 62),
                                  backgroundColor: Theme.of(context).colorScheme.secondary,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                  context: context,
                                  builder: (context) {
                                    return Padding(
                                      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                                      child: SizedBox(
                                        height: 420,
                                        child: TaskInfo(
                                          controller: _textController,
                                          db: db,
                                          initialText: taskText,
                                          initialPriority: priorityLevel,
                                          initialUrl: taskURL,
                                          initialCategory: category,
                                          urlController: _urlController,
                                          onSave: (updatedText, updatedPriority, updatedUrl, updatedCategory) {
                                            setState(() {
                                              db.taskList[index][0] = updatedText;
                                              db.taskList[index][3] = updatedPriority;
                                              db.taskList[index][7] = updatedUrl;
                                              db.taskList[index][6] = updatedCategory;
                                            });
                                            db.updateDatabase();
                                            Navigator.of(context).pop();
                                            _textController.clear();
                                          },
                                        ),
                                      ),
                                    );
                                  }
                                );
                              },
                              onCheck: () {
                                checkBoxChanged(!task[1], index);
                              },
                            ),
                          ),
                        );
                      })
                      .toList(),
                ),
        ),
      ],
    ),
  );
}
}