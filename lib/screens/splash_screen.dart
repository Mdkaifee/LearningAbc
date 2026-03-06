import 'dart:async';

import 'package:flutter/material.dart';

import '../components/app_asset_image.dart';
import '../controllers/music_controller.dart';
import '../services/audio_service.dart';
import 'main_menu_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, required this.musicController});

  final MusicController musicController;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
    _animation = CurvedAnimation(parent: _controller, curve: Curves.elasticOut);
    AudioService.instance.ensureBackgroundPlayback();

    Timer(const Duration(seconds: 2), () {
      if (!mounted) {
        return;
      }
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) =>
              MainMenuScreen(musicController: widget.musicController),
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          const AppAssetImage('splash_screen', fit: BoxFit.cover),
          Center(
            child: ScaleTransition(
              scale: _animation,
              child: const AppAssetImage(
                'splash_logo',
                width: 280,
                height: 280,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
