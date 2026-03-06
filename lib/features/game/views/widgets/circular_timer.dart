import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/game_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/ui_colors.dart';

/// A widget that displays a circular countdown timer with adaptive colors and animations.
///
/// Features a pulsing effect and glow transitions when the difficulty level changes.
/// The difficulty label is rendered separately in the parent layout via [DifficultyLabelOverlay].
class CircularTimer extends ConsumerStatefulWidget {
  const CircularTimer({super.key});

  @override
  ConsumerState<CircularTimer> createState() => _CircularTimerState();
}

class _CircularTimerState extends ConsumerState<CircularTimer>
    with TickerProviderStateMixin {
  /// Controller for the scale pulse and elastic bounce effect.
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  /// Controller for the radiating gold shadow glow effect.
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _pulseAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.2), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.2, end: 0.9), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 0.9, end: 1.0), weight: 30),
    ]).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeOut),
    );

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _glowAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 24.0), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 24.0, end: 0.0), weight: 60),
    ]).animate(CurvedAnimation(parent: _glowController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  /// Triggers the pulse and glow animations on difficulty change or game start.
  void _triggerPulse() {
    _pulseController.forward(from: 0.0);
    _glowController.forward(from: 0.0);
  }

  /// Returns the appropriate color based on the [timeRemaining].
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

    /// Listens for [Difficulty] transitions to trigger the pulse and glow.
    ref.listen(gameProvider.select((s) => s.difficulty), (previous, next) {
      if (previous != null && next != previous) _triggerPulse();
    });

    /// Listens for game start to trigger the initial pulse.
    ref.listen(gameProvider.select((s) => s.status), (previous, next) {
      if (next.name == 'playing' &&
          (previous?.name == 'idle' || previous?.name == 'countdown')) {
        _triggerPulse();
      }
    });

    final numberStyle = Theme.of(context).numberStyle;
    final timerColor =
        _pulseController.isAnimating
            ? UIColors.gold
            : _getTimerColor(timeRemaining);

    return Center(
      child: AnimatedBuilder(
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
          child: SizedBox(
            width: 48,
            height: 48,
            child: Stack(
              alignment: Alignment.center,
              children: [
                const CircularProgressIndicator(
                  value: 1.0,
                  strokeWidth: 5,
                  color: UIColors.darkGrey,
                ),
                CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 5,
                  strokeCap: StrokeCap.round,
                  color: timerColor,
                  backgroundColor: Colors.transparent,
                ),
                Text(
                  timeRemaining.ceil().toString(),
                  style: numberStyle.copyWith(fontSize: 14, color: timerColor),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
