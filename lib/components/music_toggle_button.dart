import 'package:flutter/material.dart';

import '../controllers/music_controller.dart';
import 'app_asset_image.dart';

class MusicToggleButton extends StatelessWidget {
  const MusicToggleButton({super.key, required this.controller});

  final MusicController controller;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: controller,
      builder: (context, isOn, _) {
        return IconButton(
          onPressed: () => controller.toggle(),
          iconSize: 64,
          splashRadius: 34,
          tooltip: isOn ? 'Music on' : 'Music off',
          icon: AppAssetImage(
            isOn ? 'sound_on' : 'sound_off',
            width: 54,
            height: 54,
          ),
        );
      },
    );
  }
}
