import 'package:flutter/material.dart';
import '../models/app_settings.dart';
import '../services/storage_service.dart';

class SettingsProvider with ChangeNotifier {
  final StorageService _storage = StorageService();
  AppSettings _settings = AppSettings();

  AppSettings get settings => _settings;

  bool get isDarkMode => _settings.isDarkMode;
  bool get dailyReminder => _settings.dailyReminder;
  bool get motivationReminder => _settings.motivationReminder;
  bool get habitCheckinReminder => _settings.habitCheckinReminder;
  bool get hasSeenOnboarding => _settings.hasSeenOnboarding;

  // Initialize provider
  Future<void> init() async {
    await loadSettings();
  }

  // Load settings from storage
  Future<void> loadSettings() async {
    _settings = _storage.getSettings();
    notifyListeners();
  }

  // Update settings
  Future<void> updateSettings(AppSettings newSettings) async {
    _settings = newSettings;
    await _storage.saveSettings(_settings);
    notifyListeners();
  }

  // Toggle dark mode
  Future<void> toggleDarkMode() async {
    _settings.isDarkMode = !_settings.isDarkMode;
    await _storage.saveSettings(_settings);
    notifyListeners();
  }

  // Toggle daily reminder
  Future<void> toggleDailyReminder() async {
    _settings.dailyReminder = !_settings.dailyReminder;
    await _storage.saveSettings(_settings);
    notifyListeners();
  }

  // Toggle motivation reminder
  Future<void> toggleMotivationReminder() async {
    _settings.motivationReminder = !_settings.motivationReminder;
    await _storage.saveSettings(_settings);
    notifyListeners();
  }

  // Set onboarding as seen
  Future<void> setOnboardingSeen() async {
    _settings.hasSeenOnboarding = true;
    await _storage.saveSettings(_settings);
    notifyListeners();
  }

  // Reset all app data
  Future<void> resetAllData() async {
    await _storage.clearAllData();
    _settings = AppSettings();
    await _storage.saveSettings(_settings);
    notifyListeners();
  }
}
