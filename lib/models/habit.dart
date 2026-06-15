import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class Habit {
  final String id;
  String name;
  String category;
  double dailyCost;
  DateTime startDate;
  String? icon;
  Color? color;
  bool isActive;
  List<Relapse> relapses;
  List<JournalEntry> journalEntries;
  int totalMoneySaved;
  DateTime? lastRelapseDate;
  int currentStreak;
  int longestStreak;

  Habit({
    String? id,
    required this.name,
    required this.category,
    required this.dailyCost,
    required this.startDate,
    this.icon,
    this.color,
    this.isActive = true,
    List<Relapse>? relapses,
    List<JournalEntry>? journalEntries,
    this.totalMoneySaved = 0,
    this.lastRelapseDate,
    this.currentStreak = 0,
    this.longestStreak = 0,
  })  : id = id ?? const Uuid().v4(),
        relapses = relapses ?? [],
        journalEntries = journalEntries ?? [];

  int get daysSinceStart {
    return DateTime.now().difference(startDate).inDays;
  }

  int get daysClean {
    if (lastRelapseDate == null) {
      return daysSinceStart;
    }
    return DateTime.now().difference(lastRelapseDate!).inDays;
  }

  double get moneySavedToday {
    return dailyCost;
  }

  double get moneySavedThisWeek {
    return dailyCost * daysClean.clamp(0, 7);
  }

  double get moneySavedThisMonth {
    return dailyCost * daysClean.clamp(0, 30);
  }

  double get totalMoneySavedAmount {
    return dailyCost * daysClean;
  }

  double get successRate {
    if (relapses.isEmpty) return 100.0;
    int totalDays = daysSinceStart;
    if (totalDays == 0) return 100.0;
    return ((totalDays - relapses.length) / totalDays) * 100;
  }

  void addRelapse(Relapse relapse) {
    relapses.add(relapse);
    lastRelapseDate = relapse.date;
    currentStreak = 0;
  }

  void updateStreak() {
    if (lastRelapseDate == null) {
      currentStreak = daysSinceStart;
    } else {
      currentStreak = DateTime.now().difference(lastRelapseDate!).inDays;
    }

    if (currentStreak > longestStreak) {
      longestStreak = currentStreak;
    }

    totalMoneySaved = (dailyCost * currentStreak).toInt();
  }

  void addJournalEntry(JournalEntry entry) {
    journalEntries.add(entry);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'dailyCost': dailyCost,
      'startDate': startDate.toIso8601String(),
      'icon': icon,
      'color': color?.value,
      'isActive': isActive,
      'relapses': relapses.map((r) => r.toJson()).toList(),
      'journalEntries': journalEntries.map((j) => j.toJson()).toList(),
      'totalMoneySaved': totalMoneySaved,
      'lastRelapseDate': lastRelapseDate?.toIso8601String(),
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
    };
  }

  factory Habit.fromJson(Map<String, dynamic> json) {
    return Habit(
      id: json['id'],
      name: json['name'],
      category: json['category'],
      dailyCost: json['dailyCost'],
      startDate: DateTime.parse(json['startDate']),
      icon: json['icon'],
      color: json['color'] != null ? Color(json['color']) : null,
      isActive: json['isActive'],
      relapses:
          (json['relapses'] as List).map((r) => Relapse.fromJson(r)).toList(),
      journalEntries: (json['journalEntries'] as List)
          .map((j) => JournalEntry.fromJson(j))
          .toList(),
      totalMoneySaved: json['totalMoneySaved'],
      lastRelapseDate: json['lastRelapseDate'] != null
          ? DateTime.parse(json['lastRelapseDate'])
          : null,
      currentStreak: json['currentStreak'],
      longestStreak: json['longestStreak'],
    );
  }
}

class Relapse {
  final String id;
  final DateTime date;
  String? notes;
  String? trigger;

  Relapse({
    String? id,
    required this.date,
    this.notes,
    this.trigger,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'notes': notes,
      'trigger': trigger,
    };
  }

  factory Relapse.fromJson(Map<String, dynamic> json) {
    return Relapse(
      id: json['id'],
      date: DateTime.parse(json['date']),
      notes: json['notes'],
      trigger: json['trigger'],
    );
  }
}

class JournalEntry {
  final String id;
  final DateTime date;
  String mood;
  String notes;

  JournalEntry({
    String? id,
    required this.date,
    required this.mood,
    required this.notes,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'mood': mood,
      'notes': notes,
    };
  }

  factory JournalEntry.fromJson(Map<String, dynamic> json) {
    return JournalEntry(
      id: json['id'],
      date: DateTime.parse(json['date']),
      mood: json['mood'],
      notes: json['notes'],
    );
  }
}
