import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../../components/app_asset_image.dart';
import '../../data/alphabet_data.dart';
import '../../services/audio_service.dart';

class DriveLetterScreen extends StatefulWidget {
  const DriveLetterScreen({super.key});

  @override
  State<DriveLetterScreen> createState() => _DriveLetterScreenState();
}

class _DriveLetterScreenState extends State<DriveLetterScreen> {
  final List<String> _alphabet = buildAlphabetLetters();
  final Random _random = Random();

  int _letterIndex = 0;
  late String _correctLetter;
  late List<String> _laneLetters;

  int? _selectedLane;
  bool _isCorrectLane = false;
  bool _soundOn = AudioService.instance.isBackgroundEnabled;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _loadRound();
    AudioService.instance.play(
      'Attention',
      onComplete: () async {
        await AudioService.instance.play('carenginestart');
      },
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context).size;
    final roadsWidth = min(screen.width * 0.82, 560.0);

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          const AppAssetImage('drivebg', fit: BoxFit.cover),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
              child: Column(
                children: [
                  _topBar(),
                  const SizedBox(height: 4),
                  Expanded(
                    child: Center(
                      child: SizedBox(
                        width: roadsWidth,
                        child: Stack(
                          children: [
                            Positioned.fill(
                              top: 64,
                              child: Row(
                                children: List<Widget>.generate(3, (lane) {
                                  return Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 3,
                                      ),
                                      child: AppAssetImage(
                                        'road',
                                        fit: BoxFit.fill,
                                      ),
                                    ),
                                  );
                                }),
                              ),
                            ),
                            Positioned(
                              top: 0,
                              left: 0,
                              right: 0,
                              child: SizedBox(
                                height: 92,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    const AppAssetImage(
                                      'Blueboard',
                                      fit: BoxFit.contain,
                                    ),
                                    Text(
                                      'Drive to the letter $_correctLetter',
                                      style: const TextStyle(
                                        fontSize: 19,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Positioned(
                                      right: -6,
                                      child: IconButton(
                                        onPressed: _next,
                                        iconSize: 70,
                                        icon: const AppAssetImage(
                                          'right_orange_button',
                                          width: 66,
                                          height: 66,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Positioned.fill(
                              top: 165,
                              child: Row(
                                children: List<Widget>.generate(3, (laneIndex) {
                                  return Expanded(
                                    child: Center(
                                      child: AppAssetImage(
                                        _laneLetters[laneIndex],
                                        width: 86,
                                        height: 86,
                                      ),
                                    ),
                                  );
                                }),
                              ),
                            ),
                            Positioned(
                              left: 0,
                              right: 0,
                              bottom: 10,
                              child: Row(
                                children: List<Widget>.generate(3, (laneIndex) {
                                  final isSelected = _selectedLane == laneIndex;
                                  final isCorrect =
                                      isSelected && _isCorrectLane;
                                  final isWrong = isSelected && !_isCorrectLane;

                                  final carImage = laneIndex == 0
                                      ? 'greencar'
                                      : laneIndex == 1
                                      ? 'redcar'
                                      : 'yellowcar';

                                  return Expanded(
                                    child: Center(
                                      child: GestureDetector(
                                        onTap: () => _tapLane(laneIndex),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                            border: Border.all(
                                              color: isCorrect
                                                  ? const Color(0xFF21A34F)
                                                  : isWrong
                                                  ? const Color(0xFFD34141)
                                                  : Colors.transparent,
                                              width: 3,
                                            ),
                                          ),
                                          child: AppAssetImage(
                                            carImage,
                                            width: 98,
                                            height: 108,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                              ),
                            ),
                          ],
                        ),
                      ),
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

  Widget _topBar() {
    return Row(
      children: [
        IconButton(
          onPressed: () => Navigator.of(context).pop(),
          iconSize: 72,
          icon: const AppAssetImage('Home', width: 66, height: 66),
        ),
        const Spacer(),
        IconButton(
          onPressed: () async {
            await AudioService.instance.toggleBackgroundEnabled();
            if (!mounted) {
              return;
            }
            setState(
              () => _soundOn = AudioService.instance.isBackgroundEnabled,
            );
          },
          iconSize: 72,
          icon: AppAssetImage(
            _soundOn ? 'sound_on' : 'sound_off',
            width: 66,
            height: 66,
          ),
        ),
      ],
    );
  }

  void _tapLane(int index) {
    _timer?.cancel();
    final laneLetter = _laneLetters[index];
    final isCorrect = laneLetter == _correctLetter;

    setState(() {
      _selectedLane = index;
      _isCorrectLane = isCorrect;
    });

    if (isCorrect) {
      AudioService.instance.play('carrun');
      _timer = Timer(const Duration(milliseconds: 1100), _next);
    } else {
      AudioService.instance.play('carcrash');
      _timer = Timer(const Duration(milliseconds: 800), () {
        if (!mounted) {
          return;
        }
        setState(() => _selectedLane = null);
      });
    }
  }

  void _next() {
    _timer?.cancel();
    setState(() {
      _letterIndex = (_letterIndex + 1) % _alphabet.length;
      _loadRound();
    });
  }

  void _loadRound() {
    _correctLetter = _alphabet[_letterIndex];
    final wrongPool = _alphabet.where((l) => l != _correctLetter).toList()
      ..shuffle(_random);
    _laneLetters = [_correctLetter, wrongPool[0], wrongPool[1]]
      ..shuffle(_random);
    _selectedLane = null;
    _isCorrectLane = false;
  }
}
