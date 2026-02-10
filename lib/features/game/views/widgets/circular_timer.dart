import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/game_provider.dart';
import '../../models/game_state.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/ui_colors.dart';

class CircularTimer extends ConsumerStatefulWidget {
  const CircularTimer({super.key});

  @override
  ConsumerState<CircularTimer> createState() => _CircularTimerState();
}

class _CircularTimerState extends ConsumerState<CircularTimer>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  Difficulty? _prevDifficulty;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _pulseAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.2), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.2, end: 1.0), weight: 50),
    ]).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
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

    // Listen for difficulty changes to trigger pulse
    if (_prevDifficulty != null && _prevDifficulty != gameState.difficulty) {
      _pulseController.forward(from: 0.0);
    }
    _prevDifficulty = gameState.difficulty;

    final numberStyle = Theme.of(context).numberStyle;
    final timerColor = _getTimerColor(timeRemaining);

    return Center(
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
              style: numberStyle.copyWith(fontSize: 14, color: timerColor),
            ),
          ],
        ),
      ),
    );
  }
}
