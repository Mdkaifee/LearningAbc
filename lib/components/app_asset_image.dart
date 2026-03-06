import 'package:flutter/material.dart';

import '../data/image_manifest.dart';

class AppAssetImage extends StatelessWidget {
  const AppAssetImage(
    this.name, {
    super.key,
    this.fit = BoxFit.contain,
    this.width,
    this.height,
    this.alignment = Alignment.center,
  });

  final String name;
  final BoxFit fit;
  final double? width;
  final double? height;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      img(name),
      fit: fit,
      width: width,
      height: height,
      alignment: alignment,
      errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
    );
  }
}
