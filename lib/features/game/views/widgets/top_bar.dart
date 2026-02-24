import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/game_provider.dart';
import '../../providers/high_score_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/ui_elements.dart';
import '../../../../core/constants/ui_colors.dart';

/// A HUD component showing the high score, current score, and remaining lives.
class TopBar extends ConsumerWidget {
  const TopBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameProvider);
    final highScore = ref.watch(highScoreProvider);
    final numberStyle = Theme.of(context).numberStyle;

    final topPadding = MediaQuery.of(context).padding.top;

    return Padding(
      padding: EdgeInsets.only(top: topPadding + 8, bottom: 8),
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

/// A private component for displaying a single numerical statistic with an icon.
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
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 12),
        Text(value, style: style.copyWith(fontSize: 20, color: UIColors.white)),
      ],
    );
  }
}
