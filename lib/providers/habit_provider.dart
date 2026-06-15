import 'package:flutter/material.dart';
import '../models/habit.dart';
import '../models/achievement.dart';
import '../services/storage_service.dart';

class HabitProvider with ChangeNotifier {
  final StorageService _storage = StorageService();

  List<Habit> _habits = [];
  List<Achievement> _achievements = [];

  List<Habit> get habits => _habits;
  List<Achievement> get achievements => _achievements;

  // Get active habits only
  List<Habit> get activeHabits => _habits.where((h) => h.isActive).toList();

  // Get current streak (highest among all habits)
  int get currentStreak {
    if (_habits.isEmpty) return 0;
    return _habits.map((h) => h.currentStreak).reduce((a, b) => a > b ? a : b);
  }

  // Get longest streak ever
  int get longestStreak {
    if (_habits.isEmpty) return 0;
    return _habits.map((h) => h.longestStreak).reduce((a, b) => a > b ? a : b);
  }

  // Get total money saved across all habits
  double get totalMoneySaved {
    return _habits.fold(0.0, (sum, habit) => sum + habit.totalMoneySavedAmount);
  }

  // Get overall success rate
  double get overallSuccessRate {
    if (_habits.isEmpty) return 100.0;
    double totalRate =
        _habits.fold(0.0, (sum, habit) => sum + habit.successRate);
    return totalRate / _habits.length;
  }

  // Get today's saved money
  double get todaySavedMoney {
    return _habits.fold(0.0, (sum, habit) => sum + habit.moneySavedToday);
  }

  // Get this week's saved money
  double get weekSavedMoney {
    return _habits.fold(0.0, (sum, habit) => sum + habit.moneySavedThisWeek);
  }

  // Get this month's saved money
  double get monthSavedMoney {
    return _habits.fold(0.0, (sum, habit) => sum + habit.moneySavedThisMonth);
  }

  // Initialize provider - load data from storage
  Future<void> init() async {
    await loadHabits();
    await loadAchievements();
    updateAllStreaks();
  }

  // Load habits from storage
  Future<void> loadHabits() async {
    _habits = _storage.getHabits();
    notifyListeners();
  }

  // Load achievements from storage
  Future<void> loadAchievements() async {
    _achievements = _storage.getAchievements();
    if (_achievements.isEmpty) {
      // Initialize with predefined achievements
      _achievements = getPredefinedAchievements();
      await _storage.saveAchievements(_achievements);
    }
    notifyListeners();
  }

  // Add new habit
  Future<void> addHabit(Habit habit) async {
    await _storage.addHabit(habit);
    await loadHabits();
    checkAchievements();
  }

  // Update existing habit
  Future<void> updateHabit(Habit habit) async {
    await _storage.updateHabit(habit);
    await loadHabits();
    checkAchievements();
  }

  // Delete habit
  Future<void> deleteHabit(String habitId) async {
    await _storage.deleteHabit(habitId);
    await loadHabits();
  }

  // Log a relapse
  Future<void> logRelapse(String habitId, Relapse relapse) async {
    final habit = _habits.firstWhere((h) => h.id == habitId);
    habit.addRelapse(relapse);
    habit.updateStreak();
    await _storage.updateHabit(habit);
    await loadHabits();
    checkAchievements();
  }

  // Add journal entry
  Future<void> addJournalEntry(String habitId, JournalEntry entry) async {
    final habit = _habits.firstWhere((h) => h.id == habitId);
    habit.addJournalEntry(entry);
    await _storage.updateHabit(habit);
    await loadHabits();
  }

  // Update all streaks
  void updateAllStreaks() {
    for (var habit in _habits) {
      int oldStreak = habit.currentStreak;
      habit.updateStreak();
      if (oldStreak != habit.currentStreak) {
        _storage.updateHabit(habit);
      }
    }
    notifyListeners();
  }

  // Check and unlock achievements
  void checkAchievements() {
    bool updated = false;

    for (var achievement in _achievements) {
      if (!achievement.isUnlocked &&
          currentStreak >= achievement.requiredDays) {
        achievement.isUnlocked = true;
        achievement.unlockedDate = DateTime.now();
        updated = true;
      }
    }

    if (updated) {
      _storage.saveAchievements(_achievements);
      notifyListeners();
    }
  }

  // Get habit by ID
  Habit? getHabitById(String id) {
    try {
      return _habits.firstWhere((h) => h.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get unlocked achievements
  List<Achievement> get unlockedAchievements {
    return _achievements.where((a) => a.isUnlocked).toList();
  }

  // Get locked achievements
  List<Achievement> get lockedAchievements {
    return _achievements.where((a) => !a.isUnlocked).toList();
  }

  // Get achievement progress percentage for next achievement
  double getNextAchievementProgress() {
    final locked = lockedAchievements;
    if (locked.isEmpty) return 100.0;

    final nextAchievement = locked.first;
    final progress = currentStreak / nextAchievement.requiredDays;
    return progress.clamp(0.0, 1.0);
  }

  // Get next achievement
  Achievement? get nextAchievement {
    final locked = lockedAchievements;
    if (locked.isEmpty) return null;
    return locked.first;
  }
}
