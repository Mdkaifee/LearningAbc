import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../../components/app_asset_image.dart';
import '../../data/alphabet_data.dart';
import '../../services/audio_service.dart';

class SpellAnimalScreen extends StatefulWidget {
  const SpellAnimalScreen({super.key});

  @override
  State<SpellAnimalScreen> createState() => _SpellAnimalScreenState();
}

class _SpellAnimalScreenState extends State<SpellAnimalScreen> {
  final List<String> _letters = buildAlphabetLetters();
  final Random _random = Random();

  int _currentLetterIndex = 0;
  List<_SlotContent?> _topSlots = <_SlotContent?>[];
  List<bool> _tileUsed = <bool>[];
  List<int> _shuffledOrder = <int>[];

  bool _isWrong = false;
  Timer? _advanceTimer;

  String get _currentLetter => _letters[_currentLetterIndex];

  String get _targetWord => spellTargetWord(_currentLetter);

  List<String> get _targetChars => _targetWord.split('');

  String get _shadowImageName => 'shadow_${_currentLetter.toLowerCase()}';

  @override
  void initState() {
    super.initState();
    _resetRound();
    _playRoundPrompt();
  }

  @override
  void dispose() {
    _advanceTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          const AppAssetImage('spell_bg', fit: BoxFit.cover),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
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
                  const SizedBox(height: 6),
                  _slotRow(),
                  const SizedBox(height: 10),
                  Expanded(
                    child: Center(
                      child: AppAssetImage(
                        _shadowImageName,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: IconButton(
                            onPressed: _currentLetterIndex == 0
                                ? null
                                : _previousLetter,
                            iconSize: 72,
                            icon: Opacity(
                              opacity: _currentLetterIndex == 0 ? 0.45 : 1,
                              child: const AppAssetImage(
                                'spell_arrow_left',
                                width: 66,
                                height: 66,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: IconButton(
                            onPressed:
                                _currentLetterIndex == _letters.length - 1
                                ? null
                                : _nextLetter,
                            iconSize: 72,
                            icon: Opacity(
                              opacity:
                                  _currentLetterIndex == _letters.length - 1
                                  ? 0.45
                                  : 1,
                              child: const AppAssetImage(
                                'spell_arrow_right',
                                width: 66,
                                height: 66,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _tileRow(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _slotRow() {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 2,
      runSpacing: 2,
      children: List<Widget>.generate(_topSlots.length, (i) {
        final slot = _topSlots[i];
        return GestureDetector(
          onTap: slot == null
              ? null
              : () {
                  setState(() {
                    _tileUsed[slot.sourceTileIndex] = false;
                    _topSlots[i] = null;
                    _isWrong = false;
                  });
                },
          child: SizedBox(
            width: 42,
            height: 58,
            child: Stack(
              alignment: Alignment.center,
              children: [
                const AppAssetImage('blue_square_box', width: 40, height: 58),
                if (slot != null)
                  Text(
                    slot.letter,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: _isWrong ? Colors.red : Colors.white,
                    ),
                  ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _tileRow() {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 2,
      runSpacing: 2,
      children: _shuffledOrder.map((tileIndex) {
        final used = _tileUsed[tileIndex];
        final char = _targetChars[tileIndex];

        return GestureDetector(
          onTap: used ? null : () => _placeTile(tileIndex),
          child: Opacity(
            opacity: used ? 0.2 : 1,
            child: SizedBox(
              width: 46,
              height: 62,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const AppAssetImage('wine_square_box', width: 44, height: 60),
                  Text(
                    char,
                    style: const TextStyle(
                      fontSize: 30,
                      color: Color(0xFFF9CCE0),
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  void _placeTile(int sourceTileIndex) {
    final slotIndex = _topSlots.indexWhere((slot) => slot == null);
    if (slotIndex == -1) {
      return;
    }

    final placed = _targetChars[sourceTileIndex];
    AudioService.instance.play('spell_$placed');

    setState(() {
      _topSlots[slotIndex] = _SlotContent(
        letter: placed,
        sourceTileIndex: sourceTileIndex,
      );
      _tileUsed[sourceTileIndex] = true;
      _isWrong = false;
    });

    _checkCompletion();
  }

  void _checkCompletion() {
    if (_topSlots.any((slot) => slot == null)) {
      return;
    }

    final attempt = _topSlots.map((slot) => slot!.letter).join();
    if (attempt == _targetWord) {
      _advanceTimer?.cancel();
      AudioService.instance.play('applause');
      _advanceTimer = Timer(const Duration(seconds: 2), _nextLetter);
    } else {
      AudioService.instance.play('cartoonwrong');
      setState(() => _isWrong = true);
      Future<void>.delayed(const Duration(milliseconds: 700), () {
        if (!mounted) {
          return;
        }
        setState(_resetRound);
      });
    }
  }

  void _playRoundPrompt() {
    final animal =
        animalByLetter[_currentLetter]?.toLowerCase().replaceAll(
          RegExp(r'[^a-z]'),
          '',
        ) ??
        '';
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
  }

  void _nextLetter() {
    _advanceTimer?.cancel();
    setState(() {
      if (_currentLetterIndex < _letters.length - 1) {
        _currentLetterIndex++;
      } else {
        _currentLetterIndex = 0;
      }
      _resetRound();
    });
    _playRoundPrompt();
  }

  void _previousLetter() {
    _advanceTimer?.cancel();
    setState(() {
      if (_currentLetterIndex > 0) {
        _currentLetterIndex--;
      }
      _resetRound();
    });
    _playRoundPrompt();
  }

  void _resetRound() {
    final count = _targetChars.length;
    _topSlots = List<_SlotContent?>.filled(count, null);
    _tileUsed = List<bool>.filled(count, false);
    _shuffledOrder = List<int>.generate(count, (i) => i)..shuffle(_random);
    _isWrong = false;
  }
}

class _SlotContent {
  const _SlotContent({required this.letter, required this.sourceTileIndex});

  final String letter;
  final int sourceTileIndex;
}
