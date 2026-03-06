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
  final List<double> _carTravel = List<double>.filled(3, 0);

  int? _selectedLane;
  bool _isCorrectLane = false;
  bool _isLaneLocked = false;
  bool _soundOn = AudioService.instance.isBackgroundEnabled;
  Timer? _timer;
  Timer? _animationTimer;

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
    _animationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          const AppAssetImage('drivebg', fit: BoxFit.fill),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final scale = min(
                  constraints.maxWidth / 390,
                  constraints.maxHeight / 820,
                ).clamp(0.82, 1.12);
                final roadsWidth = min(constraints.maxWidth * 0.83, 560.0);
                final boardWidth = roadsWidth * 0.86;
                final boardHeight = 94 * scale;
                final roadsTop = boardHeight - (8 * scale);
                final lettersTop = roadsTop + (130 * scale);
                final carBottom = 10 * scale;

                return Padding(
                  padding: EdgeInsets.fromLTRB(
                    14 * scale,
                    10 * scale,
                    14 * scale,
                    10 * scale,
                  ),
                  child: Column(
                    children: [
                      _topBar(scale),
                      SizedBox(height: 4 * scale),
                      Expanded(
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: SizedBox(
                            width: roadsWidth,
                            height: constraints.maxHeight,
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Positioned(
                                  left: 0,
                                  right: 0,
                                  top: roadsTop,
                                  bottom: 0,
                                  child: Row(
                                    children: List<Widget>.generate(3, (lane) {
                                      return Expanded(
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 3 * scale,
                                          ),
                                          child: const AppAssetImage(
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
                                  left: (roadsWidth - boardWidth) / 2,
                                  width: boardWidth,
                                  height: boardHeight,
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      const AppAssetImage(
                                        'Blueboard',
                                        fit: BoxFit.contain,
                                      ),
                                      Text(
                                        'Drive to the letter $_correctLetter',
                                        style: TextStyle(
                                          fontSize: 19 * scale,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Positioned(
                                        right: -14 * scale,
                                        child: IconButton(
                                          onPressed: _next,
                                          iconSize: 70 * scale,
                                          icon: AppAssetImage(
                                            'right_orange_button',
                                            width: 66 * scale,
                                            height: 66 * scale,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Positioned(
                                  left: 0,
                                  right: 0,
                                  top: lettersTop,
                                  child: Row(
                                    children: List<Widget>.generate(3, (laneIndex) {
                                      return Expanded(
                                        child: Center(
                                          child: AppAssetImage(
                                            _laneLetters[laneIndex],
                                            width: 126 * scale,
                                            height: 126 * scale,
                                          ),
                                        ),
                                      );
                                    }),
                                  ),
                                ),
                                Positioned(
                                  left: 0,
                                  right: 0,
                                  bottom: carBottom,
                                  child: Row(
                                    children: List<Widget>.generate(3, (laneIndex) {
                                      final isSelected = _selectedLane == laneIndex;
                                      final isCorrect = isSelected && _isCorrectLane;
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
                                            child: AnimatedSlide(
                                              offset: Offset(
                                                0,
                                                -_carTravel[laneIndex],
                                              ),
                                              duration: Duration(
                                                milliseconds:
                                                    _carTravel[laneIndex] > 1
                                                    ? 900
                                                    : 220,
                                              ),
                                              curve: Curves.easeInOut,
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  border: Border.all(
                                                    color: isCorrect
                                                        ? const Color(
                                                            0xFF21A34F,
                                                          )
                                                        : isWrong
                                                        ? const Color(
                                                            0xFFD34141,
                                                          )
                                                        : Colors.transparent,
                                                    width: 3 * scale,
                                                  ),
                                                ),
                                                child: AppAssetImage(
                                                  carImage,
                                                  width: 110 * scale,
                                                  height: 122 * scale,
                                                ),
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
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _topBar(double scale) {
    return Row(
      children: [
        IconButton(
          onPressed: () => Navigator.of(context).pop(),
          iconSize: 72 * scale,
          icon: AppAssetImage('Home', width: 66 * scale, height: 66 * scale),
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
          iconSize: 72 * scale,
          icon: AppAssetImage(
            _soundOn ? 'sound_on' : 'sound_off',
            width: 66 * scale,
            height: 66 * scale,
          ),
        ),
      ],
    );
  }

  void _tapLane(int index) {
    if (_isLaneLocked) {
      return;
    }
    _timer?.cancel();
    _animationTimer?.cancel();
    final laneLetter = _laneLetters[index];
    final isCorrect = laneLetter == _correctLetter;

    setState(() {
      _selectedLane = index;
      _isCorrectLane = isCorrect;
      _isLaneLocked = true;
      _carTravel[index] = isCorrect ? 5.3 : 0.9;
    });

    if (isCorrect) {
      AudioService.instance.play('carrun');
      _timer = Timer(const Duration(milliseconds: 1100), _next);
    } else {
      AudioService.instance.play('carcrash');
      _animationTimer = Timer(const Duration(milliseconds: 260), () {
        if (!mounted) {
          return;
        }
        setState(() {
          _carTravel[index] = 0;
        });
      });
      _timer = Timer(const Duration(milliseconds: 800), () {
        if (!mounted) {
          return;
        }
        setState(() {
          _selectedLane = null;
          _isLaneLocked = false;
        });
      });
    }
  }

  void _next() {
    _timer?.cancel();
    _animationTimer?.cancel();
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
    _isLaneLocked = false;
    for (var i = 0; i < _carTravel.length; i++) {
      _carTravel[i] = 0;
    }
  }
}
