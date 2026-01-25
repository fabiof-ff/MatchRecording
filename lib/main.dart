import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:camera/camera.dart';
import 'package:intl/intl.dart';

// Models
import 'models/highlight.dart';

// Controllers
import 'controllers/match_controller.dart';

// Screens
import 'screens/home_screen.dart';
import 'screens/recording_screen.dart';
import 'screens/highlights_screen.dart';

void main() {
  runApp(const MatchRecordingApp());
}

class MatchRecordingApp extends StatelessWidget {
  const MatchRecordingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Match Recording',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
      ),
      themeMode: ThemeMode.system,
      home: const HomeScreen(),
      getPages: [
        GetPage(name: '/', page: () => const HomeScreen()),
        GetPage(name: '/recording', page: () => RecordingScreen()),
        GetPage(name: '/highlights', page: () => const HighlightsScreen()),
      ],
    );
  }
}

