import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/game_provider.dart';
import '../../providers/high_score_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/ui_elements.dart';

class TopBar extends ConsumerWidget {
  const TopBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameProvider);
    final highScore = ref.watch(highScoreProvider);
    final numberStyle = Theme.of(context).numberStyle;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _StatItem(
            label: UIElements.highScore,
            value: highScore.toString(),
            style: numberStyle,
          ),
          _StatItem(
            label: UIElements.currentScore,
            value: gameState.score.toString(),
            style: numberStyle,
          ),
          _StatItem(
            label: UIElements.lives,
            value: gameState.lives.toString(),
            style: numberStyle,
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final TextStyle style;

  const _StatItem({
    required this.label,
    required this.value,
    required this.style,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 4),
        Text(value, style: style.copyWith(fontSize: 18)),
      ],
    );
  }
}
