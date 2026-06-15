import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../themes/app_theme.dart';
import '../models/habit.dart';
import '../providers/habit_provider.dart';
import '../utils/constants.dart';

class HabitDetailScreen extends StatefulWidget {
  final String habitId;

  const HabitDetailScreen({super.key, required this.habitId});

  @override
  State<HabitDetailScreen> createState() => _HabitDetailScreenState();
}

class _HabitDetailScreenState extends State<HabitDetailScreen> {
  late Habit habit;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final fetchedHabit =
        context.read<HabitProvider>().getHabitById(widget.habitId);
    if (fetchedHabit != null) {
      habit = fetchedHabit;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HabitProvider>(
      builder: (context, habitProvider, child) {
        final currentHabit = habitProvider.getHabitById(widget.habitId);

        if (currentHabit == null) {
          return const Scaffold(
            body: Center(child: Text('Habit not found')),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(currentHabit.name),
            backgroundColor: currentHabit.color ?? AppTheme.deepPurple,
            foregroundColor: Colors.white,
            actions: [
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => _confirmDelete(context, currentHabit.id),
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: () async {
              await habitProvider.loadHabits();
              setState(() {});
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stats Grid
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.5,
                    children: [
                      _buildStatCard(
                        'Current Streak',
                        '${currentHabit.currentStreak}',
                        'days',
                        Icons.local_fire_department,
                        Colors.orange,
                      ),
                      _buildStatCard(
                        'Longest Streak',
                        '${currentHabit.longestStreak}',
                        'days',
                        Icons.emoji_events,
                        Colors.amber,
                      ),
                      _buildStatCard(
                        'Money Saved',
                        AppConstants.formatCurrency(
                            currentHabit.totalMoneySavedAmount),
                        '',
                        Icons.savings,
                        Colors.green,
                      ),
                      _buildStatCard(
                        'Success Rate',
                        '${currentHabit.successRate.toStringAsFixed(0)}',
                        '%',
                        Icons.trending_up,
                        AppTheme.deepPurple,
                      ),
                      _buildStatCard(
                        'Days Clean',
                        '${currentHabit.daysClean}',
                        'days',
                        Icons.clean_hands,
                        Colors.blue,
                      ),
                      _buildStatCard(
                        'Relapses',
                        '${currentHabit.relapses.length}',
                        'times',
                        Icons.warning,
                        Colors.red,
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Action Buttons
                  const Text(
                    'Actions',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildActionButton(
                          'Log Relapse',
                          Icons.warning_amber,
                          Colors.red,
                          () => _showRelapseDialog(context, currentHabit),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildActionButton(
                          'Add Journal',
                          Icons.edit_note,
                          Colors.blue,
                          () => _showJournalDialog(context, currentHabit),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Recent Activity
                  if (currentHabit.journalEntries.isNotEmpty ||
                      currentHabit.relapses.isNotEmpty)
                    const Text(
                      'Recent Activity',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  const SizedBox(height: 12),
                  ..._buildRecentActivity(currentHabit),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatCard(
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

  Widget _buildActionButton(
      String label, IconData icon, Color color, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  List<Widget> _buildRecentActivity(Habit habit) {
    List<Widget> activities = [];

    // Add journal entries
    for (var entry in habit.journalEntries.reversed.take(5)) {
      activities.add(
        Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor:
                  AppConstants.moodColors[entry.mood]?.withOpacity(0.2),
              child: Icon(
                AppConstants.moodIcons[entry.mood],
                color: AppConstants.moodColors[entry.mood],
                size: 20,
              ),
            ),
            title: Text('Journal Entry - ${_formatDate(entry.date)}'),
            subtitle: Text(entry.notes.length > 50
                ? '${entry.notes.substring(0, 50)}...'
                : entry.notes),
            trailing: Text(entry.mood, style: const TextStyle(fontSize: 12)),
          ),
        ),
      );
    }

    // Add relapses
    for (var relapse in habit.relapses.reversed.take(5)) {
      activities.add(
        Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: const CircleAvatar(
              backgroundColor: Colors.red,
              child: Icon(Icons.warning, color: Colors.white),
            ),
            title: Text('Relapse - ${_formatDate(relapse.date)}'),
            subtitle: relapse.notes != null
                ? Text(relapse.notes!.length > 50
                    ? '${relapse.notes!.substring(0, 50)}...'
                    : relapse.notes!)
                : const Text('No notes provided'),
            trailing: relapse.trigger != null
                ? Chip(
                    label: Text(relapse.trigger!),
                    backgroundColor: Colors.red.shade100)
                : null,
          ),
        ),
      );
    }

    if (activities.isEmpty) {
      return [
        Center(
          child: Padding(
            padding: const EdgeInsets.all(40),
            child: Text(
              'No activity yet.\nLog your first journal entry!',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
        ),
      ];
    }

    return activities;
  }

  void _showRelapseDialog(BuildContext context, Habit habit) {
    final notesController = TextEditingController();
    final triggerController = TextEditingController();
    String? selectedTrigger;

    List<String> commonTriggers = [
      'Stress',
      'Boredom',
      'Social',
      'Anxiety',
      'Celebration',
      'Loneliness'
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log Relapse'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                  'It\'s okay to have setbacks. What matters is getting back up!'),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Trigger (Optional)',
                  border: OutlineInputBorder(),
                ),
                items: commonTriggers.map((trigger) {
                  return DropdownMenuItem(value: trigger, child: Text(trigger));
                }).toList(),
                onChanged: (value) {
                  selectedTrigger = value;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes (Optional)',
                  hintText: 'What led to this?',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final relapse = Relapse(
                date: DateTime.now(),
                notes: notesController.text.isNotEmpty
                    ? notesController.text
                    : null,
                trigger: selectedTrigger,
              );
              await context.read<HabitProvider>().logRelapse(habit.id, relapse);
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Relapse logged. Tomorrow is a new day! 💪'),
                    backgroundColor: AppTheme.deepPurple,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Log Relapse'),
          ),
        ],
      ),
    );
  }

  void _showJournalDialog(BuildContext context, Habit habit) {
    final notesController = TextEditingController();
    String selectedMood = AppConstants.moods[2];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Journal Entry'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: selectedMood,
                decoration: const InputDecoration(
                  labelText: 'How do you feel?',
                  border: OutlineInputBorder(),
                ),
                items: AppConstants.moods.map((mood) {
                  return DropdownMenuItem(
                    value: mood,
                    child: Row(
                      children: [
                        Icon(AppConstants.moodIcons[mood],
                            color: AppConstants.moodColors[mood]),
                        const SizedBox(width: 8),
                        Text(mood),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  selectedMood = value!;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  hintText: 'How is your journey going?',
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (notesController.text.isNotEmpty) {
                final entry = JournalEntry(
                  date: DateTime.now(),
                  mood: selectedMood,
                  notes: notesController.text,
                );
                await context
                    .read<HabitProvider>()
                    .addJournalEntry(habit.id, entry);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Journal entry saved! 📝'),
                      backgroundColor: AppTheme.deepPurple,
                    ),
                  );
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, String habitId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Habit'),
        content: const Text(
            'Are you sure you want to delete this habit? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await context.read<HabitProvider>().deleteHabit(habitId);
              if (context.mounted) {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Go back to home
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Habit deleted'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
