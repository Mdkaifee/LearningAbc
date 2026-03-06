import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class BackgroundVideo extends StatefulWidget {
  const BackgroundVideo({super.key, required this.assetPath});

  final String assetPath;

  @override
  State<BackgroundVideo> createState() => _BackgroundVideoState();
}

class _BackgroundVideoState extends State<BackgroundVideo> {
  VideoPlayerController? _controller;

  @override
  void initState() {
    super.initState();
    try {
      _controller = VideoPlayerController.asset(widget.assetPath)
        ..setLooping(true)
        ..setVolume(0)
        ..initialize()
            .then((_) {
              if (!mounted) {
                return;
              }
              setState(() {});
              _controller?.play();
            })
            .catchError((_) {});
    } catch (_) {
      _controller = null;
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) {
      return const SizedBox.shrink();
    }

    return FittedBox(
      fit: BoxFit.cover,
      child: SizedBox(
        width: controller.value.size.width,
        height: controller.value.size.height,
        child: VideoPlayer(controller),
      ),
    );
  }
}
