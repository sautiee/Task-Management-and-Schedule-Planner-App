import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class TaskDatabase {

  List taskList = [];
  List priority = ["None", "Low", "Medium", "High"];
  List<String> category = ["Main", "Uni", "Other"];
  String? url = ' ';
  final notificationId = 0;
  int? reminderValue = 0;
  String? reminderUnit = "None";

  String formatTimeOfDay(TimeOfDay time) {
    final hours = time.hour.toString().padLeft(2, '0');
    final minutes = time.minute.toString().padLeft(2, '0');
    return '$hours:$minutes';
  }

  DateTime now = DateTime.now();
  //reference hive box
  final _box1 = Hive.box('box1');

  //run method if first time ever opening app
  void createInitialData() {
    category = ["Main", "University", "Other"];;
    String formattedTime = formatTimeOfDay(TimeOfDay.now());

    taskList = [
      [ 
        "Welcome", // task text
        false, // is completed?
        now, // date
        priority[0], // priority level
        false, // reward given?
        formattedTime, // time
        category[0], //category
        url, // url
        notificationId, // notification ID
        reminderValue,
        reminderUnit,
      ],

      [
        "Finish Project",
        false,
        now,
        priority[0],
        false,
        formattedTime,
        category[0],
        "https://elearning.yu.edu.jo",
        notificationId,
        reminderValue,
        reminderUnit,
      ],
    ];

    updateDatabase();
  }

  //load data from db
  void loadData() {
    taskList = _box1.get("TASKLIST"); //key value pair
    category = _box1.get("CATEGORIES", defaultValue: ["Main"]).cast<String>();
  }

  //update dbs
  void updateDatabase() {
    _box1.put("TASKLIST", taskList);
    _box1.put("CATEGORIES", category);
  }

  //add new category
  void addCategory(String newCat) {
    if (!category.contains(newCat.trim())) {
      category.add(newCat.trim());
      _box1.put("CATEGORIES", category);
    }
  }
}

class Currency {

  int currencyAmount = 0;

  final _box2 = Hive.box('box2');

  //initialize data on app start (for the first time)
  void createInitialData() {
    currencyAmount = 0;
    _box2.put("CURRENCY", currencyAmount);
  }

  //load already existing currency amount
  void loadCurrency() {
    currencyAmount = _box2.get("CURRENCY"); //key value pair
  }

  //update db with new currency amount
  void updateCurrency(int newAmount) {
    currencyAmount = newAmount;
    _box2.put("CURRENCY", currencyAmount);
  }

  //getter method
  int get currentAmount => currencyAmount;
}

class TasksCompleted {

  int tasksCompleted = 0;

  // Streak
  int streak = 0;
  DateTime? lastCompletedDate;

  final _box3 = Hive.box('box3');

  //initialize data on app start (for the first time)
  void createInitialData() {
    tasksCompleted = 0;
    streak = 0;
    lastCompletedDate = null;
    _box3.put("TASKS_COMPLETED", tasksCompleted);
    _box3.put("STREAK", streak);
    _box3.put("LAST_COMPLETED_DATE", null);
  }

  //load already existing tasks completed
  void loadTasksCompleted() {
    tasksCompleted = _box3.get("TASKS_COMPLETED"); //key value pair
  }

  // Load streak and last completed date
  void loadStreak() {
    streak = _box3.get("STREAK", defaultValue: 0);
    final millis = _box3.get("LAST_COMPLETED_DATE");
    lastCompletedDate = millis != null ? DateTime.parse(millis) : null;
  }

  //update db with new tasks completed amount
  void updateTasksCompleted(int newAmount) {
    tasksCompleted = newAmount;
    _box3.put("TASKS_COMPLETED", tasksCompleted);
  }
  
  // Update streak and last completed date
  void updateStreak(int newStreak, DateTime? date) {
    streak = newStreak;
    lastCompletedDate = date;
    _box3.put("STREAK", streak);
    _box3.put("LAST_COMPLETED_DATE", date?.toIso8601String());
  }

  //getter methods
  int get currentAmount => tasksCompleted;
  int get currentStreak => streak;
  DateTime? get lastDate => lastCompletedDate;
}

class UserStats {
  int xp = 0;
  int level = 1;

  final _box4 = Hive.box('box4');

  void createInitialData() {
    xp = 0;
    level = 1;
    _box4.put("XP", xp);
    _box4.put("LEVEL", level);
  }

  void loadStats() {
    xp = _box4.get("XP", defaultValue: 0);
    level = _box4.get("LEVEL", defaultValue: 1);
  }

  void updateXP(int newXP) {
    xp = newXP;
    _box4.put("XP", xp);
  }

  void updateLevel(int newLevel) {
    level = newLevel;
    _box4.put("LEVEL", level);
  }

  int get currentXP => xp;
  int get currentLevel => level;
}