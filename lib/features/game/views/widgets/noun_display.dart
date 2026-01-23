import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/game_provider.dart';
import '../../models/game_state.dart';
import '../../../../core/constants/ui_colors.dart';
import '../../../../core/constants/ui_elements.dart';

class NounDisplay extends ConsumerStatefulWidget {
  const NounDisplay({super.key});

  @override
  ConsumerState<NounDisplay> createState() => _NounDisplayState();
}

class _NounDisplayState extends ConsumerState<NounDisplay>
    with TickerProviderStateMixin {
  late AnimationController _countdownController;
  late Animation<double> _countdownAnimation;
  int _countdownValue = 3;

  @override
  void initState() {
    super.initState();
    _countdownController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _countdownAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.5, end: 1.2), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.2, end: 1.0), weight: 50),
    ]).animate(
      CurvedAnimation(parent: _countdownController, curve: Curves.easeInOut),
    );

    _countdownController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (_countdownValue > 1) {
          setState(() {
            _countdownValue--;
          });
          _countdownController.forward(from: 0.0);
        } else {
          ref.read(gameProvider.notifier).onCountdownComplete();
          setState(() {
            _countdownValue = 3; // Reset for next time
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _countdownController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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

    if (gameState.status == GameStatus.countdown) {
      if (!_countdownController.isAnimating) {
        _countdownController.forward(from: 0.0);
      }
      return Center(
        child: ScaleTransition(
          scale: _countdownAnimation,
          child: Text(
            '$_countdownValue',
            style: const TextStyle(
              fontSize: 80,
              fontWeight: FontWeight.bold,
              color: UIColors.gold,
            ),
          ),
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
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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
            Text(
              currentNoun.noun,
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color:
                    isRevealed && !gameState.wasCorrect
                        ? UIColors.wrong
                        : UIColors.correct,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          currentNoun.translation,
          style: const TextStyle(fontSize: 18, color: UIColors.grey),
        ),
      ],
    );
  }
}
