import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../../components/app_asset_image.dart';
import '../../data/alphabet_data.dart';
import '../../services/audio_service.dart';

class FindLetterScreen extends StatefulWidget {
  const FindLetterScreen({super.key});

  @override
  State<FindLetterScreen> createState() => _FindLetterScreenState();
}

class _FindLetterScreenState extends State<FindLetterScreen> {
  final List<String> _letters = buildAlphabetLetters();
  final Random _random = Random();

  int _letterIndex = 0;
  List<String> _options = <String>[];
  String? _wrongSelection;
  String? _correctSelection;
  Timer? _timer;
  bool _soundOn = AudioService.instance.isBackgroundEnabled;

  String get _currentLetter => _letters[_letterIndex];

  @override
  void initState() {
    super.initState();
    _loadQuestion();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final entry = entryForLetter(_currentLetter);
    final animalLabel = _footerAnimalLabel(_currentLetter, entry?.animalName);
    final animalImage = _footerAnimalImage(_currentLetter, entry?.animalImageName);

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          const AppAssetImage('pick_bg', fit: BoxFit.cover),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final rawScale = min(
                  constraints.maxHeight / 840,
                  constraints.maxWidth / 390,
                );
                final scale = rawScale.clamp(0.8, 1.0);
                final contentWidth = constraints.maxWidth - (28 * scale);
                final footerBottomInset = max(10.0, constraints.maxHeight * 0.14);

                return Padding(
                  padding: EdgeInsets.fromLTRB(
                    14 * scale,
                    8 * scale,
                    14 * scale,
                    8 * scale,
                  ),
                  child: Column(
                    children: [
                      _topBar(scale),
                      SizedBox(height: 1 * scale),
                      _header(scale, contentWidth),
                      SizedBox(height: 2 * scale),
                      Expanded(
                        child: Stack(
                          children: [
                            Align(
                              alignment: Alignment.topCenter,
                              child: Transform.translate(
                                offset: Offset(0, -4 * scale),
                                child: _bubbleGrid(
                                  scale: scale,
                                  contentWidth: contentWidth,
                                ),
                              ),
                            ),
                            Positioned(
                              left: 0,
                              right: 0,
                              bottom: footerBottomInset,
                              child: _animalFooter(
                                scale: scale,
                                animalLabel: animalLabel,
                                animalImage: animalImage,
                              ),
                            ),
                          ],
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
      crossAxisAlignment: CrossAxisAlignment.start,
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

  Widget _topLetterTile(double scale) {
    return SizedBox(
      width: 96 * scale,
      height: 96 * scale,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          AppAssetImage('blue_bubble_bg', width: 96 * scale, height: 96 * scale),
          Transform.translate(
            offset: Offset(0, -10 * scale),
            child: AppAssetImage(
              _currentLetter,
              width: 52 * scale,
              height: 52 * scale,
            ),
          ),
        ],
      ),
    );
  }

  Widget _header(double scale, double contentWidth) {
    final bannerWidth = min(contentWidth, 330 * scale);
    return SizedBox(
      width: bannerWidth,
      height: 152 * scale,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          Positioned(
            top: 28 * scale,
            left: 0,
            right: 0,
            child: SizedBox(
              height: 124 * scale,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const AppAssetImage('Pick_name_bubble', fit: BoxFit.contain),
                  Positioned(
                    right: 8 * scale,
                    child: IconButton(
                      onPressed: _next,
                      iconSize: 68 * scale,
                      icon: AppAssetImage(
                        'right_orange_button',
                        width: 64 * scale,
                        height: 64 * scale,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 52 * scale),
                    child: Text(
                      'Find the\nletter $_currentLetter?',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 21 * scale,
                        fontWeight: FontWeight.w900,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Transform.translate(
            offset: Offset(0, -35 * scale),
            child: _topLetterTile(scale),
          ),
        ],
      ),
    );
  }

  Widget _animalFooter({
    required double scale,
    required String animalLabel,
    required String animalImage,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Flexible(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _currentLetter,
                style: TextStyle(
                  fontSize: 62 * scale,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFFE04C17),
                  height: 0.9,
                ),
              ),
              Text(
                animalLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 19 * scale,
                  color: const Color(0xFFC84E1F),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 12 * scale),
        ClipRect(
          child: SizedBox(
            width: 120 * scale,
            height: 106 * scale,
            child: Align(
              alignment: Alignment.topCenter,
              heightFactor: 0.82,
              child: AppAssetImage(
                animalImage,
                width: 122 * scale,
                height: 122 * scale,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _bubbleGrid({required double scale, required double contentWidth}) {
    final rows = <int>[4, 3, 4, 2];
    var cursor = 0;
    final maxSlots = rows.reduce(max);
    final baseBubbleSize = (contentWidth / maxSlots).clamp(68.0, 86.0);
    final bubbleSize = baseBubbleSize + (8 * scale);
    const horizontalOverlapFactor = 0.74;
    const verticalOverlapFactor = 0.78;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: rows.map((count) {
        final rowOptions = _options.sublist(cursor, cursor + count);
        cursor += count;

        return Align(
          heightFactor: verticalOverlapFactor,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: rowOptions.map((option) {
              final isWrong = _wrongSelection == option;
              final isCorrect = _correctSelection == option;

              return Align(
                widthFactor: horizontalOverlapFactor,
                child: GestureDetector(
                  onTap: () => _select(option),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(bubbleSize / 2),
                      border: Border.all(
                        color: isCorrect
                            ? const Color(0xFF2EAF5F)
                            : isWrong
                            ? const Color(0xFFD84949)
                            : Colors.transparent,
                        width: 3 * scale,
                      ),
                    ),
                    child: SizedBox(
                      width: bubbleSize,
                      height: bubbleSize,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          const AppAssetImage('bluecircle', fit: BoxFit.contain),
                          AppAssetImage(
                            option.toUpperCase(),
                            width: bubbleSize * 0.55,
                            height: bubbleSize * 0.55,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      }).toList(),
    );
  }

  void _select(String picked) {
    _timer?.cancel();
    if (picked.toUpperCase() == _currentLetter) {
      setState(() {
        _correctSelection = picked;
        _wrongSelection = null;
      });
      AudioService.instance.play('applause');
      _timer = Timer(const Duration(milliseconds: 1000), _next);
    } else {
      setState(() {
        _wrongSelection = picked;
        _correctSelection = null;
      });
      AudioService.instance.play('cartoonwrong');
      _timer = Timer(const Duration(milliseconds: 500), () {
        if (!mounted) {
          return;
        }
        setState(() => _wrongSelection = null);
      });
    }
  }

  void _next() {
    _timer?.cancel();
    setState(() {
      _letterIndex = (_letterIndex + 1) % _letters.length;
      _loadQuestion();
    });
  }

  void _loadQuestion() {
    final all = buildAlphabetLetters().map((e) => e.toLowerCase()).toList();
    final wrongs = all.where((l) => l.toUpperCase() != _currentLetter).toList()
      ..shuffle(_random);
    _options = [_currentLetter.toLowerCase(), ...wrongs.take(12)]
      ..shuffle(_random);

    _wrongSelection = null;
    _correctSelection = null;

    Future<void>.delayed(const Duration(milliseconds: 700), () {
      if (!mounted) {
        return;
      }
      AudioService.instance.play(
        'findtheletter',
        onComplete: () async {
          await AudioService.instance.play('spell_$_currentLetter');
        },
      );
    });
  }

  String _footerAnimalLabel(String letter, String? fallback) {
    return (fallback ?? '').toUpperCase();
  }

  String _footerAnimalImage(String letter, String? fallback) {
    return fallback ?? 'Monkey';
  }
}
