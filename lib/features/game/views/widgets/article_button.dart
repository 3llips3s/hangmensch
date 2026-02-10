import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/game_provider.dart';
import '../../models/game_state.dart';
import '../../../../core/constants/ui_colors.dart';
import '../../../../core/constants/layout_constants.dart';

class ArticleButton extends ConsumerStatefulWidget {
  final String article;
  final VoidCallback onTap;
  final bool isEnabled;

  const ArticleButton({
    super.key,
    required this.article,
    required this.onTap,
    this.isEnabled = true,
  });

  @override
  ConsumerState<ArticleButton> createState() => _ArticleButtonState();
}

class _ArticleButtonState extends ConsumerState<ArticleButton>
    with TickerProviderStateMixin {
  late AnimationController _pressController;
  late Animation<double> _scaleAnimation;

  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeInOut),
    );

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _pulseAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.1), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.1, end: 1.0), weight: 50),
    ]).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    _shakeController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameProvider);
    final isRevealed =
        gameState.status == GameStatus.revealed ||
        gameState.status == GameStatus.gameOver;
    final isCorrectArticle =
        gameState.revealedArticle?.toLowerCase() ==
        widget.article.toLowerCase();
    final wasThisOneTapped =
        gameState.lastSelectedArticle?.toLowerCase() ==
        widget.article.toLowerCase();
    final isWrongSelection =
        isRevealed && wasThisOneTapped && !isCorrectArticle;

    // Trigger animations based on state
    if (isRevealed && isCorrectArticle) {
      if (!_pulseController.isAnimating) _pulseController.forward(from: 0.0);
    }

    return GestureDetector(
      onTapDown: (_) => widget.isEnabled ? _pressController.forward() : null,
      onTapUp: (_) => widget.isEnabled ? _pressController.reverse() : null,
      onTapCancel: () => widget.isEnabled ? _pressController.reverse() : null,
      onTap: () {
        if (widget.isEnabled) {
          widget.onTap();
          final isCorrect =
              gameState.currentNoun?.article.toLowerCase() ==
              widget.article.toLowerCase();
          if (!isCorrect) {
            _shakeController.forward(from: 0.0);
          }
        }
      },
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _scaleAnimation,
          _shakeAnimation,
          _pulseAnimation,
        ]),
        builder: (context, child) {
          Color borderColor = UIColors.gold;
          Color fillColor = Colors.transparent;

          if (isRevealed) {
            if (isCorrectArticle) {
              borderColor = UIColors.gold;
              fillColor = UIColors.gold.withOpacity(0.2);
            } else if (isWrongSelection) {
              borderColor = UIColors.wrong;
              fillColor = UIColors.wrong.withOpacity(0.2);
            }
          }

          return Transform.translate(
            offset: Offset(
              sin(_shakeController.value * pi * 4) * _shakeAnimation.value,
              0,
            ),
            child: Transform.scale(
              scale: _scaleAnimation.value * _pulseAnimation.value,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: widget.isEnabled ? 1.0 : 0.5,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 28,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: borderColor,
                      width: LayoutConstants.buttonBorderWidth,
                    ),
                    borderRadius: BorderRadius.circular(
                      LayoutConstants.borderRadius,
                    ),
                    color: fillColor,
                  ),
                  child: Text(
                    widget.article,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: UIColors.white,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
