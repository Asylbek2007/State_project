import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Theme mode state
class ThemeModeState {
  final ThemeMode themeMode;

  const ThemeModeState(this.themeMode);

  ThemeModeState copyWith({ThemeMode? themeMode}) {
    return ThemeModeState(themeMode ?? this.themeMode);
  }
}

/// Provider for theme mode management
class ThemeModeNotifier extends StateNotifier<ThemeModeState> {
  static const String _themeModeKey = 'theme_mode';

  ThemeModeNotifier() : super(const ThemeModeState(ThemeMode.light)) {
    _loadThemeMode();
  }

  /// Load theme mode from shared preferences
  Future<void> _loadThemeMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeModeIndex = prefs.getInt(_themeModeKey) ?? 0;
      state = ThemeModeState(ThemeMode.values[themeModeIndex]);
    } catch (e) {
      // If error, use light mode as default
      state = const ThemeModeState(ThemeMode.light);
    }
  }

  /// Set theme mode and save to preferences
  Future<void> setThemeMode(ThemeMode mode) async {
    state = ThemeModeState(mode);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_themeModeKey, mode.index);
    } catch (e) {
      // If save fails, state is still updated
      print('Failed to save theme mode: $e');
    }
  }

  /// Toggle between light and dark mode
  Future<void> toggleTheme() async {
    final newMode = state.themeMode == ThemeMode.light
        ? ThemeMode.dark
        : ThemeMode.light;
    await setThemeMode(newMode);
  }
}

/// Provider for theme mode notifier
final themeModeProvider =
    StateNotifierProvider<ThemeModeNotifier, ThemeModeState>((ref) {
  return ThemeModeNotifier();
});

