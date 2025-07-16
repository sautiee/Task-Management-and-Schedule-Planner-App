import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ThemeModel extends ChangeNotifier {
  final List<List<String>> _themeItems = [
    ["Blue", "100", "assets/images/blueTheme.png"],
    ["Dark", "100", "assets/images/darkTheme.png"],
    ["Purple", "250", "assets/images/purpleTheme.png"],
    ["Green", "250", "assets/images/greenTheme.png"],
    ["Red", "250", "assets/images/redTheme.png"],
    ["Pink", "250", "assets/images/pinkTheme.png"],
  ];

  final _box = Hive.box("box3");

  String currentThemeName = 'Blue';
  Set<String> boughtThemes = {'Blue'};

  ThemeModel() {
    _loadData();
  }

  void _loadData() {
    final List<dynamic>? storedBoughtThemes = _box.get('BOUGHT_THEMES');
    final String? storedCurrentTheme = _box.get('CURRENT_THEME');

    if (storedBoughtThemes != null) {
      boughtThemes = Set<String>.from(storedBoughtThemes);
    }

    if (storedCurrentTheme != null) {
      currentThemeName = storedCurrentTheme;
    }
  }

  void _saveData() {
    _box.put('BOUGHT_THEMES', boughtThemes.toList());
    _box.put('CURRENT_THEME', currentThemeName);
  }

  bool isThemeBought(String name) => boughtThemes.contains(name);

  void buyTheme(String name) {
    boughtThemes.add(name);
    _saveData();
    notifyListeners();
  }

  void selectTheme(String name) {
    currentThemeName = name;
    _saveData();
    notifyListeners();
  }

  List<List<String>> get themeItems => _themeItems;
}
