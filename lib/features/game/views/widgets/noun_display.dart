import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/game_provider.dart';
import '../../models/game_state.dart';
import '../../../../core/constants/ui_colors.dart';
import '../../../../core/constants/ui_elements.dart';

/// A widget that manages the display of the current noun, translation, and countdown.
class NounDisplay extends ConsumerStatefulWidget {
  /// Whether the surrounding layout is compact (e.g. non-fullscreen mobile browser).
  final bool isCompact;
  final bool hideStartPrompt;
  final bool isDesktop;

  const NounDisplay({
    super.key,
    this.isCompact = false,
    this.hideStartPrompt = false,
    this.isDesktop = false,
  });

  @override
  ConsumerState<NounDisplay> createState() => _NounDisplayState();
}

class _NounDisplayState extends ConsumerState<NounDisplay>
    with TickerProviderStateMixin {
  /// Controller for the countdown scale transition.
  late AnimationController _countdownController;
  late Animation<double> _countdownAnimation;

  /// Controller for the pulse animation.
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

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

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOutSine),
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
    _pulseController.dispose();
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
        child: AnimatedOpacity(
          opacity: widget.hideStartPrompt ? 0.0 : 1.0,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ScaleTransition(
                scale: _pulseAnimation,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.isDesktop)
                      Container(
                        margin: const EdgeInsets.only(right: 12),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: UIColors.darkGrey,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: UIColors.gold.withValues(alpha: 0.5),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.5),
                              offset: const Offset(0, 2),
                              blurRadius: 0,
                            ),
                          ],
                        ),
                        child: const Text(
                          'SPACE',
                          style: TextStyle(
                            color: UIColors.gold,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    Text(
                      widget.isDesktop ? '-> Los!' : UIElements.tapToStart,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: UIColors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
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
      // Reduce font size on compact viewports to stay within the allocated SizedBox height.
      final countdownFontSize = widget.isCompact ? 56.0 : 80.0;
      return Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: ScaleTransition(
            scale: _countdownAnimation,
            child: Text(
              '$_countdownValue',
              key: ValueKey(_countdownValue),
              style: TextStyle(
                fontSize: countdownFontSize,
                fontWeight: FontWeight.bold,
                color: UIColors.gold,
              ),
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

    final fontSize = widget.isCompact ? 40.0 : 48.0;

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
        SizedBox(height: widget.isCompact ? 2 : 4),
        Text(
          currentNoun.translation,
          style: TextStyle(
            fontSize: widget.isCompact ? 14 : 18,
            color: UIColors.grey,
          ),
        ),
      ],
    );
  }
}
