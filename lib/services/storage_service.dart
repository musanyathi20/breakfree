import 'dart:convert';
import 'simple_storage.dart';
import '../models/habit.dart';
import '../models/reason.dart';
import '../models/achievement.dart';
import '../models/app_settings.dart';

class StorageService {
  // ============ HABITS ============

  Future<void> saveHabits(List<Habit> habits) async {
    List<String> habitsJson =
        habits.map((habit) => jsonEncode(habit.toJson())).toList();
    await SimpleStorage.saveStringList('habits', habitsJson);
  }

  List<Habit> getHabits() {
    List<String> habitsJson = SimpleStorage.getStringList('habits');
    if (habitsJson.isEmpty) return [];

    return habitsJson.map((jsonString) {
      Map<String, dynamic> json = jsonDecode(jsonString);
      return Habit.fromJson(json);
    }).toList();
  }

  Future<void> addHabit(Habit habit) async {
    List<Habit> habits = getHabits();
    habits.add(habit);
    await saveHabits(habits);
  }

  Future<void> updateHabit(Habit updatedHabit) async {
    List<Habit> habits = getHabits();
    int index = habits.indexWhere((habit) => habit.id == updatedHabit.id);
    if (index != -1) {
      habits[index] = updatedHabit;
      await saveHabits(habits);
    }
  }

  Future<void> deleteHabit(String habitId) async {
    List<Habit> habits = getHabits();
    habits.removeWhere((habit) => habit.id == habitId);
    await saveHabits(habits);
  }

  Habit? getHabitById(String id) {
    List<Habit> habits = getHabits();
    try {
      return habits.firstWhere((habit) => habit.id == id);
    } catch (e) {
      return null;
    }
  }

  // ============ REASONS ============

  Future<void> saveReasons(List<Reason> reasons) async {
    List<String> reasonsJson =
        reasons.map((reason) => jsonEncode(reason.toJson())).toList();
    await SimpleStorage.saveStringList('reasons', reasonsJson);
  }

  List<Reason> getReasons() {
    List<String> reasonsJson = SimpleStorage.getStringList('reasons');
    if (reasonsJson.isEmpty) return [];

    return reasonsJson.map((jsonString) {
      Map<String, dynamic> json = jsonDecode(jsonString);
      return Reason.fromJson(json);
    }).toList();
  }

  Future<void> addReason(Reason reason) async {
    List<Reason> reasons = getReasons();
    reasons.add(reason);
    await saveReasons(reasons);
  }

  Future<void> deleteReason(String reasonId) async {
    List<Reason> reasons = getReasons();
    reasons.removeWhere((reason) => reason.id == reasonId);
    await saveReasons(reasons);
  }

  // ============ ACHIEVEMENTS ============

  Future<void> saveAchievements(List<Achievement> achievements) async {
    List<String> achievementsJson = achievements
        .map((achievement) => jsonEncode(achievement.toJson()))
        .toList();
    await SimpleStorage.saveStringList('achievements', achievementsJson);
  }

  List<Achievement> getAchievements() {
    List<String> achievementsJson = SimpleStorage.getStringList('achievements');
    if (achievementsJson.isEmpty) return [];

    return achievementsJson.map((jsonString) {
      Map<String, dynamic> json = jsonDecode(jsonString);
      return Achievement.fromJson(json);
    }).toList();
  }

  Future<void> updateAchievement(Achievement updatedAchievement) async {
    List<Achievement> achievements = getAchievements();
    int index = achievements
        .indexWhere((achievement) => achievement.id == updatedAchievement.id);
    if (index != -1) {
      achievements[index] = updatedAchievement;
      await saveAchievements(achievements);
    }
  }

  // ============ SETTINGS ============

  Future<void> saveSettings(AppSettings settings) async {
    await SimpleStorage.saveString('settings', jsonEncode(settings.toJson()));
  }

  AppSettings getSettings() {
    String? settingsJson = SimpleStorage.getString('settings');
    if (settingsJson == null) {
      return AppSettings();
    }
    Map<String, dynamic> json = jsonDecode(settingsJson);
    return AppSettings.fromJson(json);
  }

  // ============ UTILITY ============

  Future<void> clearAllData() async {
    await SimpleStorage.remove('habits');
    await SimpleStorage.remove('reasons');
    await SimpleStorage.remove('achievements');
    await SimpleStorage.remove('settings');
  }

  // Export all data as JSON string
  String exportAllData() {
    Map<String, dynamic> allData = {
      'habits': getHabits().map((h) => h.toJson()).toList(),
      'reasons': getReasons().map((r) => r.toJson()).toList(),
      'achievements': getAchievements().map((a) => a.toJson()).toList(),
      'settings': getSettings().toJson(),
      'exportDate': DateTime.now().toIso8601String(),
    };
    return jsonEncode(allData);
  }

  // Import data from JSON string
  Future<void> importData(String jsonString) async {
    try {
      Map<String, dynamic> allData = jsonDecode(jsonString);

      if (allData.containsKey('habits')) {
        List<Habit> habits =
            (allData['habits'] as List).map((h) => Habit.fromJson(h)).toList();
        await saveHabits(habits);
      }

      if (allData.containsKey('reasons')) {
        List<Reason> reasons = (allData['reasons'] as List)
            .map((r) => Reason.fromJson(r))
            .toList();
        await saveReasons(reasons);
      }

      if (allData.containsKey('achievements')) {
        List<Achievement> achievements = (allData['achievements'] as List)
            .map((a) => Achievement.fromJson(a))
            .toList();
        await saveAchievements(achievements);
      }

      if (allData.containsKey('settings')) {
        AppSettings settings = AppSettings.fromJson(allData['settings']);
        await saveSettings(settings);
      }
    } catch (e) {
      throw Exception('Failed to import data: $e');
    }
  }
}
