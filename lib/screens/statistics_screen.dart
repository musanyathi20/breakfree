import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../themes/app_theme.dart';
import '../providers/habit_provider.dart';
import '../utils/constants.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics'),
        backgroundColor: AppTheme.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Consumer<HabitProvider>(
        builder: (context, habitProvider, child) {
          if (habitProvider.habits.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bar_chart, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No data yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  Text(
                    'Add habits to see statistics',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Overall Stats Cards
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.5,
                  children: [
                    _buildStatsCard(
                      'Current Streak',
                      '${habitProvider.currentStreak}',
                      'days',
                      Icons.local_fire_department,
                      Colors.orange,
                    ),
                    _buildStatsCard(
                      'Longest Streak',
                      '${habitProvider.longestStreak}',
                      'days',
                      Icons.emoji_events,
                      Colors.amber,
                    ),
                    _buildStatsCard(
                      'Total Saved',
                      AppConstants.formatCurrency(
                          habitProvider.totalMoneySaved),
                      '',
                      Icons.savings,
                      Colors.green,
                    ),
                    _buildStatsCard(
                      'Success Rate',
                      '${habitProvider.overallSuccessRate.toStringAsFixed(0)}',
                      '%',
                      Icons.trending_up,
                      AppTheme.deepPurple,
                    ),
                    _buildStatsCard(
                      'Active Habits',
                      '${habitProvider.activeHabits.length}',
                      '',
                      Icons.check_circle,
                      Colors.blue,
                    ),
                    _buildStatsCard(
                      'Total Relapses',
                      '${habitProvider.habits.fold(0, (sum, h) => sum + h.relapses.length)}',
                      '',
                      Icons.warning,
                      Colors.red,
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Progress Bar for Next Achievement
                if (habitProvider.nextAchievement != null)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                habitProvider.nextAchievement!.icon,
                                style: const TextStyle(fontSize: 24),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Next: ${habitProvider.nextAchievement!.title}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                    Text(
                                      habitProvider
                                          .nextAchievement!.description,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          LinearProgressIndicator(
                            value: habitProvider.getNextAchievementProgress(),
                            backgroundColor: Colors.grey[300],
                            color: AppTheme.deepPurple,
                            minHeight: 8,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${habitProvider.currentStreak}/${habitProvider.nextAchievement!.requiredDays} days',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                const SizedBox(height: 24),

                // Weekly Savings
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Savings Summary',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildSavingsRow(
                            'Today:',
                            AppConstants.formatCurrency(
                                habitProvider.todaySavedMoney)),
                        _buildSavingsRow(
                            'This week:',
                            AppConstants.formatCurrency(
                                habitProvider.weekSavedMoney)),
                        _buildSavingsRow(
                            'This month:',
                            AppConstants.formatCurrency(
                                habitProvider.monthSavedMoney)),
                        const Divider(height: 16),
                        _buildSavingsRow(
                            'Total lifetime:',
                            AppConstants.formatCurrency(
                                habitProvider.totalMoneySaved),
                            isBold: true),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Achievements Section
                const Text(
                  'Achievements',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ..._buildAchievements(habitProvider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatsCard(
      String title, String value, String suffix, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 4),
              Text(
                title,
                style: TextStyle(fontSize: 11, color: Colors.grey[600]),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Flexible(
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (suffix.isNotEmpty) ...[
                const SizedBox(width: 2),
                Text(
                  suffix,
                  style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSavingsRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: isBold ? AppTheme.deepPurple : null,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildAchievements(HabitProvider habitProvider) {
    List<Widget> widgets = [];

    final achievements = habitProvider.achievements;
    if (achievements.isEmpty) {
      return [
        const Center(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Text('Complete streaks to unlock achievements!'),
          ),
        ),
      ];
    }

    for (var achievement in achievements) {
      widgets.add(
        Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: achievement.isUnlocked
                    ? AppTheme.deepPurple.withOpacity(0.2)
                    : Colors.grey.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  achievement.icon,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            ),
            title: Text(
              achievement.title,
              style: TextStyle(
                fontWeight: achievement.isUnlocked
                    ? FontWeight.bold
                    : FontWeight.normal,
                color:
                    achievement.isUnlocked ? AppTheme.deepPurple : Colors.grey,
              ),
            ),
            subtitle: Text(achievement.description),
            trailing: achievement.isUnlocked
                ? const Icon(Icons.check_circle, color: Colors.green)
                : Text(
                    '${habitProvider.currentStreak}/${achievement.requiredDays} days'),
          ),
        ),
      );
    }

    return widgets;
  }
}
