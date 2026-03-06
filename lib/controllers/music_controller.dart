import 'package:flutter/foundation.dart';

import '../services/audio_service.dart';

class MusicController extends ValueNotifier<bool> {
  MusicController({bool initialValue = true}) : super(initialValue) {
    AudioService.instance.init();
    AudioService.instance.setBackgroundEnabled(initialValue);
  }

  Future<void> toggle() async {
    value = !value;
    await AudioService.instance.setBackgroundEnabled(value);
  }
}
