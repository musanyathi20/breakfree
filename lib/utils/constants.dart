import 'package:flutter/material.dart';

class AppConstants {
  // Currency Settings
  static const String currencySymbol = 'R';
  static const String currencyCode = 'ZAR';
  static const String currencyName = 'Rand';

  // User Settings Keys
  static const String userNameKey = 'user_name';
  static const String hasSeenOnboardingKey = 'has_seen_onboarding';

  // Habit Categories
  static const List<String> categories = [
    'Smoking',
    'Alcohol',
    'Gambling',
    'Social Media',
    'Junk Food',
    'Gaming',
    'Other',
  ];

  // Category Icons - Using regular Map (not const)
  static Map<String, IconData> categoryIcons = {
    'Smoking': Icons.smoke_free,
    'Alcohol': Icons.local_bar,
    'Gambling': Icons.casino,
    'Social Media': Icons.phone_android,
    'Junk Food': Icons.fastfood,
    'Gaming': Icons.sports_esports,
    'Other': Icons.help_outline,
  };

  // Mood Options
  static const List<String> moods = [
    'Great',
    'Good',
    'Neutral',
    'Bad',
    'Terrible',
  ];

  static Map<String, IconData> moodIcons = {
    'Great': Icons.sentiment_very_satisfied,
    'Good': Icons.sentiment_satisfied,
    'Neutral': Icons.sentiment_neutral,
    'Bad': Icons.sentiment_dissatisfied,
    'Terrible': Icons.sentiment_very_dissatisfied,
  };

  static Map<String, Color> moodColors = {
    'Great': const Color(0xFF4CAF50),
    'Good': const Color(0xFF8BC34A),
    'Neutral': const Color(0xFFFFC107),
    'Bad': const Color(0xFFFF9800),
    'Terrible': const Color(0xFFE53935),
  };

  // Default Reasons to Quit
  static const List<Map<String, String>> defaultReasons = [
    {'text': 'Better health and longer life', 'icon': '❤️'},
    {'text': 'Save money for important things', 'icon': '💰'},
    {'text': 'Better relationships with family', 'icon': '👨‍👩‍👧‍👦'},
    {'text': 'More energy and productivity', 'icon': '⚡'},
    {'text': 'Better sleep and mental clarity', 'icon': '😴'},
    {'text': 'Be a better role model', 'icon': '🌟'},
  ];

  // Motivational Quotes
  static const List<String> quotes = [
    'The secret of getting ahead is getting started.',
    'You didn\'t come this far to only come this far.',
    'Small progress is still progress.',
    'One day at a time.',
    'Your future self will thank you.',
    'Every master was once a beginner.',
    'Don\'t stop until you\'re proud.',
    'You are stronger than you think.',
    'Today is the first day of the rest of your life.',
    'Believe you can and you\'re halfway there.',
  ];

  // Emergency Messages
  static const List<String> emergencyMessages = [
    'This craving will pass. You are stronger than it! 💪',
    'Remember why you started. You\'ve got this! 🌟',
    'Take a deep breath. Count to 10. You can do this! 🧘',
    'Think about how proud you\'ll feel tomorrow! ✨',
    'This feeling is temporary. Your progress is permanent! 🎯',
    'You have the power to choose differently today! 🌈',
    'One moment of strength changes everything! ⚡',
    'You\'re not alone in this fight! 🤝',
    'Future you is cheering for current you! 🎉',
    'This is your breakthrough moment! 🦋',
  ];

  // Format currency helper
  static String formatCurrency(double amount) {
    return '$currencySymbol${amount.toStringAsFixed(2)}';
  }
}
