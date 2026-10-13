import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../storage/hive_boxes.dart';

/// Riverpod Notifier managing ThemeMode (Light / Dark) with Hive persistence
class ThemeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    try {
      final box = Hive.box(HiveBoxes.settingsBox);
      final isDark = box.get('isDarkMode', defaultValue: false) as bool;
      return isDark ? ThemeMode.dark : ThemeMode.light;
    } catch (_) {
      return ThemeMode.light;
    }
  }

  void toggleTheme() {
    final newMode = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    state = newMode;
    try {
      final box = Hive.box(HiveBoxes.settingsBox);
      box.put('isDarkMode', newMode == ThemeMode.dark);
    } catch (_) {}
  }

  void setTheme(ThemeMode mode) {
    state = mode;
    try {
      final box = Hive.box(HiveBoxes.settingsBox);
      box.put('isDarkMode', mode == ThemeMode.dark);
    } catch (_) {}
  }
}

final themeProvider = NotifierProvider<ThemeNotifier, ThemeMode>(ThemeNotifier.new);
