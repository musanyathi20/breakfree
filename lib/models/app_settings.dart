class AppSettings {
  bool isDarkMode;
  bool dailyReminder;
  bool motivationReminder;
  bool habitCheckinReminder;
  bool hasSeenOnboarding;
  String? dailyReminderTime;
  String? motivationReminderTime;

  AppSettings({
    this.isDarkMode = false,
    this.dailyReminder = true,
    this.motivationReminder = true,
    this.habitCheckinReminder = true,
    this.hasSeenOnboarding = false,
    this.dailyReminderTime = '09:00',
    this.motivationReminderTime = '18:00',
  });

  Map<String, dynamic> toJson() {
    return {
      'isDarkMode': isDarkMode,
      'dailyReminder': dailyReminder,
      'motivationReminder': motivationReminder,
      'habitCheckinReminder': habitCheckinReminder,
      'hasSeenOnboarding': hasSeenOnboarding,
      'dailyReminderTime': dailyReminderTime,
      'motivationReminderTime': motivationReminderTime,
    };
  }

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      isDarkMode: json['isDarkMode'] ?? false,
      dailyReminder: json['dailyReminder'] ?? true,
      motivationReminder: json['motivationReminder'] ?? true,
      habitCheckinReminder: json['habitCheckinReminder'] ?? true,
      hasSeenOnboarding: json['hasSeenOnboarding'] ?? false,
      dailyReminderTime: json['dailyReminderTime'] ?? '09:00',
      motivationReminderTime: json['motivationReminderTime'] ?? '18:00',
    );
  }
}
