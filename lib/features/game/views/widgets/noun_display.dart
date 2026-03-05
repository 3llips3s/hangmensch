import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/game_provider.dart';
import '../../models/game_state.dart';
import '../../../../core/constants/ui_colors.dart';
import '../../../../core/constants/ui_elements.dart';

/// A widget that manages the display of the current noun, translation, and countdown.
class NounDisplay extends ConsumerStatefulWidget {
  const NounDisplay({super.key});

  @override
  ConsumerState<NounDisplay> createState() => _NounDisplayState();
}

class _NounDisplayState extends ConsumerState<NounDisplay>
    with TickerProviderStateMixin {
  /// Controller for the countdown scale transition.
  late AnimationController _countdownController;
  late Animation<double> _countdownAnimation;

  /// The current value shown during the initiation countdown.
  int _countdownValue = 3;

  /// Whether the countdown sequence is currently active.
  bool _isCountingDown = false;

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
          setState(() {
            _isCountingDown = false;
          });
          ref.read(gameProvider.notifier).onCountdownComplete();
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
      _countdownValue = 3;
      _isCountingDown = false;
      return GestureDetector(
        onTap: () => ref.read(gameProvider.notifier).startGame(),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              UIElements.tapToStart,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: UIColors.white,
              ),
            ),
          ],
        ),
      );
    }

    if (gameState.status == GameStatus.countdown) {
      if (!_isCountingDown) {
        _isCountingDown = true;
        _countdownValue = 3;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _countdownController.forward(from: 0.0);
        });
      }
      return Center(
        child: ScaleTransition(
          scale: _countdownAnimation,
          child: Text(
            '$_countdownValue',
            key: ValueKey(_countdownValue),
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

    return LayoutBuilder(
      builder: (context, constraints) {
        final screenHeight = MediaQuery.of(context).size.height;
        final isVeryShortScreen = screenHeight < 540;
        final fontSize = isVeryShortScreen ? 40.0 : 48.0;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (isRevealed && gameState.revealedArticle != null)
                    AnimatedSlide(
                      offset: isRevealed ? Offset.zero : const Offset(-0.5, 0),
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeOutBack,
                      child: AnimatedOpacity(
                        opacity: isRevealed ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 300),
                        child: Text(
                          '${gameState.revealedArticle} ',
                          style: TextStyle(
                            fontSize: fontSize,
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
                      fontSize: fontSize,
                      fontWeight: FontWeight.bold,
                      color:
                          isRevealed && !gameState.wasCorrect
                              ? UIColors.wrong
                              : UIColors.correct,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: isVeryShortScreen ? 2 : 4),
            Text(
              currentNoun.translation,
              style: TextStyle(
                fontSize: isVeryShortScreen ? 14 : 18,
                color: UIColors.grey,
              ),
            ),
          ],
        );
      },
    );
  }
}
