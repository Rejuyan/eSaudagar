import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsState {
  final ThemeMode themeMode;
  final Locale locale;

  SettingsState({
    required this.themeMode,
    required this.locale,
  });

  SettingsState copyWith({
    ThemeMode? themeMode,
    Locale? locale,
  }) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      locale: locale ?? this.locale,
    );
  }
}

class SettingsNotifier extends Notifier<SettingsState> {
  late SharedPreferences _prefs;

  @override
  SettingsState build() {
    return SettingsState(
      themeMode: ThemeMode.light,
      locale: const Locale('en'),
    );
  }

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    
    final isDark = _prefs.getBool('isDark') ?? false;
    final langCode = _prefs.getString('langCode') ?? 'en';

    state = SettingsState(
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      locale: Locale(langCode),
    );
  }

  Future<void> toggleTheme() async {
    final newMode = state.themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    await _prefs.setBool('isDark', newMode == ThemeMode.dark);
    state = state.copyWith(themeMode: newMode);
  }

  Future<void> setLocale(String langCode) async {
    await _prefs.setString('langCode', langCode);
    state = state.copyWith(locale: Locale(langCode));
  }
}

final settingsProvider = NotifierProvider<SettingsNotifier, SettingsState>(() {
  return SettingsNotifier();
});
