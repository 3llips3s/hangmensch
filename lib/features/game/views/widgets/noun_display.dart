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

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Noun Area (with sliding article)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Article with slide-in animation
            AnimatedSlide(
              offset: isRevealed ? Offset.zero : const Offset(-0.5, 0),
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutBack,
              child: AnimatedOpacity(
                opacity: isRevealed ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: Text(
                  '${currentNoun.article} ',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color:
                        gameState.wasCorrect
                            ? UIColors.correct
                            : UIColors.wrong,
                  ),
                ),
              ),
            ),
            // Noun
            Text(
              currentNoun.noun,
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                // Noun stays Gold as brand color, or turns Red if wrong (following PRD)
                color:
                    isRevealed && !gameState.wasCorrect
                        ? UIColors.wrong
                        : UIColors.correct,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Translation (now below the noun)
        Text(
          currentNoun.translation,
          style: const TextStyle(fontSize: 18, color: UIColors.grey),
        ),
      ],
    );
  }
}
