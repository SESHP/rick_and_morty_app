import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class SettingsProvider with ChangeNotifier {
  static const String _boxName = 'settings';
  late Box _box;

  static const Map<String, Color> themeColors = {
    'green': Color(0xFF34C759),
    'blue': Color(0xFF007AFF),
    'purple': Color(0xFFAF52DE),
    'pink': Color(0xFFFF2D55),
    'orange': Color(0xFFFF9500),
    'red': Color(0xFFFF3B30),
  };

  String _colorKey = 'green';
  String _language = 'ru';
  bool _isDark = true;

  String get colorKey => _colorKey;
  Color get themeColor => themeColors[_colorKey] ?? themeColors['green']!;
  String get language => _language;
  bool get isDark => _isDark;

  // Цвета для светлой/тёмной темы
  Color get backgroundColor => _isDark ? Colors.black : const Color(0xFFF2F2F7);
  Color get cardColor => _isDark ? const Color(0xFF1C1C1E) : Colors.white;
  Color get textColor => _isDark ? Colors.white : Colors.black;
  Color get textSecondaryColor => _isDark ? Colors.white70 : Colors.black54;
  Color get textTertiaryColor => _isDark ? Colors.white38 : Colors.black38;

  Future<void> init() async {
    _box = await Hive.openBox(_boxName);
    _colorKey = _box.get('colorKey', defaultValue: 'green');
    _language = _box.get('language', defaultValue: 'ru');
    _isDark = _box.get('isDark', defaultValue: true);
    notifyListeners();
  }

  Future<void> setColor(String colorKey) async {
    _colorKey = colorKey;
    await _box.put('colorKey', colorKey);
    notifyListeners();
  }

  Future<void> setLanguage(String language) async {
    _language = language;
    await _box.put('language', language);
    notifyListeners();
  }

  Future<void> setDarkMode(bool isDark) async {
    _isDark = isDark;
    await _box.put('isDark', isDark);
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    await setDarkMode(!_isDark);
  }
}