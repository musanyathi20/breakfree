import 'package:uuid/uuid.dart';

class Achievement {
  final String id;
  String title;
  String description;
  int requiredDays;
  bool isUnlocked;
  DateTime? unlockedDate;
  String icon;

  Achievement({
    String? id,
    required this.title,
    required this.description,
    required this.requiredDays,
    this.isUnlocked = false,
    this.unlockedDate,
    required this.icon,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'requiredDays': requiredDays,
      'isUnlocked': isUnlocked,
      'unlockedDate': unlockedDate?.toIso8601String(),
      'icon': icon,
    };
  }

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      requiredDays: json['requiredDays'],
      isUnlocked: json['isUnlocked'],
      unlockedDate: json['unlockedDate'] != null
          ? DateTime.parse(json['unlockedDate'])
          : null,
      icon: json['icon'],
    );
  }
}

// Predefined achievements
List<Achievement> getPredefinedAchievements() {
  return [
    Achievement(
      title: 'First Step',
      description: 'Complete 1 day',
      requiredDays: 1,
      icon: '🎯',
    ),
    Achievement(
      title: 'Getting Started',
      description: 'Complete 3 days',
      requiredDays: 3,
      icon: '🌟',
    ),
    Achievement(
      title: 'One Week Strong',
      description: 'Complete 7 days',
      requiredDays: 7,
      icon: '💪',
    ),
    Achievement(
      title: 'Two Weeks',
      description: 'Complete 14 days',
      requiredDays: 14,
      icon: '🎉',
    ),
    Achievement(
      title: 'One Month',
      description: 'Complete 30 days',
      requiredDays: 30,
      icon: '🏆',
    ),
    Achievement(
      title: 'Two Months',
      description: 'Complete 60 days',
      requiredDays: 60,
      icon: '⭐',
    ),
    Achievement(
      title: 'Three Months',
      description: 'Complete 90 days',
      requiredDays: 90,
      icon: '🔥',
    ),
    Achievement(
      title: 'Half Year',
      description: 'Complete 180 days',
      requiredDays: 180,
      icon: '🌈',
    ),
    Achievement(
      title: 'One Year',
      description: 'Complete 365 days',
      requiredDays: 365,
      icon: '👑',
    ),
  ];
}
