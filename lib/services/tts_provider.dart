import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class TtsProvider extends ChangeNotifier {
  static const String _boxName = 'settings';
  static const String _key = 'ttsEnabled';

  bool _ttsEnabled = false;
  bool get ttsEnabled => _ttsEnabled;

  TtsProvider() {
    _load();
  }

  void _load() async {
    final box = await Hive.openBox(_boxName);
    _ttsEnabled = box.get(_key, defaultValue: false);
    notifyListeners();
  }

  void setTtsEnabled(bool value) async {
    _ttsEnabled = value;
    notifyListeners();
    final box = await Hive.openBox(_boxName);
    box.put(_key, value);
  }
}