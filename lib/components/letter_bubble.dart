import 'package:flutter/material.dart';

import 'app_asset_image.dart';

class LetterBubble extends StatelessWidget {
  const LetterBubble({
    super.key,
    required this.letter,
    required this.isSelected,
    this.size = 108,
  });

  final String letter;
  final bool isSelected;
  final double size;

  @override
  Widget build(BuildContext context) {
    final bubble = isSelected ? 'green_bubble_bg' : 'blue_bubble_bg';

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AppAssetImage(bubble, width: size, height: size),
          AppAssetImage(letter, width: size * 0.5, height: size * 0.5),
        ],
      ),
    );
  }
}
