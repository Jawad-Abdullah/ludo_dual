import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

void main() {
  runApp(const LudoApp());
}

class LudoApp extends StatelessWidget {
  const LudoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Two Player Ludo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1F8068),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F6F2),
        useMaterial3: true,
      ),
      home: const LudoGamePage(),
    );
  }
}

class LudoGamePage extends StatefulWidget {
  const LudoGamePage({super.key});

  @override
  State<LudoGamePage> createState() => _LudoGamePageState();
}

class _LudoGamePageState extends State<LudoGamePage> {
  static const _colors = [Color(0xFFDA4B48), Color(0xFF238B68)];
  static const _names = ['Red', 'Green'];
  static const _track = <Offset>[
    Offset(6, 1),
    Offset(6, 2),
    Offset(6, 3),
    Offset(6, 4),
    Offset(6, 5),
    Offset(5, 6),
    Offset(4, 6),
    Offset(3, 6),
    Offset(2, 6),
    Offset(1, 6),
    Offset(0, 6),
    Offset(0, 7),
    Offset(0, 8),
    Offset(1, 8),
    Offset(2, 8),
    Offset(3, 8),
    Offset(4, 8),
    Offset(5, 8),
    Offset(6, 9),
    Offset(6, 10),
    Offset(6, 11),
    Offset(6, 12),
    Offset(6, 13),
    Offset(6, 14),
    Offset(7, 14),
    Offset(8, 14),
    Offset(8, 13),
    Offset(8, 12),
    Offset(8, 11),
    Offset(8, 10),
    Offset(8, 9),
    Offset(9, 8),
    Offset(10, 8),
    Offset(11, 8),
    Offset(12, 8),
    Offset(13, 8),
    Offset(14, 8),
    Offset(14, 7),
    Offset(14, 6),
    Offset(13, 6),
    Offset(12, 6),
    Offset(11, 6),
    Offset(10, 6),
    Offset(9, 6),
    Offset(8, 5),
    Offset(8, 4),
    Offset(8, 3),
    Offset(8, 2),
    Offset(8, 1),
    Offset(8, 0),
    Offset(7, 0),
    Offset(6, 0),
  ];

  final List<List<int>> _positions = [
    List<int>.filled(4, -1),
    List<int>.filled(4, -1),
  ];
  final Random _random = Random();
  int _currentPlayer = 0;
  int _diceValue = 1;
  int _animationStep = 0;
  bool _isRolling = false;
  bool _hasRolled = false;
  String _message = 'Roll the dice to begin.';
  Timer? _rollTimer;

  List<int> get _legalTokens {
    if (!_hasRolled) return const [];
    return [
      for (var index = 0; index < 4; index++)
        if (_canMoveToken(_positions[_currentPlayer][index])) index,
    ];
  }

  bool _canMoveToken(int position) {
    if (position == -1) return _diceValue == 6;
    return position + _diceValue <= 57;
  }

  void _rollDice() {
    if (_isRolling || _hasRolled) return;

    final result = _random.nextInt(6) + 1;
    setState(() {
      _isRolling = true;
      _animationStep = 0;
      _message = 'Rolling the dice...';
    });

    _rollTimer?.cancel();
    _rollTimer = Timer.periodic(const Duration(milliseconds: 85), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _animationStep++;
        _diceValue = _random.nextInt(6) + 1;
        if (_animationStep >= 7) {
          timer.cancel();
          _diceValue = result;
          _isRolling = false;
          _hasRolled = true;
          if (_legalTokens.isEmpty) {
            _hasRolled = false;
            _currentPlayer = 1 - _currentPlayer;
            _message = 'No legal move. ${_names[_currentPlayer]} plays next.';
          } else {
            _message = 'Choose a highlighted token to move.';
          }
        }
      });
    });
  }

  void _moveToken(int tokenIndex) {
    if (!_legalTokens.contains(tokenIndex)) return;
    setState(() {
      final oldPosition = _positions[_currentPlayer][tokenIndex];
      _positions[_currentPlayer][tokenIndex] =
          oldPosition == -1 ? 0 : oldPosition + _diceValue;

      if (_positions[_currentPlayer].every((position) => position == 57)) {
        _message = '${_names[_currentPlayer]} wins!';
        _hasRolled = false;
        return;
      }

      if (_diceValue == 6) {
        _message = 'A six! ${_names[_currentPlayer]} rolls again.';
      } else {
        _currentPlayer = 1 - _currentPlayer;
        _message = '${_names[_currentPlayer]} plays next. Roll the dice.';
      }
      _hasRolled = false;
    });
  }

  void _restartGame() {
    _rollTimer?.cancel();
    setState(() {
      for (final playerTokens in _positions) {
        for (var index = 0; index < playerTokens.length; index++) {
          playerTokens[index] = -1;
        }
      }
      _currentPlayer = 0;
      _diceValue = 1;
      _animationStep = 0;
      _isRolling = false;
      _hasRolled = false;
      _message = 'Roll the dice to begin.';
    });
  }

  bool get _hasWinner =>
      _positions.any((tokens) => tokens.every((position) => position == 57));

  @override
  void dispose() {
    _rollTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentColor = _colors[_currentPlayer];
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'LUDO DUEL',
          style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.6),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        top: false,
        child: LayoutBuilder(
          builder: (context, constraints) => Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: SizedBox(
                  height: constraints.maxHeight,
                  child: Column(
                    children: [
                      _TurnBanner(
                        color: currentColor,
                        message: _message,
                        hasWinner: _hasWinner,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          for (var player = 0; player < 2; player++) ...[
                            Expanded(
                              child: _PlayerCard(
                                name: _names[player],
                                color: _colors[player],
                                isActive:
                                    _currentPlayer == player && !_hasWinner,
                                finished: _positions[player]
                                    .where((position) => position == 57)
                                    .length,
                              ),
                            ),
                            if (player == 0) const SizedBox(width: 10),
                          ],
                        ],
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: Center(
                          child: AspectRatio(
                            aspectRatio: 1,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(18),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.08),
                                    blurRadius: 18,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: LayoutBuilder(
                                builder: (context, constraints) {
                                  final cellSize = constraints.maxWidth / 15;
                                  return Stack(
                                    children: [
                                      const Positioned.fill(
                                        child: CustomPaint(
                                          painter: _BoardPainter(),
                                        ),
                                      ),
                                      for (var player = 0; player < 2; player++)
                                        for (var token = 0; token < 4; token++)
                                          _buildToken(
                                            player: player,
                                            token: token,
                                            cellSize: cellSize,
                                          ),
                                    ],
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildControls(),
                      const SizedBox(height: 6),
                      const Text(
                        'Roll a 6 to start • Reach the center to win',
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style:
                            TextStyle(color: Color(0xFF6D7772), fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildToken({
    required int player,
    required int token,
    required double cellSize,
  }) {
    final position = _positions[player][token];
    final cell = _tokenCell(player, token, position);
    final diameter = cellSize * 0.72;
    final isMovable = player == _currentPlayer && _legalTokens.contains(token);
    return Positioned(
      left: cell.dx * cellSize - diameter / 2,
      top: cell.dy * cellSize - diameter / 2,
      width: diameter,
      height: diameter,
      child: Semantics(
        button: isMovable,
        label: '${_names[player]} token ${token + 1}',
        child: GestureDetector(
          key: ValueKey('token-$player-$token'),
          onTap: isMovable ? () => _moveToken(token) : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 280),
            decoration: BoxDecoration(
              color: _colors[player],
              shape: BoxShape.circle,
              border: Border.all(
                color: isMovable ? Colors.white : Colors.white.withOpacity(0.9),
                width: isMovable ? 2.5 : 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: _colors[player].withOpacity(isMovable ? 0.48 : 0.25),
                  blurRadius: isMovable ? 9 : 4,
                  spreadRadius: isMovable ? 1 : 0,
                ),
              ],
            ),
            alignment: Alignment.center,
          ),
        ),
      ),
    );
  }

  Offset _tokenCell(int player, int token, int position) {
    if (position == -1) {
      final spots = player == 0
          ? const [
              Offset(1.7, 1.7),
              Offset(4.3, 1.7),
              Offset(1.7, 4.3),
              Offset(4.3, 4.3)
            ]
          : const [
              Offset(10.7, 10.7),
              Offset(13.3, 10.7),
              Offset(10.7, 13.3),
              Offset(13.3, 13.3)
            ];
      return spots[token];
    }

    if (position >= 52) {
      final laneStep = position - 52;
      return player == 0
          ? Offset(7.5, 1.5 + laneStep)
          : Offset(7.5, 13.5 - laneStep);
    }

    final trackIndex = (position + (player == 0 ? 0 : 26)) % _track.length;
    final trackCell = _track[trackIndex];
    return Offset(trackCell.dx + 0.5, trackCell.dy + 0.5);
  }

  Widget _buildControls() {
    final canRoll = !_isRolling && !_hasRolled && !_hasWinner;
    return Row(
      children: [
        Expanded(
          child: FilledButton.icon(
            key: const ValueKey('roll-button'),
            onPressed: canRoll ? _rollDice : null,
            icon: const Icon(Icons.casino_outlined),
            label: Text(_isRolling ? 'Rolling...' : 'Roll dice'),
            style: FilledButton.styleFrom(
              backgroundColor: _colors[_currentPlayer],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 15),
              textStyle: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedRotation(
              turns: _animationStep / 2,
              duration: const Duration(milliseconds: 80),
              child: Container(
                key: const ValueKey('dice-value'),
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE0E6E1), width: 2),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x14000000),
                      blurRadius: 8,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: CustomPaint(
                  painter: _DicePipPainter(_diceValue),
                ),
              ),
            ),
            const SizedBox(height: 3),
            const Text(
              'DICE',
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
                color: Color(0xFF6D7772),
              ),
            ),
          ],
        ),
        const SizedBox(width: 8),
        OutlinedButton(
          key: const ValueKey('restart-button'),
          onPressed: _restartGame,
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF41534B),
            padding: const EdgeInsets.all(14),
            minimumSize: const Size(54, 54),
          ),
          child: const Icon(Icons.refresh),
        ),
      ],
    );
  }
}

class _DicePipPainter extends CustomPainter {
  const _DicePipPainter(this.value);

  final int value;

  static const _positions = <int, List<Offset>>{
    1: [Offset(0.5, 0.5)],
    2: [Offset(0.27, 0.27), Offset(0.73, 0.73)],
    3: [Offset(0.27, 0.27), Offset(0.5, 0.5), Offset(0.73, 0.73)],
    4: [
      Offset(0.27, 0.27),
      Offset(0.73, 0.27),
      Offset(0.27, 0.73),
      Offset(0.73, 0.73),
    ],
    5: [
      Offset(0.27, 0.27),
      Offset(0.73, 0.27),
      Offset(0.5, 0.5),
      Offset(0.27, 0.73),
      Offset(0.73, 0.73),
    ],
    6: [
      Offset(0.27, 0.25),
      Offset(0.73, 0.25),
      Offset(0.27, 0.5),
      Offset(0.73, 0.5),
      Offset(0.27, 0.75),
      Offset(0.73, 0.75),
    ],
  };

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFF25352D);
    for (final position in _positions[value]!) {
      canvas.drawCircle(
        Offset(position.dx * size.width, position.dy * size.height),
        size.width * 0.065,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _DicePipPainter oldDelegate) =>
      oldDelegate.value != value;
}

class _TurnBanner extends StatelessWidget {
  const _TurnBanner({
    required this.color,
    required this.message,
    required this.hasWinner,
  });

  final Color color;
  final String message;
  final bool hasWinner;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: hasWinner ? const Color(0xFFFFF1CB) : color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(
            hasWinner ? Icons.emoji_events : Icons.circle,
            color: hasWinner ? const Color(0xFFB68100) : color,
            size: hasWinner ? 23 : 15,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              key: const ValueKey('game-status'),
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlayerCard extends StatelessWidget {
  const _PlayerCard({
    required this.name,
    required this.color,
    required this.isActive,
    required this.finished,
  });

  final String name;
  final Color color;
  final bool isActive;
  final int finished;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isActive ? color : const Color(0xFFE5EAE6),
          width: isActive ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: color,
            child: const Icon(Icons.person, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.w800)),
                Text(
                  '$finished / 4 home',
                  style:
                      const TextStyle(fontSize: 11, color: Color(0xFF77817B)),
                ),
              ],
            ),
          ),
          if (isActive) Icon(Icons.play_arrow_rounded, color: color, size: 21),
        ],
      ),
    );
  }
}

class _BoardPainter extends CustomPainter {
  const _BoardPainter();

  static const _red = Color(0xFFDA4B48);
  static const _blue = Color(0xFF4383D1);
  static const _green = Color(0xFF238B68);
  static const _yellow = Color(0xFFE7B534);
  static const _softRed = Color(0xFFFFE7E4);
  static const _softBlue = Color(0xFFE5EEFC);
  static const _softGreen = Color(0xFFE1F3E9);
  static const _softYellow = Color(0xFFFFF3D0);
  static const _line = Color(0xFFDCE3DE);
  static const _route = <Offset>[
    Offset(6, 1),
    Offset(6, 2),
    Offset(6, 3),
    Offset(6, 4),
    Offset(6, 5),
    Offset(5, 6),
    Offset(4, 6),
    Offset(3, 6),
    Offset(2, 6),
    Offset(1, 6),
    Offset(0, 6),
    Offset(0, 7),
    Offset(0, 8),
    Offset(1, 8),
    Offset(2, 8),
    Offset(3, 8),
    Offset(4, 8),
    Offset(5, 8),
    Offset(6, 9),
    Offset(6, 10),
    Offset(6, 11),
    Offset(6, 12),
    Offset(6, 13),
    Offset(6, 14),
    Offset(7, 14),
    Offset(8, 14),
    Offset(8, 13),
    Offset(8, 12),
    Offset(8, 11),
    Offset(8, 10),
    Offset(8, 9),
    Offset(9, 8),
    Offset(10, 8),
    Offset(11, 8),
    Offset(12, 8),
    Offset(13, 8),
    Offset(14, 8),
    Offset(14, 7),
    Offset(14, 6),
    Offset(13, 6),
    Offset(12, 6),
    Offset(11, 6),
    Offset(10, 6),
    Offset(9, 6),
    Offset(8, 5),
    Offset(8, 4),
    Offset(8, 3),
    Offset(8, 2),
    Offset(8, 1),
    Offset(8, 0),
    Offset(7, 0),
    Offset(6, 0),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final cell = size.width / 15;
    final paint = Paint()..style = PaintingStyle.fill;
    canvas.drawColor(Colors.white, BlendMode.src);

    _drawHome(
      canvas,
      paint,
      cell,
      const Rect.fromLTWH(0, 0, 6, 6),
      _softRed,
      _red,
    );
    _drawHome(
      canvas,
      paint,
      cell,
      const Rect.fromLTWH(9, 0, 6, 6),
      _softBlue,
      _blue,
    );
    _drawHome(
      canvas,
      paint,
      cell,
      const Rect.fromLTWH(9, 9, 6, 6),
      _softGreen,
      _green,
    );
    _drawHome(
      canvas,
      paint,
      cell,
      const Rect.fromLTWH(0, 9, 6, 6),
      _softYellow,
      _yellow,
    );

    for (final point in _route) {
      _drawCell(canvas, paint, cell, point, Colors.white);
    }
    for (var step = 1; step <= 5; step++) {
      _drawCell(canvas, paint, cell, Offset(7, step.toDouble()), _softRed);
      _drawCell(
          canvas, paint, cell, Offset((14 - step).toDouble(), 7), _softBlue);
      _drawCell(
          canvas, paint, cell, Offset(7, (14 - step).toDouble()), _softGreen);
      _drawCell(canvas, paint, cell, Offset(step.toDouble(), 7), _softYellow);
    }
    _drawCell(canvas, paint, cell, _route.first, _red);
    _drawCell(canvas, paint, cell, _route[26], _green);

    final center = Offset(7.5 * cell, 7.5 * cell);
    final redTriangle = Path()
      ..moveTo(6 * cell, 6 * cell)
      ..lineTo(9 * cell, 6 * cell)
      ..lineTo(center.dx, center.dy)
      ..close();
    paint.color = _red;
    canvas.drawPath(redTriangle, paint);
    final blueTriangle = Path()
      ..moveTo(9 * cell, 6 * cell)
      ..lineTo(9 * cell, 9 * cell)
      ..lineTo(center.dx, center.dy)
      ..close();
    paint.color = _blue;
    canvas.drawPath(blueTriangle, paint);
    final greenTriangle = Path()
      ..moveTo(9 * cell, 9 * cell)
      ..lineTo(6 * cell, 9 * cell)
      ..lineTo(center.dx, center.dy)
      ..close();
    paint.color = _green;
    canvas.drawPath(greenTriangle, paint);
    final yellowTriangle = Path()
      ..moveTo(6 * cell, 9 * cell)
      ..lineTo(6 * cell, 6 * cell)
      ..lineTo(center.dx, center.dy)
      ..close();
    paint.color = _yellow;
    canvas.drawPath(yellowTriangle, paint);

    paint
      ..color = _line
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.7;
    for (var index = 0; index <= 15; index++) {
      canvas.drawLine(
          Offset(index * cell, 0), Offset(index * cell, size.height), paint);
      canvas.drawLine(
          Offset(0, index * cell), Offset(size.width, index * cell), paint);
    }
    paint.style = PaintingStyle.fill;
  }

  void _drawHome(
    Canvas canvas,
    Paint paint,
    double cell,
    Rect bounds,
    Color background,
    Color tokenColor,
  ) {
    paint.color = background;
    canvas.drawRect(
      Rect.fromLTWH(bounds.left * cell, bounds.top * cell, bounds.width * cell,
          bounds.height * cell),
      paint,
    );
    paint.color = Colors.white;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH((bounds.left + 1) * cell, (bounds.top + 1) * cell,
            4 * cell, 4 * cell),
        Radius.circular(cell * 0.45),
      ),
      paint,
    );

    paint.color = tokenColor.withOpacity(0.18);
    final spots = <Offset>[
      Offset(bounds.left + 1.7, bounds.top + 1.7),
      Offset(bounds.left + 4.3, bounds.top + 1.7),
      Offset(bounds.left + 1.7, bounds.top + 4.3),
      Offset(bounds.left + 4.3, bounds.top + 4.3),
    ];
    for (final spot in spots) {
      canvas.drawCircle(
          Offset(spot.dx * cell, spot.dy * cell), cell * 0.48, paint);
    }
  }

  void _drawCell(
      Canvas canvas, Paint paint, double cell, Offset point, Color color) {
    paint
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawRect(
      Rect.fromLTWH(point.dx * cell, point.dy * cell, cell, cell),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
