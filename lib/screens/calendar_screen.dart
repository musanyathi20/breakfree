import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../themes/app_theme.dart';
import '../providers/habit_provider.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _currentMonth = DateTime.now();
  DateTime? _selectedDate;
  Map<String, List<String>> _events = {};

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _loadEvents();
  }

  void _loadEvents() {
    final habitProvider = context.read<HabitProvider>();
    final Map<String, List<String>> events = {};

    for (var habit in habitProvider.habits) {
      for (var relapse in habit.relapses) {
        final dateKey =
            '${relapse.date.year}-${relapse.date.month}-${relapse.date.day}';
        if (!events.containsKey(dateKey)) {
          events[dateKey] = [];
        }
        events[dateKey]!.add('⚠️ Relapse: ${habit.name}');
      }

      for (var journal in habit.journalEntries) {
        final dateKey =
            '${journal.date.year}-${journal.date.month}-${journal.date.day}';
        if (!events.containsKey(dateKey)) {
          events[dateKey] = [];
        }
        events[dateKey]!.add('📝 Journal: ${journal.mood}');
      }
    }

    setState(() {
      _events = events;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar'),
        backgroundColor: AppTheme.deepPurple,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Month Navigation
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () {
                    setState(() {
                      _currentMonth =
                          DateTime(_currentMonth.year, _currentMonth.month - 1);
                      _loadEvents();
                    });
                  },
                ),
                Text(
                  _getMonthName(_currentMonth.month),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () {
                    setState(() {
                      _currentMonth =
                          DateTime(_currentMonth.year, _currentMonth.month + 1);
                      _loadEvents();
                    });
                  },
                ),
              ],
            ),
          ),

          // Day Headers
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              children: const [
                Expanded(
                    child: Text('Mon',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(
                    child: Text('Tue',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(
                    child: Text('Wed',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(
                    child: Text('Thu',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(
                    child: Text('Fri',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(
                    child: Text('Sat',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.red))),
                Expanded(
                    child: Text('Sun',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.red))),
              ],
            ),
          ),

          const Divider(height: 1),

          // Calendar Grid
          Expanded(
            flex: 3,
            child: _buildCalendarGrid(),
          ),

          const Divider(height: 1),

          // Selected Date Events
          if (_selectedDate != null)
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _formatDate(_selectedDate!),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: _buildEventsForDay(_selectedDate!),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid() {
    final firstDayOfMonth =
        DateTime(_currentMonth.year, _currentMonth.month, 1);
    int firstWeekday = firstDayOfMonth.weekday;

    // Adjust for Monday as first day (1 = Monday, 7 = Sunday)
    int startOffset = firstWeekday - 1;
    if (startOffset < 0) startOffset = 6;

    final daysInMonth =
        DateTime(_currentMonth.year, _currentMonth.month + 1, 0).day;

    List<Widget> calendarDays = [];

    // Empty cells for days before month starts
    for (int i = 0; i < startOffset; i++) {
      calendarDays.add(const Expanded(child: SizedBox()));
    }

    // Days of the month
    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(_currentMonth.year, _currentMonth.month, day);
      final isSelected = _selectedDate != null &&
          _selectedDate!.year == date.year &&
          _selectedDate!.month == date.month &&
          _selectedDate!.day == date.day;
      final isToday = DateTime.now().year == date.year &&
          DateTime.now().month == date.month &&
          DateTime.now().day == date.day;
      final hasEvents =
          _events.containsKey('${date.year}-${date.month}-${date.day}');
      final isWeekend = date.weekday == 6 || date.weekday == 7;

      calendarDays.add(
        Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                _selectedDate = date;
              });
            },
            child: Container(
              margin: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.deepPurple
                    : hasEvents
                        ? AppTheme.lightPurple
                        : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Container(
                  width: 36,
                  height: 36,
                  alignment: Alignment.center,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Text(
                        day.toString(),
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : isWeekend
                                  ? Colors.red
                                  : null,
                          fontWeight:
                              isToday ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      if (hasEvents && !isSelected)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: AppTheme.deepPurple,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    // Fill remaining cells
    final remainingCells = 42 - calendarDays.length;
    for (int i = 0; i < remainingCells; i++) {
      calendarDays.add(const Expanded(child: SizedBox()));
    }

    return GridView.count(
      crossAxisCount: 7,
      childAspectRatio: 1.2,
      children: calendarDays,
    );
  }

  Widget _buildEventsForDay(DateTime day) {
    final dateKey = '${day.year}-${day.month}-${day.day}';
    final events = _events[dateKey] ?? [];

    if (events.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, size: 48, color: Colors.green),
            SizedBox(height: 8),
            Text(
              'No events for this day',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            Text(
              'Great job staying on track!',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: events.length,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: events[index].contains('Relapse')
                ? const Icon(Icons.warning, color: Colors.red)
                : const Icon(Icons.edit_note, color: Colors.blue),
            title: Text(events[index]),
            subtitle: Text(_formatTime(day)),
          ),
        );
      },
    );
  }

  String _getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return months[month - 1];
  }

  String _formatDate(DateTime date) {
    return '${date.day} ${_getMonthName(date.month)} ${date.year}';
  }

  String _formatTime(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
