import 'package:flutter/material.dart';

import '../../components/app_asset_image.dart';
import '../../components/letter_bubble.dart';
import '../../data/alphabet_data.dart';
import '../../services/audio_service.dart';

class AbcAlphabetScreen extends StatefulWidget {
  const AbcAlphabetScreen({super.key});

  @override
  State<AbcAlphabetScreen> createState() => _AbcAlphabetScreenState();
}

class _AbcAlphabetScreenState extends State<AbcAlphabetScreen> {
  static const int _pageSize = 3;

  int _startIndex = 0;
  int? _selectedIndex;
  final Set<int> _revealed = <int>{};

  bool get _isOnLastPage => _startIndex >= _lastPageStart;

  int get _lastPageStart {
    final remainder = alphabetEntries.length % _pageSize;
    if (remainder == 0) {
      return alphabetEntries.length - _pageSize;
    }
    return alphabetEntries.length - remainder;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          const AppAssetImage('Learning_bg', fit: BoxFit.cover),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        iconSize: 68,
                        splashRadius: 36,
                        icon: const AppAssetImage(
                          'Home',
                          width: 64,
                          height: 64,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 4,
                    ),
                    itemCount: _pageSize,
                    itemBuilder: (context, row) {
                      final absoluteIndex = _startIndex + row;
                      if (absoluteIndex >= alphabetEntries.length) {
                        return const SizedBox(height: 40);
                      }
                      final entry = alphabetEntries[absoluteIndex];
                      final isSelected = _selectedIndex == absoluteIndex;
                      final isRevealed = _revealed.contains(absoluteIndex);

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: () => _select(absoluteIndex),
                              child: LetterBubble(
                                letter: entry.letterImageName,
                                isSelected: isSelected,
                                size: 112,
                              ),
                            ),
                            const SizedBox(width: 12),
                            AnimatedOpacity(
                              opacity: isSelected ? 1 : 0,
                              duration: const Duration(milliseconds: 180),
                              child: const AppAssetImage(
                                'handpointer',
                                width: 44,
                                height: 44,
                              ),
                            ),
                            const SizedBox(width: 14),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 260),
                              width: isRevealed ? 170 : 0,
                              height: isRevealed ? 150 : 0,
                              curve: Curves.easeOut,
                              child: isRevealed
                                  ? AppAssetImage(
                                      entry.animalImageName,
                                      fit: BoxFit.contain,
                                    )
                                  : const SizedBox.shrink(),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 14),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: _startIndex == 0
                            ? null
                            : () => _page(-_pageSize),
                        iconSize: 72,
                        icon: Opacity(
                          opacity: _startIndex == 0 ? 0.45 : 1,
                          child: const AppAssetImage(
                            'left_green_button',
                            width: 68,
                            height: 68,
                          ),
                        ),
                      ),
                      const SizedBox(width: 18),
                      IconButton(
                        onPressed: _isOnLastPage
                            ? null
                            : () => _page(_pageSize),
                        iconSize: 72,
                        icon: Opacity(
                          opacity: _isOnLastPage ? 0.45 : 1,
                          child: const AppAssetImage(
                            'right_orange_button',
                            width: 68,
                            height: 68,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _select(int index) {
    final entry = alphabetEntries[index];
    setState(() {
      _selectedIndex = index;
      _revealed.add(index);
    });

    AudioService.instance.play(
      entry.soundName,
      onComplete: () async {
        if (index == alphabetEntries.length - 1) {
          await AudioService.instance.play('applause');
        }
      },
    );
  }

  void _page(int delta) {
    setState(() {
      _selectedIndex = null;
      _startIndex = (_startIndex + delta).clamp(0, _lastPageStart);
    });
  }
}
