import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/game_provider.dart';
import '../../providers/high_score_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/ui_elements.dart';
import '../../../../core/constants/ui_colors.dart';

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
            icon: UIElements.highScoreIcon,
            value: highScore.toString(),
            color: UIColors.gold,
            style: numberStyle,
          ),
          _StatItem(
            icon: UIElements.currentScoreIcon,
            value: gameState.score.toString(),
            color: UIColors.grey,
            style: numberStyle,
          ),
          _StatItem(
            icon: UIElements.livesIcon,
            value: gameState.lives.toString(),
            color: UIColors.red,
            style: numberStyle,
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final Color color;
  final TextStyle style;

  const _StatItem({
    required this.icon,
    required this.value,
    required this.color,
    required this.style,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 24, color: color),
        const SizedBox(width: 8),
        Text(value, style: style.copyWith(fontSize: 24, color: UIColors.white)),
      ],
    );
  }
}
