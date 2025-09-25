// lib/services/habit_service.dart
import 'package.flutter/material.dart';
import 'package:hive/hive.dart';
import '../model/habit.dart';

class HabitService extends ChangeNotifier {
  static const String _boxName = "habitsBox";
  Box<Habit>? _box;

  List<Habit> _habits = [];
  List<Habit> get habits => List.unmodifiable(_habits);

  Future<void> init() async {
    if (_box != null) return;
    
    _box = await Hive.openBox<Habit>(_boxName);
    _habits = _box?.values.toList() ?? [];
    notifyListeners();
  }

  Future<void> addHabit(String title) async {
    if (_box == null) await init();
    
    final newHabit = Habit(
      title: title,
      creationDate: DateTime.now(),
    );

    await _box?.add(newHabit);
    _habits = _box?.values.toList() ?? [];
    notifyListeners();
  }

  // --- THIS IS THE CORRECTED METHOD ---
  Future<void> toggleHabitCompletion(Habit habit) async {
    if (_box == null) await init();
    
    // 1. Call the new method on the habit object itself
    habit.toggleCompletion();
    
    // 2. Save the changes back to the database
    // Since Habit extends HiveObject, you can save it directly.
    await habit.save();

    // 3. Refresh the local list and notify listeners
    _habits = _box?.values.toList() ?? [];
    notifyListeners();
  }

  // ... (keep your other methods like calculateStreak)
  int calculateStreak(Habit habit) {
    if (habit.completedDates.isEmpty) return 0;
    final sortedDates = habit.completedDates.map(DateUtils.dateOnly).toList()
      ..sort((a, b) => b.compareTo(a));
    int streak = 0;
    var currentDate = DateUtils.dateOnly(DateTime.now());
    if (sortedDates.contains(currentDate)) {
      streak++;
    } else {
      currentDate = currentDate.subtract(const Duration(days: 1));
    }
    for (final date in sortedDates) {
      if (date == currentDate) {
        if (!sortedDates.contains(date)) continue;
        streak++;
        currentDate = currentDate.subtract(const Duration(days: 1));
      }
    }
    return streak;
  }

  double calculateWeeklyProgress(Habit habit) {
    final today = DateTime.now();
    final startOfWeek = today.subtract(Duration(days: today.weekday - 1));
    int completedInWeek = 0;
    for (int i = 0; i < 7; i++) {
      final day = DateUtils.dateOnly(startOfWeek.add(Duration(days: i)));
      if (habit.completedDates.contains(day)) {
        completedInWeek++;
      }
    }
    return completedInWeek / 7.0;
  }
}