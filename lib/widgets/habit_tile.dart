// lib/widgets/habit_tile.dart
import 'package:flutter/material.dart';
import '../model/habit.dart';
import '../services/habit_service.dart';

class HabitTile extends StatelessWidget {
  final Habit habit;
  final HabitService habitService;

  const HabitTile({
    super.key,
    required this.habit,
    required this.habitService,
  });

  @override
  Widget build(BuildContext context) {
    final today = DateUtils.dateOnly(DateTime.now());
    final isDoneToday = habit.completedDates.contains(today);
    final streak = habitService.calculateStreak(habit);
    final weeklyProgress = habitService.calculateWeeklyProgress(habit);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    habit.title,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                IconButton(
                  icon: Icon(
                    isDoneToday ? Icons.check_circle : Icons.radio_button_unchecked,
                    color: isDoneToday ? Theme.of(context).colorScheme.primary : null,
                  ),
                  onPressed: () => habitService.toggleHabitCompletion(habit),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Streak: $streak day${streak == 1 ? '' : 's'} 🔥',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    value: weeklyProgress,
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 8),
                Text('${(weeklyProgress * 100).toInt()}%'),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Weekly Progress',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}