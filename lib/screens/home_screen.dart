// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import '../model/habit.dart';
import '../services/habit_service.dart';
import '../widgets/add_habit_dialog.dart';
import '../widgets/habit_tile.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final HabitService _habitService = HabitService();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _habitService.addListener(_update);
    _initializeService();
  }

  Future<void> _initializeService() async {
    try {
      await _habitService.init();
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _habitService.removeListener(_update);
    _habitService.dispose();
    super.dispose();
  }

  void _update() => setState(() {});

  void _showAddHabitDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AddHabitDialog(
          onAdd: (title) => _habitService.addHabit(title),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Habit Tracker',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                Color(0xFF7E57FF), // Light purple
                Color(0xFF4527A0), // Deep purple
              ],
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _habitService.habits.isEmpty
              ? const Center(
                  child: Text(
                    'No habits yet. Add one to get started!',
                    style: TextStyle(fontSize: 18),
                  ),
                )
              : ListView.builder(
              itemCount: _habitService.habits.length,
              itemBuilder: (context, index) {
                final Habit habit = _habitService.habits[index];
                return HabitTile(habit: habit, habitService: _habitService);
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddHabitDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}