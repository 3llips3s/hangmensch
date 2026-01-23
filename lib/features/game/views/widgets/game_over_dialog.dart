import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/game_provider.dart';
import '../../../../core/constants/ui_colors.dart';
import '../../../../core/constants/ui_elements.dart';
import '../../../../core/theme/app_theme.dart';

class GameOverDialog extends ConsumerWidget {
  final int score;
  final int highScore;
  final bool isNewHighScore;

  const GameOverDialog({
    super.key,
    required this.score,
    required this.highScore,
    required this.isNewHighScore,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final numberStyle = Theme.of(context).numberStyle;

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 300,
          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
          decoration: BoxDecoration(
            color: UIColors.darkGrey,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: UIColors.gold, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Tombstone
              const Text('🪦', style: TextStyle(fontSize: 64)),
              const SizedBox(height: 24),

              // Current Score
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    UIElements.currentScoreIcon,
                    color: UIColors.white,
                    size: 28,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$score',
                    style: numberStyle.copyWith(
                      fontSize: 48,
                      color: UIColors.white,
                    ),
                  ),
                  if (isNewHighScore) ...[
                    const SizedBox(width: 8),
                    const Text('✨', style: TextStyle(fontSize: 24)),
                  ],
                ],
              ),
              const SizedBox(height: 8),

              // High Score
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    UIElements.highScoreIcon,
                    color: UIColors.white.withOpacity(0.5),
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'High: $highScore',
                    style: numberStyle.copyWith(
                      fontSize: 18,
                      color: UIColors.white.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Restart Button
              IconButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  ref.read(gameProvider.notifier).restartGame();
                },
                icon: const Icon(Icons.refresh_rounded),
                iconSize: 48,
                color: UIColors.gold,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void showGameOverDialog({
  required BuildContext context,
  required int score,
  required int highScore,
  required bool isNewHighScore,
}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black.withOpacity(0.7),
    builder:
        (context) => GameOverDialog(
          score: score,
          highScore: highScore,
          isNewHighScore: isNewHighScore,
        ),
  );
}
