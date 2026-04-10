import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:mv2629/game/penalty_game.dart';

class PenaltyGameScreen extends StatefulWidget {
  const PenaltyGameScreen({super.key});

  @override
  State<PenaltyGameScreen> createState() => _PenaltyGameScreenState();
}

class _PenaltyGameScreenState extends State<PenaltyGameScreen> {
  late PenaltyGame _game;

  @override
  void initState() {
    super.initState();
    _game = PenaltyGame();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GameWidget<PenaltyGame>(
        game: _game,
        overlayBuilderMap: {
          PenaltyGame.hudOverlay: (ctx, game) => HudOverlay(game: game),
          PenaltyGame.controlsOverlay: (ctx, game) =>
              ControlsOverlay(game: game),
          PenaltyGame.goalOverlay: (ctx, game) => GoalNotifOverlay(game: game),
          PenaltyGame.resultOverlay: (ctx, game) =>
              ResultOverlay(game: game, onHome: () => Navigator.of(ctx).pop()),
        },
        initialActiveOverlays: const [
          PenaltyGame.hudOverlay,
          PenaltyGame.controlsOverlay,
        ],
      ),
    );
  }
}

class HudOverlay extends StatefulWidget {
  final PenaltyGame game;
  const HudOverlay({super.key, required this.game});

  @override
  State<HudOverlay> createState() => _HudOverlayState();
}

class _HudOverlayState extends State<HudOverlay> {
  @override
  void initState() {
    super.initState();
    widget.game.addListener(_rebuild);
  }

  @override
  void dispose() {
    widget.game.removeListener(_rebuild);
    super.dispose();
  }

  void _rebuild() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final game = widget.game;
    final progress = game.score / 100.0;
    final shotsLeft = (PenaltyGame.maxShots - game.shotsTaken).clamp(
      0,
      PenaltyGame.maxShots,
    );

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.65),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white24, width: 1),
                    ),
                    child: const Icon(
                      Icons.arrow_back,
                      color: Colors.white70,
                      size: 22,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                _HudChip(
                  child: Row(
                    children: [
                      const Icon(
                        Icons.sports_soccer,
                        color: Colors.white70,
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Shot ${game.shotsTaken}/${PenaltyGame.maxShots}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                _HudChip(
                  child: Row(
                    children: [
                      const Icon(Icons.stars, color: Colors.white70, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        '${game.score}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        ' / 100',
                        style: TextStyle(color: Colors.white54, fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                _HudChip(
                  child: Text(
                    'Left: $shotsLeft',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _HudChip(
                  child: Text(
                    'Wind: ${game.windStrength.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.lightBlueAccent,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const Spacer(),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                backgroundColor: Colors.white12,
                valueColor: AlwaysStoppedAnimation<Color>(
                  progress >= 1.0
                      ? const Color(0xFFFFD700)
                      : progress >= 0.6
                      ? const Color(0xFF7FFF00)
                      : const Color(0xFF42A5F5),
                ),
                minHeight: 6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HudChip extends StatelessWidget {
  final Widget child;
  const _HudChip({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.65),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white24, width: 1),
      ),
      child: child,
    );
  }
}

class ControlsOverlay extends StatelessWidget {
  final PenaltyGame game;
  const ControlsOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: _ShootButton(onTap: game.shoot),
        ),
      ),
    );
  }
}

class _ShootButton extends StatefulWidget {
  final VoidCallback onTap;
  const _ShootButton({required this.onTap});

  @override
  State<_ShootButton> createState() => _ShootButtonState();
}

class _ShootButtonState extends State<_ShootButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.9).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        _ctrl.forward();
        widget.onTap();
      },
      onTapUp: (_) => _ctrl.reverse(),
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1565C0), Color(0xFF0D47A1)],
            ),
            border: Border.all(color: Colors.white38, width: 2.5),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1565C0).withOpacity(0.7),
                blurRadius: 20,
                spreadRadius: 4,
              ),
            ],
          ),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.sports_soccer, color: Colors.white, size: 30),
              SizedBox(height: 2),
              Text(
                'SHOOT',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class GoalNotifOverlay extends StatefulWidget {
  final PenaltyGame game;
  const GoalNotifOverlay({super.key, required this.game});

  @override
  State<GoalNotifOverlay> createState() => _GoalNotifOverlayState();
}

class _GoalNotifOverlayState extends State<GoalNotifOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _scale = CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut);
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final game = widget.game;
    final pts = game.goalScoredPoints;
    final isPos = pts > 0;
    final color = isPos ? const Color(0xFF7FFF00) : const Color(0xFFFF4444);
    final goalColor = _getGoalColor(game.goalScoredName);

    return FadeTransition(
      opacity: _fade,
      child: Center(
        child: ScaleTransition(
          scale: _scale,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 28),
            decoration: BoxDecoration(
              color: const Color(0xDD0A0F20),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: color.withOpacity(0.8), width: 2.5),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 30,
                  spreadRadius: 8,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isPos ? Icons.check_circle : Icons.cancel,
                      color: color,
                      size: 40,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isPos ? 'GOAL!' : 'MISS!',
                      style: TextStyle(
                        color: color,
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: goalColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: goalColor.withOpacity(0.5)),
                  ),
                  child: Text(
                    '${game.goalScoredName} Goal',
                    style: TextStyle(
                      color: goalColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '${isPos ? '+' : ''}$pts pts',
                  style: TextStyle(
                    color: color,
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getGoalColor(String name) {
    switch (name) {
      case 'White':
        return Colors.white;
      case 'Red':
        return const Color(0xFFFF3333);
      case 'Green':
        return const Color(0xFF2ECC40);
      case 'Yellow':
        return const Color(0xFFFFDD00);
      case 'Pink':
        return const Color(0xFFFF69B4);
      default:
        return Colors.white;
    }
  }
}

class ResultOverlay extends StatefulWidget {
  final PenaltyGame game;
  final VoidCallback onHome;
  const ResultOverlay({super.key, required this.game, required this.onHome});

  @override
  State<ResultOverlay> createState() => _ResultOverlayState();
}

class _ResultOverlayState extends State<ResultOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _slideIn;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _slideIn = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final game = widget.game;
    final isWin = game.gameState == GameState.win;

    return Container(
      color: Colors.black.withOpacity(0.88),
      child: Center(
        child: ScaleTransition(
          scale: _slideIn,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.85,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: isWin
                    ? [const Color(0xFF1A2A0A), const Color(0xFF0A1A28)]
                    : [const Color(0xFF2A0A0A), const Color(0xFF0A0A1A)],
              ),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: isWin
                    ? const Color(0xFFFFD700)
                    : const Color(0xFFFF3333),
                width: 2.5,
              ),
              boxShadow: [
                BoxShadow(
                  color:
                      (isWin
                              ? const Color(0xFFFFD700)
                              : const Color(0xFFFF3333))
                          .withOpacity(0.35),
                  blurRadius: 40,
                  spreadRadius: 8,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isWin ? Icons.emoji_events : Icons.sentiment_dissatisfied,
                  color: isWin
                      ? const Color(0xFFFFD700)
                      : const Color(0xFFFF4444),
                  size: 80,
                ),
                const SizedBox(height: 12),
                Text(
                  isWin ? 'PERFECT SCORE!' : 'GAME OVER',
                  style: TextStyle(
                    color: isWin
                        ? const Color(0xFFFFD700)
                        : const Color(0xFFFF4444),
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 3,
                  ),
                ),
                const SizedBox(height: 8),
                if (isWin)
                  const Text(
                    'You reached 100 points!',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  )
                else
                  Text(
                    'Final Score: ${game.score} / 100',
                    style: const TextStyle(color: Colors.white70, fontSize: 18),
                  ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '${game.score} pts',
                    style: TextStyle(
                      color: isWin ? const Color(0xFFFFD700) : Colors.white54,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _ResultBtn(
                      label: 'Play Again',
                      color: const Color(0xFF1565C0),
                      onTap: () {
                        _ctrl.reverse().then((_) => widget.game.restart());
                      },
                    ),
                    const SizedBox(width: 16),
                    _ResultBtn(
                      label: 'Home',
                      color: const Color(0xFF37474F),
                      onTap: widget.onHome,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ResultBtn extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ResultBtn({
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(26),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.4),
              blurRadius: 14,
              spreadRadius: 3,
            ),
          ],
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
