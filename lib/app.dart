import 'package:flutter/material.dart';

import 'controllers/music_controller.dart';
import 'screens/splash_screen.dart';

class AbcLearningApp extends StatefulWidget {
  const AbcLearningApp({super.key});

  @override
  State<AbcLearningApp> createState() => _AbcLearningAppState();
}

class _AbcLearningAppState extends State<AbcLearningApp> {
  late final MusicController musicController;

  @override
  void initState() {
    super.initState();
    musicController = MusicController(initialValue: true);
  }

  @override
  void dispose() {
    musicController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ABC Learning',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF4F7FF),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1E88E5)),
        textTheme: Theme.of(context).textTheme.apply(fontFamily: 'Avenir'),
      ),
      home: SplashScreen(musicController: musicController),
    );
  }
}
