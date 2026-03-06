import 'package:flutter/material.dart';

import '../components/app_asset_image.dart';
import '../components/background_video.dart';
import '../components/menu_tile.dart';
import '../components/music_toggle_button.dart';
import '../controllers/music_controller.dart';
import '../data/menu_modules.dart';
import '../models/menu_module.dart';
import '../services/audio_service.dart';
import 'about_screen.dart';
import 'modules/abc_alphabet_screen.dart';
import 'modules/drive_letter_screen.dart';
import 'modules/find_letter_screen.dart';
import 'modules/pick_animal_screen.dart';
import 'modules/spell_animal_screen.dart';
import 'modules/trace_letter_screen.dart';

class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({super.key, required this.musicController});

  final MusicController musicController;

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  @override
  void initState() {
    super.initState();
    AudioService.instance.ensureBackgroundPlayback();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          const BackgroundVideo(assetPath: 'assets/video/main_background.mp4'),
          const AppAssetImage('main_background', fit: BoxFit.cover),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      MusicToggleButton(controller: widget.musicController),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const AboutScreen(),
                            ),
                          );
                        },
                        icon: const Icon(
                          Icons.info,
                          color: Colors.white,
                          size: 32,
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.black.withValues(alpha: 0.35),
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final isLandscape =
                            constraints.maxWidth > constraints.maxHeight;
                        final crossAxisCount = isLandscape ? 3 : 2;

                        return GridView.builder(
                          padding: EdgeInsets.only(
                            top: constraints.maxHeight > 700 ? 20 : 8,
                            bottom: 16,
                          ),
                          itemCount: menuModules.length,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: crossAxisCount,
                                crossAxisSpacing: 24,
                                mainAxisSpacing: 24,
                                childAspectRatio: 1.45,
                              ),
                          itemBuilder: (context, index) {
                            final module = menuModules[index];
                            return MenuTile(
                              module: module,
                              onTap: () => _openModule(module.type),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openModule(ModuleType type) async {
    final Widget screen;
    switch (type) {
      case ModuleType.abc:
        screen = const AbcAlphabetScreen();
      case ModuleType.spell:
        screen = const SpellAnimalScreen();
      case ModuleType.pick:
        screen = const PickAnimalScreen();
      case ModuleType.trace:
        screen = const TraceLetterScreen();
      case ModuleType.find:
        screen = const FindLetterScreen();
      case ModuleType.drive:
        screen = const DriveLetterScreen();
    }

    await AudioService.instance.pauseBackground();
    if (!mounted) {
      return;
    }
    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
    await AudioService.instance.ensureBackgroundPlayback();
  }
}
