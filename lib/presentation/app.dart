import 'package:flutter/material.dart';

import 'auth/login_screen.dart';
import 'design/design.dart';

class CalorieTrackApp extends StatelessWidget {
  const CalorieTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CalorieTrack',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: const LoginScreen(),
    );
  }
}
