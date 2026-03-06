import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../../components/app_asset_image.dart';
import '../../data/alphabet_data.dart';
import '../../services/audio_service.dart';

class PickAnimalScreen extends StatefulWidget {
  const PickAnimalScreen({super.key});

  @override
  State<PickAnimalScreen> createState() => _PickAnimalScreenState();
}

class _PickAnimalScreenState extends State<PickAnimalScreen> {
  final List<String> _letters = buildAlphabetLetters();
  final Random _random = Random();

  int _letterIndex = 0;
  List<String> _options = <String>[];
  String? _correctSelection;
  String? _wrongSelection;
  Timer? _timer;

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
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          const AppAssetImage('bg5', fit: BoxFit.cover),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        iconSize: 68,
                        icon: const AppAssetImage(
                          'Home',
                          width: 64,
                          height: 64,
                        ),
                      ),
                    ],
                  ),
                  _header(),
                  const SizedBox(height: 12),
                  Expanded(
                    child: Center(
                      child: Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 18,
                        runSpacing: 18,
                        children: _options.map((option) {
                          return _StoneOption(
                            letter: option,
                            isWrong: _wrongSelection == option,
                            isCorrect: _correctSelection == option,
                            onTap: () => _handleSelection(option),
                          );
                        }).toList(),
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

  Widget _header() {
    return Column(
      children: [
        const AppAssetImage('blue_bubble_bg', width: 116, height: 116),
        Transform.translate(
          offset: const Offset(0, -74),
          child: AppAssetImage(_currentLetter, width: 54, height: 54),
        ),
        Transform.translate(
          offset: const Offset(0, -46),
          child: SizedBox(
            height: 140,
            child: Stack(
              alignment: Alignment.center,
              children: [
                const AppAssetImage('Pick_name_bubble', fit: BoxFit.contain),
                Positioned(
                  left: 0,
                  child: IconButton(
                    onPressed: _previous,
                    iconSize: 62,
                    icon: const AppAssetImage(
                      'left_green_button',
                      width: 58,
                      height: 58,
                    ),
                  ),
                ),
                Positioned(
                  right: 0,
                  child: IconButton(
                    onPressed: _next,
                    iconSize: 62,
                    icon: const AppAssetImage(
                      'right_orange_button',
                      width: 58,
                      height: 58,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 62),
                  child: Text(
                    'Which animal name\nbegins with $_currentLetter?',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _handleSelection(String selectedOption) {
    _timer?.cancel();
    if (selectedOption.toUpperCase() == _currentLetter) {
      setState(() {
        _correctSelection = selectedOption;
        _wrongSelection = null;
      });
      AudioService.instance.play('applause');
      _timer = Timer(const Duration(milliseconds: 1100), _next);
    } else {
      setState(() {
        _wrongSelection = selectedOption;
        _correctSelection = null;
      });
      AudioService.instance.play('cartoonwrong');
      _timer = Timer(const Duration(milliseconds: 550), () {
        if (!mounted) {
          return;
        }
        setState(() => _wrongSelection = null);
      });
    }
  }

  void _next() {
    setState(() {
      _letterIndex = (_letterIndex + 1) % _letters.length;
      _loadQuestion();
    });
  }

  void _previous() {
    setState(() {
      if (_letterIndex == 0) {
        _letterIndex = _letters.length - 1;
      } else {
        _letterIndex--;
      }
      _loadQuestion();
    });
  }

  void _loadQuestion() {
    final others = _letters.where((letter) => letter != _currentLetter).toList()
      ..shuffle(_random);
    _options = [
      _currentLetter.toLowerCase(),
      ...others.take(2).map((e) => e.toLowerCase()),
    ]..shuffle(_random);

    _correctSelection = null;
    _wrongSelection = null;

    final animal =
        animalByLetter[_currentLetter]?.toLowerCase().replaceAll(
          RegExp(r'[^a-z]'),
          '',
        ) ??
        '';

    Future<void>.delayed(const Duration(milliseconds: 700), () {
      if (!mounted) {
        return;
      }
      AudioService.instance.play(
        'animalname',
        onComplete: () async {
          await AudioService.instance.play(
            '${_currentLetter}_$animal',
            onComplete: () async {
              await AudioService.instance.play('spell_$_currentLetter');
            },
          );
        },
      );
    });
  }
}

class _StoneOption extends StatelessWidget {
  const _StoneOption({
    required this.letter,
    required this.isWrong,
    required this.isCorrect,
    required this.onTap,
  });

  final String letter;
  final bool isWrong;
  final bool isCorrect;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final borderColor = isCorrect
        ? const Color(0xFF2EA757)
        : isWrong
        ? const Color(0xFFD84949)
        : Colors.transparent;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: borderColor, width: 4),
          borderRadius: BorderRadius.circular(120),
        ),
        child: AppAssetImage('stone_$letter', width: 150, height: 150),
      ),
    );
  }
}
