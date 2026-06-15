import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../themes/app_theme.dart';
import '../models/reason.dart';
import '../providers/reason_provider.dart';

class WhyStartedScreen extends StatefulWidget {
  const WhyStartedScreen({super.key});

  @override
  State<WhyStartedScreen> createState() => _WhyStartedScreenState();
}

class _WhyStartedScreenState extends State<WhyStartedScreen> {
  final TextEditingController _reasonController = TextEditingController();
  String _selectedIcon = '❤️';

  final List<String> _iconOptions = [
    '❤️',
    '💰',
    '👨‍👩‍👧‍👦',
    '⚡',
    '😴',
    '🌟',
    '🏆',
    '🎯',
    '💪',
    '🌈',
    '🔥',
    '🎉'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Why You Started'),
        backgroundColor: AppTheme.deepPurple,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Consumer<ReasonProvider>(
        builder: (context, reasonProvider, child) {
          return Column(
            children: [
              // Add Reason Section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.lightPurple.withOpacity(0.3),
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.withOpacity(0.2)),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Add Your Reason',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Why do you want to quit? This will keep you motivated!',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _reasonController,
                      decoration: const InputDecoration(
                        hintText: 'e.g., To be healthier for my family...',
                        border: OutlineInputBorder(),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 12),
                    const Text('Choose an icon:'),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 12,
                      runSpacing: 8,
                      children: _iconOptions.map((icon) {
                        return FilterChip(
                          label:
                              Text(icon, style: const TextStyle(fontSize: 20)),
                          selected: _selectedIcon == icon,
                          onSelected: (selected) {
                            setState(() {
                              _selectedIcon = selected ? icon : '❤️';
                            });
                          },
                          selectedColor: AppTheme.deepPurple.withOpacity(0.2),
                          checkmarkColor: AppTheme.deepPurple,
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: _addReason,
                      icon: const Icon(Icons.add),
                      label: const Text('Add Your Reason'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.deepPurple,
                        minimumSize: const Size(double.infinity, 45),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Your Reasons List
              Expanded(
                child: reasonProvider.reasons.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.emoji_emotions,
                                size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text(
                              'No reasons added yet',
                              style:
                                  TextStyle(fontSize: 18, color: Colors.grey),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Add your first reason to stay motivated!',
                              style:
                                  TextStyle(fontSize: 14, color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: reasonProvider.reasons.length,
                        itemBuilder: (context, index) {
                          final reason = reasonProvider.reasons[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              leading: Container(
                                width: 55,
                                height: 55,
                                decoration: BoxDecoration(
                                  color: AppTheme.deepPurple.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: Text(
                                    reason.icon,
                                    style: const TextStyle(fontSize: 28),
                                  ),
                                ),
                              ),
                              title: Text(
                                reason.text,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              subtitle: Text(
                                'Added ${_formatDate(reason.createdAt)}',
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey[600]),
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete_outline,
                                    color: Colors.red),
                                onPressed: () => _deleteReason(reason.id),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _addReason() async {
    if (_reasonController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a reason'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final reason = Reason(
      text: _reasonController.text.trim(),
      icon: _selectedIcon,
      createdAt: DateTime.now(),
    );

    await context.read<ReasonProvider>().addReason(reason);
    _reasonController.clear();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Reason added! 🎯 Stay motivated!'),
          backgroundColor: AppTheme.deepPurple,
        ),
      );
    }
  }

  void _deleteReason(String id) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Reason'),
        content: const Text('Are you sure you want to delete this reason?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await context.read<ReasonProvider>().deleteReason(id);
              if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Reason deleted')),
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
