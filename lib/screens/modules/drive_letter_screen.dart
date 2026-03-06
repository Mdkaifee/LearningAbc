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
  final List<double> _carTravelPx = List<double>.filled(3, 0);

  bool _isLaneLocked = false;
  bool _soundOn = AudioService.instance.isBackgroundEnabled;
  Timer? _timer;
  Timer? _animationTimer;
  double _correctTravelDistancePx = 520;
  double _wrongTravelDistancePx = 90;

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
                        child: LayoutBuilder(
                          builder: (context, gameArea) {
                            final availableWidth = gameArea.maxWidth;
                            final availableHeight = gameArea.maxHeight;

                            final roadsWidth = min(availableWidth * 1.00, 820.0);
                            final laneHorizontalGap = 2.0 * scale;
                            final laneRoadWidth =
                                (roadsWidth / 3) - (laneHorizontalGap * 2);
                            final arenaHeight = min(
                              availableHeight * 0.92,
                              roadsWidth * 1.95,
                            );

                            final boardWidth = roadsWidth * 1.42;
                            final boardHeight = 54 * scale;

                            final roadsTop = -40 * scale;
                            final roadsBottom = -220 * scale;
                            final boardTop = roadsTop + (80 * scale);
                            final lettersTop = roadsTop + (304 * scale);
                            final letterBoxHeight = laneRoadWidth;
                            final carBottom = 52 * scale;

                            final carWidth = laneRoadWidth * 0.66;
                            final carHeight = carWidth * 1.20;

                            final carStartTop = arenaHeight - carBottom - carHeight;
                            final targetCarTop = lettersTop + (10 * scale);

                            _correctTravelDistancePx = max(
                              0.0,
                              carStartTop - targetCarTop,
                            );
                            _wrongTravelDistancePx = min(
                              _correctTravelDistancePx * 0.16,
                              85 * scale,
                            );

                            return Align(
                              alignment: Alignment.topCenter,
                              child: SizedBox(
                                width: roadsWidth,
                                height: arenaHeight,
                                child: Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    Positioned(
                                      left: 0,
                                      right: 0,
                                      top: roadsTop,
                                      bottom: roadsBottom,
                                      child: Row(
                                        children: List<Widget>.generate(3, (lane) {
                                          return Expanded(
                                            child: Padding(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: laneHorizontalGap,
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
                                      top: boardTop,
                                      left: (roadsWidth - boardWidth) / 2,
                                      width: boardWidth,
                                      height: boardHeight,
                                      child: Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          const AppAssetImage(
                                            'Blueboard',
                                            fit: BoxFit.fill,
                                          ),
                                          Padding(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 34 * scale,
                                            ),
                                            child: FittedBox(
                                              fit: BoxFit.scaleDown,
                                              child: Text(
                                                'Drive to the letter $_correctLetter',
                                                maxLines: 1,
                                                style: TextStyle(
                                                  fontSize: 20 * scale,
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Positioned(
                                      top: boardTop + (boardHeight - (66 * scale)) / 2,
                                      right: -(10 * scale),
                                      child: IconButton(
                                        splashColor: Colors.transparent,
                                        highlightColor: Colors.transparent,
                                        hoverColor: Colors.transparent,
                                        onPressed: _next,
                                        iconSize: 70 * scale,
                                        icon: AppAssetImage(
                                          'right_orange_button',
                                          width: 46 * scale,
                                          height: 46 * scale,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      left: 0,
                                      right: 0,
                                      top: lettersTop,
                                      child: Row(
                                        children: List<Widget>.generate(3, (laneIndex) {
                                          return Expanded(
                                            child: Padding(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: laneHorizontalGap,
                                              ),
                                              child: SizedBox(
                                                height: letterBoxHeight,
                                                child: Center(
                                                  child: AppAssetImage(
                                                    _laneLetters[laneIndex],
                                                    width: laneRoadWidth * 0.72,
                                                    height: laneRoadWidth * 0.72,
                                                  ),
                                                ),
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
                                          final carImage = laneIndex == 0
                                              ? 'greencar'
                                              : laneIndex == 1
                                                  ? 'redcar'
                                                  : 'yellowcar';

                                          final isLongRun =
                                              _carTravelPx[laneIndex] >
                                                  _wrongTravelDistancePx + 1;

                                          final durationMs =
                                              _carTravelPx[laneIndex] > 0
                                                  ? (isLongRun ? 1500 : 260)
                                                  : 220;

                                          return Expanded(
                                            child: Padding(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: laneHorizontalGap,
                                              ),
                                              child: Center(
                                                child: GestureDetector(
                                                  behavior: HitTestBehavior.opaque,
                                                  onTap: () => _tapLane(laneIndex),
                                                  child: AnimatedContainer(
                                                    duration: Duration(
                                                      milliseconds: durationMs,
                                                    ),
                                                    curve: Curves.easeInOut,
                                                    transform:
                                                        Matrix4.translationValues(
                                                      0,
                                                      -_carTravelPx[laneIndex],
                                                      0,
                                                    ),
                                                    child: AppAssetImage(
                                                      carImage,
                                                      width: carWidth,
                                                      height: carHeight,
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
                            );
                          },
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
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          hoverColor: Colors.transparent,
          onPressed: () => Navigator.of(context).pop(),
          iconSize: 72 * scale,
          icon: AppAssetImage(
            'Home',
            width: 66 * scale,
            height: 66 * scale,
          ),
        ),
        const Spacer(),
        IconButton(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          hoverColor: Colors.transparent,
          onPressed: () async {
            await AudioService.instance.toggleBackgroundEnabled();
            if (!mounted) {
              return;
            }
            setState(() {
              _soundOn = AudioService.instance.isBackgroundEnabled;
            });
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
      _isLaneLocked = true;
      _carTravelPx[index] = isCorrect
          ? _correctTravelDistancePx
          : _wrongTravelDistancePx;
    });

    if (isCorrect) {
      AudioService.instance.play('carrun');
      _timer = Timer(const Duration(milliseconds: 1650), _next);
    } else {
      AudioService.instance.play('carcrash');
      _animationTimer = Timer(const Duration(milliseconds: 260), () {
        if (!mounted) {
          return;
        }
        setState(() {
          _carTravelPx[index] = 0;
        });
      });
      _timer = Timer(const Duration(milliseconds: 800), () {
        if (!mounted) {
          return;
        }
        setState(() {
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

    _isLaneLocked = false;

    for (var i = 0; i < _carTravelPx.length; i++) {
      _carTravelPx[i] = 0;
    }
  }
}
