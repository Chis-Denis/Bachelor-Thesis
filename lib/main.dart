import 'package:flutter/material.dart';
import 'screens/main_screen.dart';
import 'repositories/meal_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize the database and repository
  try {
    final repository = MealRepository();
    await repository.initialize();
  } catch (e, stackTrace) {
    // Handle initialization error
    debugPrint('Error initializing database: $e');
    debugPrint('Stack trace: $stackTrace');
  }
  
  runApp(const CalorieTrackApp());
}

class CalorieTrackApp extends StatelessWidget {
  const CalorieTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CalorieTrack',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const MainScreen(),
    );
  }
}

