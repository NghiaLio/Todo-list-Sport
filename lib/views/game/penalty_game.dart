import 'dart:async';
import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

enum GameState { playing, goalScored, gameOver, win }

class GoalData {
  final String name;
  final Color color;
  final int points;
  const GoalData(this.name, this.color, this.points);
}

const List<GoalData> kGoals = [
  GoalData('White', Color(0xFFEEEEEE), 10),
  GoalData('Red', Color(0xFFFF3333), -50),
  GoalData('Green', Color(0xFF2ECC40), 20),
  GoalData('Yellow', Color(0xFFFFDD00), -10),
  GoalData('Pink', Color(0xFFFF69B4), 50),
];

class PenaltyGame extends FlameGame {
  static const String hudOverlay = 'hud';
  static const String controlsOverlay = 'controls';
  static const String goalOverlay = 'goal';
  static const String resultOverlay = 'result';

  int score = 0;
  GameState gameState = GameState.playing;
  double aimX = 0.5;
  bool isShooting = false;
  String goalScoredName = '';
  int goalScoredPoints = 0;
  int targetedGoalIndex = 2;
  int shotsTaken = 0;

  static const int maxShots = 5;
  static const double _minAimX = 0.05;
  static const double _maxAimX = 0.95;
  static const double _baseAimSweepSpeed = 0.80;
  static const double _aimSpeedIncreasePerShot = 0.22;
  static const double _minWindStrength = 0.10;
  static const double _maxWindStrength = 0.90;

  double windStrength = 0.35;
  final Random _random = Random();

  double _aimSweepSpeed = _baseAimSweepSpeed;
  double _aimSweepDirection = 1;

  final List<VoidCallback> _listeners = [];
  void addListener(VoidCallback l) => _listeners.add(l);
  void removeListener(VoidCallback l) => _listeners.remove(l);
  void _notify() {
    for (final l in _listeners) {
      l();
    }
  }

  late BallComp ball;

  @override
  Color backgroundColor() => const Color(0xFF0A1628);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    add(FieldBg());

    final gw = size.x / 5;
    final gh = size.y * 0.12;
    final gy = size.y * 0.04;
    for (int i = 0; i < kGoals.length; i++) {
      add(
        GoalComp(
          data: kGoals[i],
          position: Vector2(i * gw, gy),
          size: Vector2(gw, gh),
        ),
      );
    }

    ball = BallComp(radius: size.x * 0.044);
    ball.position = Vector2(size.x * 0.5, size.y * 0.73);
    add(ball);

    _randomizeWindStrength();

    overlays.add(controlsOverlay);
  }

  void _randomizeWindStrength() {
    windStrength =
        _minWindStrength +
        _random.nextDouble() * (_maxWindStrength - _minWindStrength);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (gameState != GameState.playing ||
        isShooting ||
        shotsTaken >= maxShots) {
      return;
    }

    aimX += _aimSweepDirection * _aimSweepSpeed * dt;
    if (aimX <= _minAimX) {
      aimX = _minAimX;
      _aimSweepDirection = 1;
    } else if (aimX >= _maxAimX) {
      aimX = _maxAimX;
      _aimSweepDirection = -1;
    }
    targetedGoalIndex = (aimX * 5).floor().clamp(0, 4);
    ball.position.x = (aimX * size.x).clamp(
      ball.radius * 1.4,
      size.x - ball.radius * 1.4,
    );
  }

  void _endGame() {
    gameState = score >= 100 ? GameState.win : GameState.gameOver;
    overlays.add(resultOverlay);
    _notify();
  }

  void shoot() {
    if (isShooting ||
        gameState != GameState.playing ||
        shotsTaken >= maxShots) {
      return;
    }
    isShooting = true;
    shotsTaken++;
    final goalIndex = targetedGoalIndex;
    final gw = size.x / 5;
    final windDir = _random.nextDouble() * 2 - 1;
    final windAccelX = windDir * windStrength.clamp(0.0, 1.0) * size.x * 2.2;
    ball.shoot(
      target: Vector2(goalIndex * gw + gw / 2, size.y * 0.10),
      windAccelX: windAccelX,
      onGoal: () => _handleGoal(goalIndex),
    );
    _notify();
  }

  void _handleGoal(int goalIndex) {
    final data = kGoals[goalIndex];
    score = (score + data.points).clamp(0, 999);
    goalScoredName = data.name;
    goalScoredPoints = data.points;
    gameState = GameState.goalScored;
    overlays.add(goalOverlay);
    _notify();

    Future.delayed(const Duration(milliseconds: 1300), () {
      overlays.remove(goalOverlay);
      if (shotsTaken >= maxShots) {
        _endGame();
        return;
      }
      if (gameState == GameState.goalScored) {
        ball.reset(Vector2(size.x * 0.5, size.y * 0.73));
        _aimSweepSpeed += _aimSpeedIncreasePerShot;
        _randomizeWindStrength();
        isShooting = false;
        gameState = GameState.playing;
        _notify();
      }
    });
  }

  void restart() {
    score = 0;
    gameState = GameState.playing;
    aimX = 0.5;
    targetedGoalIndex = 2;
    shotsTaken = 0;
    _aimSweepSpeed = _baseAimSweepSpeed;
    _aimSweepDirection = 1;
    _randomizeWindStrength();
    isShooting = false;
    overlays.remove(resultOverlay);
    overlays.remove(goalOverlay);
    ball.reset(Vector2(size.x * 0.5, size.y * 0.73));
    _notify();
  }
}

class FieldBg extends Component with HasGameRef<PenaltyGame> {
  late final List<(double, double, double, double)> _stars;

  @override
  Future<void> onLoad() async {
    final rng = Random(42);
    final w = gameRef.size.x;
    final h = gameRef.size.y;
    _stars = List.generate(
      28,
      (_) => (
        rng.nextDouble() * w,
        rng.nextDouble() * h * 0.24,
        rng.nextDouble() * 1.4 + 0.4,
        rng.nextDouble() * 0.5 + 0.3,
      ),
    );
  }

  @override
  void render(Canvas canvas) {
    final s = gameRef.size;
    final w = s.x;
    final h = s.y;

    final skyP = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF040810), Color(0xFF081420)],
      ).createShader(Rect.fromLTWH(0, 0, w, h * 0.30));
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h * 0.30), skyP);

    for (final (sx, sy, sr, sop) in _stars) {
      canvas.drawCircle(
        Offset(sx, sy),
        sr,
        Paint()..color = Colors.white.withOpacity(sop),
      );
    }

    canvas.drawCircle(
      Offset(w * 0.84, h * 0.07),
      h * 0.036,
      Paint()..color = const Color(0xFFFFF8DC),
    );
    canvas.drawCircle(
      Offset(w * 0.845, h * 0.062),
      h * 0.028,
      Paint()..color = const Color(0xFF06101E),
    );

    _floodlight(canvas, Offset(w * 0.06, h * 0.25), w, h);
    _floodlight(canvas, Offset(w * 0.94, h * 0.25), w, h);

    final grassTop = h * 0.27;
    final stripeH = (h - grassTop) / 8;
    const c1 = Color(0xFF1E7A3C);
    const c2 = Color(0xFF197033);
    for (int i = 0; i < 8; i++) {
      canvas.drawRect(
        Rect.fromLTWH(0, grassTop + i * stripeH, w, stripeH),
        Paint()..color = i.isEven ? c1 : c2,
      );
    }

    final lp = Paint()
      ..color = Colors.white.withOpacity(0.22)
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke;

    canvas.drawLine(Offset(0, h * 0.20), Offset(w, h * 0.20), lp);
    canvas.drawRect(Rect.fromLTWH(w * 0.30, h * 0.20, w * 0.40, h * 0.10), lp);
    canvas.drawRect(Rect.fromLTWH(w * 0.16, h * 0.52, w * 0.68, h * 0.24), lp);
    canvas.drawCircle(
      Offset(w * 0.5, h * 0.60),
      3.5,
      Paint()..color = Colors.white.withOpacity(0.4),
    );

    final arc = Path()
      ..addArc(
        Rect.fromCenter(
          center: Offset(w * 0.5, h * 0.60),
          width: w * 0.34,
          height: h * 0.16,
        ),
        pi * 1.1,
        pi * 0.8,
      );
    canvas.drawPath(arc, lp);

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.5, h * 0.86),
        width: w * 0.55,
        height: h * 0.14,
      ),
      lp,
    );
    canvas.drawCircle(
      Offset(w * 0.5, h * 0.86),
      4,
      Paint()..color = Colors.white.withOpacity(0.4),
    );
  }

  void _floodlight(Canvas canvas, Offset pos, double w, double h) {
    canvas.drawLine(
      pos,
      Offset(pos.dx, h * 0.27),
      Paint()
        ..color = Colors.white38
        ..strokeWidth = 2.5,
    );
    canvas.drawCircle(pos, 6, Paint()..color = const Color(0xFFFFFACD));
    canvas.drawCircle(
      pos,
      20,
      Paint()
        ..color = Colors.yellow.withOpacity(0.14)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14),
    );

    final cone = Path()
      ..moveTo(pos.dx, pos.dy)
      ..lineTo(pos.dx - h * 0.26, h * 0.27)
      ..lineTo(pos.dx + h * 0.26, h * 0.27)
      ..close();
    canvas.drawPath(
      cone,
      Paint()
        ..color = Colors.yellow.withOpacity(0.04)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 24),
    );
  }
}

class GoalComp extends PositionComponent with HasGameRef<PenaltyGame> {
  final GoalData data;

  GoalComp({
    required this.data,
    required Vector2 position,
    required Vector2 size,
  }) : super(position: position, size: size, anchor: Anchor.topLeft);

  @override
  void render(Canvas canvas) {
    final w = size.x;
    final h = size.y;

    canvas.drawRect(
      Rect.fromLTWH(3, 3, w - 6, h - 4),
      Paint()..color = data.color.withOpacity(0.10),
    );

    final nlp = Paint()
      ..color = data.color.withOpacity(0.28)
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;
    for (double x = 3; x < w - 3; x += (w - 6) / 5) {
      canvas.drawLine(Offset(x, 3), Offset(x, h - 2), nlp);
    }
    for (double y = 3; y < h; y += h / 3.5) {
      canvas.drawLine(Offset(3, y), Offset(w - 3, y), nlp);
    }

    final fp = Paint()
      ..color = data.color
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(1.5, 1.5), Offset(w - 1.5, 1.5), fp);
    canvas.drawLine(Offset(1.5, 1.5), Offset(1.5, h), fp);
    canvas.drawLine(Offset(w - 1.5, 1.5), Offset(w - 1.5, h), fp);

    final pts = data.points;
    final ptsStr = pts > 0 ? '+$pts' : '$pts';
    final isPos = pts > 0;
    final ptColor = isPos ? const Color(0xFF7FFF00) : const Color(0xFFFF4444);

    _text(
      canvas,
      ptsStr,
      Offset(w / 2, h * 0.58),
      TextStyle(
        color: ptColor,
        fontSize: h * 0.40,
        fontWeight: FontWeight.w900,
        shadows: const [
          Shadow(color: Colors.black, blurRadius: 4, offset: Offset(1, 1)),
        ],
      ),
    );
    _text(
      canvas,
      data.name,
      Offset(w / 2, h * 0.17),
      TextStyle(
        color: data.color,
        fontSize: h * 0.20,
        fontWeight: FontWeight.bold,
        shadows: const [Shadow(color: Colors.black, blurRadius: 3)],
      ),
    );
  }

  void _text(Canvas canvas, String t, Offset center, TextStyle style) {
    final tp = TextPainter(
      text: TextSpan(text: t, style: style),
      textDirection: TextDirection.ltr,
    );
    tp.layout(maxWidth: size.x);
    tp.paint(canvas, center - Offset(tp.width / 2, tp.height / 2));
  }
}

class BallComp extends PositionComponent with HasGameRef<PenaltyGame> {
  final double radius;
  static const double _flightDuration = 0.52;
  Vector2 _vel = Vector2.zero();
  bool _shooting = false;
  VoidCallback? _onGoal;
  double _targetY = 0;
  double _windAccelX = 0;

  BallComp({required this.radius}) : super(anchor: Anchor.center);

  void shoot({
    required Vector2 target,
    required double windAccelX,
    required VoidCallback onGoal,
  }) {
    _onGoal = onGoal;
    _shooting = true;
    _targetY = target.y;
    _windAccelX = windAccelX;
    _vel = (target - position) / _flightDuration;
  }

  void reset(Vector2 pos) {
    position = pos;
    _vel = Vector2.zero();
    _windAccelX = 0;
    _shooting = false;
    _onGoal = null;
  }

  @override
  void update(double dt) {
    if (!_shooting) {
      return;
    }
    _vel.x += _windAccelX * dt;
    position += _vel * dt;
    position.x = position.x.clamp(radius, gameRef.size.x - radius);
    if (position.y <= _targetY) {
      position.y = _targetY;
      _shooting = false;
      _vel = Vector2.zero();
      _windAccelX = 0;
      final cb = _onGoal;
      _onGoal = null;
      cb?.call();
    }
  }

  @override
  void render(Canvas canvas) {
    final startY = gameRef.size.y * 0.73;
    final goalY = gameRef.size.y * 0.10;
    final t = ((position.y - goalY) / (startY - goalY)).clamp(0.0, 1.0);
    final r = radius * (0.58 + 0.42 * t);
    const cx = 0.0;
    const cy = 0.0;

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx, cy + r * 0.38),
        width: r * 2.05,
        height: r * 0.58,
      ),
      Paint()
        ..color = Colors.black.withOpacity(0.44 * t)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 9),
    );

    canvas.drawCircle(
      Offset(cx, cy),
      r,
      Paint()
        ..shader =
            RadialGradient(
              center: const Alignment(-0.34, -0.38),
              radius: 1.05,
              colors: const [
                Color(0xFFFFFFFF),
                Color(0xFFE9ECF1),
                Color(0xFFC8D0D9),
              ],
              stops: const [0.0, 0.62, 1.0],
            ).createShader(
              Rect.fromCircle(center: const Offset(cx, cy), radius: r),
            ),
    );

    final seamPaint = Paint()
      ..color = const Color(0xFF151B23).withOpacity(0.55)
      ..strokeWidth = r * 0.05
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    Path pentagon(Offset center, double rad) {
      final p = Path();
      for (int i = 0; i < 5; i++) {
        final a = -pi / 2 + i * (2 * pi / 5);
        final px = center.dx + cos(a) * rad;
        final py = center.dy + sin(a) * rad;
        if (i == 0) {
          p.moveTo(px, py);
        } else {
          p.lineTo(px, py);
        }
      }
      p.close();
      return p;
    }

    final centerPanel = pentagon(const Offset(cx, cy), r * 0.24);
    canvas.drawPath(centerPanel, Paint()..color = const Color(0xFF1B212A));
    canvas.drawPath(centerPanel, seamPaint);

    for (int i = 0; i < 5; i++) {
      final a = -pi / 2 + i * (2 * pi / 5);
      final c = Offset(cx + cos(a) * r * 0.50, cy + sin(a) * r * 0.50);
      final panel = pentagon(c, r * 0.18);
      canvas.drawPath(panel, Paint()..color = const Color(0xFF202A35));
      canvas.drawPath(panel, seamPaint);
      canvas.drawLine(
        Offset(cx + cos(a) * r * 0.22, cy + sin(a) * r * 0.22),
        Offset(cx + cos(a) * r * 0.36, cy + sin(a) * r * 0.36),
        seamPaint,
      );
    }

    canvas.drawCircle(
      Offset(cx, cy),
      r,
      Paint()
        ..color = const Color(0xFFB5BDC7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * 0.06,
    );

    canvas.drawArc(
      Rect.fromCircle(center: const Offset(cx, cy), radius: r * 0.98),
      pi * 0.15,
      pi * 0.9,
      false,
      Paint()
        ..color = const Color(0xFF5F6A78).withOpacity(0.35)
        ..strokeWidth = r * 0.09
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    canvas.drawCircle(
      Offset(cx - r * 0.30, cy - r * 0.34),
      r * 0.20,
      Paint()..color = Colors.white.withOpacity(0.58),
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx - r * 0.14, cy - r * 0.14),
        width: r * 0.25,
        height: r * 0.12,
      ),
      Paint()..color = Colors.white.withOpacity(0.32),
    );
  }
}
