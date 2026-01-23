import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/game_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/ui_colors.dart';

class CircularTimer extends ConsumerWidget {
  const CircularTimer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameProvider);
    final maxTime = gameState.maxTime;
    final timeRemaining = gameState.timeRemaining;
    final progress = (timeRemaining / maxTime).clamp(0.0, 1.0);

    final numberStyle = Theme.of(context).numberStyle;

    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background track
          const SizedBox(
            width: 80,
            height: 80,
            child: CircularProgressIndicator(
              value: 1.0,
              strokeWidth: 8,
              color: UIColors.darkGrey,
            ),
          ),
          // Progress bar
          SizedBox(
            width: 80,
            height: 80,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 8,
              color: UIColors.gold,
              backgroundColor: Colors.transparent,
            ),
          ),
          // Timer Text
          Text(
            timeRemaining.ceil().toString(),
            style: numberStyle.copyWith(fontSize: 24, color: UIColors.gold),
          ),
        ],
      ),
    );
  }
}
