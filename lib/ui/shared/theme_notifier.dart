import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:subsocial_auth_example/ui/shared/providers.dart';

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  final sharedPrefs = ref.watch(sharedPrefsProvider);
  final themeIndex = sharedPrefs.getInt('theme');
  final theme =
      themeIndex == null ? ThemeMode.light : ThemeMode.values[themeIndex];
  return ThemeNotifier(theme, sharedPrefs);
});

class ThemeNotifier extends StateNotifier<ThemeMode> {
  final SharedPreferences _preferences;
  ThemeNotifier(ThemeMode initial, this._preferences) : super(initial);

  void change(ThemeMode newTheme) {
    _preferences.setInt('theme', newTheme.index);
    state = newTheme;
  }
}
