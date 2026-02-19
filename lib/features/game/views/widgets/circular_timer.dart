import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/game_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/ui_colors.dart';

class CircularTimer extends ConsumerStatefulWidget {
  const CircularTimer({super.key});

  @override
  ConsumerState<CircularTimer> createState() => _CircularTimerState();
}

class _CircularTimerState extends ConsumerState<CircularTimer>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;
  late AnimationController _labelController;

  String? _difficultyLabel;

  static const _difficultyLabels = {
    'easy': '⚡ Einfach',
    'medium': '⚡ Mittel',
    'hard': '⚡ Schwer',
    'infinite': '⚡ Endlos',
  };

  @override
  void initState() {
    super.initState();

    // Pulse: bigger scale + elastic bounce for difficulty change
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _pulseAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.6), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.6, end: 0.95), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 0.95, end: 1.0), weight: 30),
    ]).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeOut),
    );

    // Glow: radiating gold shadow
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _glowAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 24.0), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 24.0, end: 0.0), weight: 60),
    ]).animate(CurvedAnimation(parent: _glowController, curve: Curves.easeOut));

    // Label: fade in/out for difficulty name
    _labelController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _glowController.dispose();
    _labelController.dispose();
    super.dispose();
  }

  void _triggerDifficultyAnimation(String difficultyName) {
    setState(() {
      _difficultyLabel = _difficultyLabels[difficultyName] ?? difficultyName;
    });
    _pulseController.forward(from: 0.0);
    _glowController.forward(from: 0.0);
    _labelController.forward(from: 0.0).then((_) {
      if (mounted) {
        setState(() => _difficultyLabel = null);
      }
    });
  }

  Color _getTimerColor(double timeRemaining) {
    if (timeRemaining <= 1.0) return UIColors.timerCritical;
    if (timeRemaining <= 2.0) return UIColors.timerWarning;
    return UIColors.timerNormal;
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameProvider);
    final maxTime = gameState.maxTime;
    final timeRemaining = gameState.timeRemaining;
    final progress = (timeRemaining / maxTime).clamp(0.0, 1.0);

    // Listen for difficulty changes to trigger animation
    ref.listen(gameProvider.select((s) => s.difficulty), (previous, next) {
      if (previous != null && next != previous) {
        _triggerDifficultyAnimation(next.name);
      }
    });

    // Listen for game start / restart to show initial difficulty label
    ref.listen(gameProvider.select((s) => s.status), (previous, next) {
      if (next.name == 'playing' &&
          (previous?.name == 'idle' || previous?.name == 'countdown')) {
        final difficulty = ref.read(gameProvider).difficulty;
        _triggerDifficultyAnimation(difficulty.name);
      }
    });

    final numberStyle = Theme.of(context).numberStyle;
    final timerColor =
        _pulseController.isAnimating
            ? UIColors.gold
            : _getTimerColor(timeRemaining);

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Timer circle with glow + pulse
          AnimatedBuilder(
            animation: _glowAnimation,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow:
                      _glowAnimation.value > 0
                          ? [
                            BoxShadow(
                              color: UIColors.gold.withValues(alpha: 0.6),
                              blurRadius: _glowAnimation.value,
                              spreadRadius: _glowAnimation.value * 0.15,
                            ),
                          ]
                          : null,
                ),
                child: child,
              );
            },
            child: ScaleTransition(
              scale: _pulseAnimation,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Background track
                  const SizedBox(
                    width: 48,
                    height: 48,
                    child: CircularProgressIndicator(
                      value: 1.0,
                      strokeWidth: 5,
                      color: UIColors.darkGrey,
                    ),
                  ),
                  // Progress bar
                  SizedBox(
                    width: 48,
                    height: 48,
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 5,
                      strokeCap: StrokeCap.round,
                      color: timerColor,
                      backgroundColor: Colors.transparent,
                    ),
                  ),
                  // Timer Text
                  Text(
                    timeRemaining.ceil().toString(),
                    style: numberStyle.copyWith(
                      fontSize: 14,
                      color: timerColor,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Difficulty label flash
          SizedBox(
            height: 20,
            child:
                _difficultyLabel != null
                    ? FadeTransition(
                      opacity: TweenSequence<double>([
                        TweenSequenceItem(
                          tween: Tween(begin: 0.0, end: 1.0),
                          weight: 25,
                        ),
                        TweenSequenceItem(
                          tween: Tween(begin: 1.0, end: 1.0),
                          weight: 50,
                        ),
                        TweenSequenceItem(
                          tween: Tween(begin: 1.0, end: 0.0),
                          weight: 25,
                        ),
                      ]).animate(_labelController),
                      child: Text(
                        _difficultyLabel!,
                        style: numberStyle.copyWith(
                          fontSize: 11,
                          color: UIColors.gold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    )
                    : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
