import 'dart:math';

import 'package:flutter/material.dart';

import '../../components/app_asset_image.dart';
import '../../data/alphabet_data.dart';
import '../../data/trace_dots_data.dart';
import '../../services/audio_service.dart';

class TraceLetterScreen extends StatefulWidget {
  const TraceLetterScreen({super.key});

  @override
  State<TraceLetterScreen> createState() => _TraceLetterScreenState();
}

class _TraceLetterScreenState extends State<TraceLetterScreen> {
  final List<String> _letters = buildAlphabetLetters();

  int _letterIndex = 0;
  bool _soundOn = AudioService.instance.isBackgroundEnabled;

  Color _currentColor = const Color(0xFFFF3A46);
  final List<List<Offset>> _strokes = <List<Offset>>[];
  List<Offset> _currentStroke = <Offset>[];

  late List<Offset> _allDots; // normalized points 0..1
  late List<Offset> _remainingDots; // normalized points 0..1
  bool _isTracing = false;
  bool _completed = false;
  bool _invalidStroke = false;

  static const double _hitRadius = 26;

  String get _currentLetter => _letters[_letterIndex];

  @override
  void initState() {
    super.initState();
    _loadLetter();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final boardWidth = width * 0.86;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          const AppAssetImage('Modulefour', fit: BoxFit.cover),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
              child: Column(
                children: [
                  _topBar(),
                  const SizedBox(height: 8),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          _board(boardWidth),
                          const SizedBox(height: 18),
                          IconButton(
                            onPressed: _next,
                            iconSize: 84,
                            icon: const AppAssetImage(
                              'spell_arrow_right',
                              width: 80,
                              height: 80,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _crayon('redpen', const Color(0xFFFF3A46)),
                              const SizedBox(width: 22),
                              _crayon('pinkpen', const Color(0xFFD95CB0)),
                              const SizedBox(width: 22),
                              _crayon('purplepen', const Color(0xFF8D4DDB)),
                              const SizedBox(width: 22),
                              _crayon('bluepen', const Color(0xFF2F86E9)),
                            ],
                          ),
                        ],
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

  Widget _board(double boardWidth) {
    final boardHeight = boardWidth * 1.4;
    final entry = entryForLetter(_currentLetter);
    final animalImage = _referenceAnimalImage(
      _currentLetter,
      entry?.animalImageName,
    );
    final animalLabel = _englishAnimalLabel(_currentLetter, entry?.animalName);

    return SizedBox(
      width: boardWidth,
      height: boardHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          const Positioned.fill(
            child: AppAssetImage('board', fit: BoxFit.contain),
          ),
          Positioned(
            top: boardHeight * 0.07,
            left: boardWidth * 0.42,
            child: AppAssetImage(
              _currentLetter,
              width: boardWidth * 0.1,
              height: boardWidth * 0.1,
            ),
          ),
          Positioned(
            top: boardHeight * 0.035,
            right: boardWidth * 0.05,
            child: AppAssetImage(animalImage, width: 54, height: 54),
          ),
          Positioned(
            top: boardHeight * 0.085,
            right: boardWidth * 0.05,
            child: Text(
              animalLabel,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w900,
                shadows: [Shadow(color: Colors.black45, blurRadius: 2)],
              ),
            ),
          ),
          Positioned(
            left: boardWidth * 0.12,
            right: boardWidth * 0.12,
            top: boardHeight * 0.21,
            bottom: boardHeight * 0.1,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final size = Size(constraints.maxWidth, constraints.maxHeight);
                final startDot = _remainingDots.isEmpty
                    ? null
                    : _toLocal(_remainingDots.first, size);

                return GestureDetector(
                  onPanStart: (details) =>
                      _onPanStart(details.localPosition, size),
                  onPanUpdate: (details) =>
                      _onPanUpdate(details.localPosition, size),
                  onPanEnd: (_) => _onPanEnd(),
                  child: CustomPaint(
                    painter: _TraceBoardPainter(
                      allDots: _allDots,
                      remainingDots: _remainingDots,
                      strokes: _strokes,
                      currentStroke: _currentStroke,
                      color: _currentColor,
                      completed: _completed,
                      startDot: startDot,
                    ),
                    child: const SizedBox.expand(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _crayon(String image, Color color) {
    final selected = _currentColor == color;
    return GestureDetector(
      onTap: () => setState(() => _currentColor = color),
      child: Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? const Color(0xFF1E8AD8) : Colors.transparent,
            width: 2,
          ),
        ),
        child: AppAssetImage(image, width: 42, height: 92),
      ),
    );
  }

  void _onPanStart(Offset point, Size size) {
    if (_completed || _remainingDots.isEmpty) {
      return;
    }

    final first = _toLocal(_remainingDots.first, size);
    if ((first - point).distance > _hitRadius) {
      return;
    }

    setState(() {
      _isTracing = true;
      _invalidStroke = false;
      _currentStroke = <Offset>[first];
      _remainingDots.removeAt(0);
    });
  }

  void _onPanUpdate(Offset point, Size size) {
    if (!_isTracing || _completed) {
      return;
    }

    setState(() {
      _currentStroke.add(point);

      if (_remainingDots.isEmpty) {
        return;
      }

      final first = _toLocal(_remainingDots.first, size);
      final firstDistance = (first - point).distance;
      if (firstDistance <= _hitRadius) {
        _currentStroke.add(first);
        _remainingDots.removeAt(0);
        return;
      }

      final nearest = _nearestRemaining(point, size);
      if (nearest != null && nearest > 0) {
        _invalidStroke = true;
      }
    });
  }

  void _onPanEnd() {
    if (!_isTracing) {
      return;
    }

    setState(() {
      if (_currentStroke.length >= 2 && !_invalidStroke) {
        _strokes.add(List<Offset>.from(_currentStroke));
      }

      _currentStroke = <Offset>[];
      _isTracing = false;

      if (_remainingDots.isEmpty) {
        _completed = true;
        AudioService.instance.play('applause');
      }
    });
  }

  int? _nearestRemaining(Offset point, Size size) {
    var bestIndex = -1;
    var bestDistance = double.infinity;

    for (var i = 0; i < _remainingDots.length; i++) {
      final p = _toLocal(_remainingDots[i], size);
      final d = (p - point).distance;
      if (d < bestDistance) {
        bestDistance = d;
        bestIndex = i;
      }
    }

    if (bestIndex == -1 || bestDistance > _hitRadius) {
      return null;
    }
    return bestIndex;
  }

  Offset _toLocal(Offset normalized, Size size) {
    return Offset(normalized.dx * size.width, normalized.dy * size.height);
  }

  void _loadLetter() {
    final points = traceDotsFor(_currentLetter);
    _allDots = points;
    _remainingDots = List<Offset>.from(points);
    _strokes.clear();
    _currentStroke = <Offset>[];
    _isTracing = false;
    _invalidStroke = false;
    _completed = false;

    _playPrompt();
  }

  void _playPrompt() {
    AudioService.instance.play(
      'tracetheletter',
      onComplete: () async {
        await AudioService.instance.play('spell_$_currentLetter');
      },
    );
  }

  void _next() {
    setState(() {
      _letterIndex = (_letterIndex + 1) % _letters.length;
      _loadLetter();
    });
  }

  String _referenceAnimalImage(String letter, String? fallback) {
    if (letter == 'A') {
      return 'Fox';
    }
    return fallback ?? 'Monkey';
  }

  String _englishAnimalLabel(String letter, String? fallback) {
    const map = <String, String>{
      'A': 'SQUIRREL',
      'B': 'BEAR',
      'C': 'CAT',
      'D': 'DOG',
      'E': 'ELEPHANT',
      'F': 'FOX',
      'G': 'GIRAFFE',
      'H': 'HIPPO',
      'I': 'IGUANA',
      'J': 'JELLYFISH',
      'K': 'KANGAROO',
      'L': 'LION',
      'M': 'MONKEY',
      'N': 'NUMBAT',
      'O': 'OWL',
      'P': 'PENGUIN',
      'Q': 'QUAIL',
      'R': 'RACCOON',
      'S': 'SHEEP',
      'T': 'TIGER',
      'U': 'UNICORN',
      'V': 'VAMPIRE BAT',
      'W': 'WHALE',
      'X': 'X-RAY FISH',
      'Y': 'YAK',
      'Z': 'ZEBRA',
    };
    return map[letter] ?? (fallback ?? '').toUpperCase();
  }
}

class _TraceBoardPainter extends CustomPainter {
  const _TraceBoardPainter({
    required this.allDots,
    required this.remainingDots,
    required this.strokes,
    required this.currentStroke,
    required this.color,
    required this.completed,
    required this.startDot,
  });

  final List<Offset> allDots; // normalized
  final List<Offset> remainingDots; // normalized
  final List<List<Offset>> strokes; // local
  final List<Offset> currentStroke; // local
  final Color color;
  final bool completed;
  final Offset? startDot;

  @override
  void paint(Canvas canvas, Size size) {
    if (allDots.length < 2) {
      return;
    }

    final guidePath = _buildGuidePath(size);

    final blackGuide = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 22
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final oliveGuide = Paint()
      ..color = const Color(0xFF6C620F)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final finalStrokeOutline = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 24
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final finalStrokeInner = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    if (completed) {
      canvas.drawPath(guidePath, finalStrokeOutline);
      canvas.drawPath(guidePath, finalStrokeInner);
    } else {
      canvas.drawPath(guidePath, blackGuide);
      canvas.drawPath(guidePath, oliveGuide);

      final dotPaint = Paint()..color = const Color(0xFFEDECE6);
      for (final n in allDots) {
        final p = Offset(n.dx * size.width, n.dy * size.height);
        canvas.drawCircle(p, 6, dotPaint);
      }
    }

    for (final stroke in strokes) {
      _drawStroke(canvas, stroke, color);
    }
    _drawStroke(canvas, currentStroke, color);

    if (!completed && startDot != null) {
      final markerPaint = Paint()..color = Colors.white;
      canvas.drawCircle(startDot!, 17, markerPaint);
      final border = Paint()
        ..color = const Color(0xFF222222)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawCircle(startDot!, 17, border);

      final tp = TextPainter(
        text: const TextSpan(
          text: '↗',
          style: TextStyle(
            color: Color(0xFFE64848),
            fontWeight: FontWeight.w900,
            fontSize: 20,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(
        canvas,
        Offset(startDot!.dx - tp.width / 2, startDot!.dy - tp.height / 2),
      );
    }
  }

  Path _buildGuidePath(Size size) {
    final path = Path();
    final pts = allDots
        .map((n) => Offset(n.dx * size.width, n.dy * size.height))
        .toList();

    if (pts.isEmpty) {
      return path;
    }

    path.moveTo(pts.first.dx, pts.first.dy);
    for (var i = 1; i < pts.length; i++) {
      final prev = pts[i - 1];
      final cur = pts[i];
      if ((cur - prev).distance > max(size.width, size.height) * 0.42) {
        path.moveTo(cur.dx, cur.dy);
      } else {
        path.lineTo(cur.dx, cur.dy);
      }
    }

    return path;
  }

  void _drawStroke(Canvas canvas, List<Offset> points, Color strokeColor) {
    if (points.length < 2) {
      return;
    }

    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }

    final outline = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 15
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final inner = Paint()
      ..color = strokeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 11
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(path, outline);
    canvas.drawPath(path, inner);
  }

  @override
  bool shouldRepaint(covariant _TraceBoardPainter oldDelegate) {
    return oldDelegate.remainingDots != remainingDots ||
        oldDelegate.strokes != strokes ||
        oldDelegate.currentStroke != currentStroke ||
        oldDelegate.color != color ||
        oldDelegate.completed != completed ||
        oldDelegate.startDot != startDot;
  }
}
