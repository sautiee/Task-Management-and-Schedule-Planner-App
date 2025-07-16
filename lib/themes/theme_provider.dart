import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:taskmanagement/themes/themes.dart';

class ThemeProvider with ChangeNotifier {
  ThemeData _themeData = lightMode;
  String _currentThemeName = 'Blue';

  // Getter for current theme data
  ThemeData get themeData => _themeData;

  // Getter for current theme name
  String get currentThemeName => _currentThemeName;

  // Constructor - loads saved theme from Hive on init
  ThemeProvider() {
    _loadThemeFromHive();
  }

  // Load saved theme and apply it
  Future<void> _loadThemeFromHive() async {
    var box3 = Hive.box('box3');
    String savedTheme = box3.get('CURRENT_THEME', defaultValue: 'Blue');
    _currentThemeName = savedTheme;

    switch (savedTheme) {
      case 'Blue':
        _themeData = lightMode;
        break;
      case 'Dark':
        _themeData = darkMode;
        break;
      case 'Purple':
        _themeData = purpleMode;
        break;
      case 'Green':
        _themeData = greenMode;
        break;
      case 'Red':
        _themeData = redMode;
        break;
      default:
        _themeData = lightMode;
    }
    notifyListeners();
  }

  // Save theme name
  Future<void> _saveThemeToHive(String themeName) async {
    var box3 = Hive.box('box3');
    await box3.put('CURRENT_THEME', themeName);
  }

  // Toggle themes (setters)

  void toggleLightTheme() {
    _currentThemeName = 'Light';
    _themeData = lightMode;
    _saveThemeToHive(_currentThemeName);
    notifyListeners();
  }

  void toggleDarkTheme() {
    _currentThemeName = 'Dark';
    _themeData = darkMode;
    _saveThemeToHive(_currentThemeName);
    notifyListeners();
  }

  void togglePurpleTheme() {
    _currentThemeName = 'Purple';
    _themeData = purpleMode;
    _saveThemeToHive(_currentThemeName);
    notifyListeners();
  }

  void toggleGreenTheme() {
    _currentThemeName = 'Green';
    _themeData = greenMode;
    _saveThemeToHive(_currentThemeName);
    notifyListeners();
  }

  void toggleRedTheme() {
    _currentThemeName = 'Red';
    _themeData = redMode;
    _saveThemeToHive(_currentThemeName);
    notifyListeners();
  }

  void togglePinkTheme() {
    _currentThemeName = 'Pink';
    _themeData = pinkMode;
    _saveThemeToHive(_currentThemeName);
    notifyListeners();
  }
}
