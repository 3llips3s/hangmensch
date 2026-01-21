import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/game_provider.dart';
import '../../models/game_state.dart';
import '../../../../core/constants/ui_colors.dart';
import '../../../../core/constants/ui_elements.dart';

class NounDisplay extends ConsumerWidget {
  const NounDisplay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameProvider);

    if (gameState.status == GameStatus.idle) {
      return GestureDetector(
        onTap: () => ref.read(gameProvider.notifier).startGame(),
        child: const Column(
          children: [
            Text(
              UIElements.tapToStart,
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: UIColors.white,
              ),
            ),
          ],
        ),
      );
    }

    final currentNoun = gameState.currentNoun;
    if (currentNoun == null) return const SizedBox.shrink();

    final isRevealed =
        gameState.status == GameStatus.revealed ||
        gameState.status == GameStatus.gameOver;

    Color wordColor = UIColors.white;
    if (isRevealed) {
      wordColor = gameState.wasCorrect ? UIColors.correct : UIColors.wrong;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Translation (always shown in grey)
        Text(
          currentNoun.translation,
          style: const TextStyle(fontSize: 18, color: UIColors.grey),
        ),
        const SizedBox(height: 8),
        // Noun (with optional article reveal)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isRevealed) ...[
              Text(
                '${currentNoun.article} ',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: wordColor,
                ),
              ),
            ],
            Text(
              currentNoun.noun,
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: wordColor,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
