import 'package:flutter/material.dart';

class ThemeDetector with WidgetsBindingObserver {
  static final ThemeDetector _instance = ThemeDetector._internal();
  factory ThemeDetector() => _instance;
  ThemeDetector._internal() {
    WidgetsBinding.instance.addObserver(this);
    _updateBrightness();
  }

  Brightness _brightness = Brightness.light;

  @override
  void didChangePlatformBrightness() {
    _updateBrightness();
  }

  void _updateBrightness() {
    _brightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
  }

  bool isDarkMode() {
    return _brightness == Brightness.dark;
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
  }
}
