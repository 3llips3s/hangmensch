import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/game_provider.dart';
import '../../../../core/constants/ui_colors.dart';
import '../../../../core/constants/ui_elements.dart';
import '../../../../core/theme/app_theme.dart';

/// A dialog displayed when the game ends, showing the final score and high score.
class GameOverDialog extends ConsumerStatefulWidget {
  /// The score achieved in the session.
  final int score;

  /// The player's persistent high score.
  final int highScore;

  /// Whether the current score represents a new high score.
  final bool isNewHighScore;

  const GameOverDialog({
    super.key,
    required this.score,
    required this.highScore,
    required this.isNewHighScore,
  });

  @override
  ConsumerState<GameOverDialog> createState() => _GameOverDialogState();
}

class _GameOverDialogState extends ConsumerState<GameOverDialog>
    with SingleTickerProviderStateMixin {
  /// Controller for the entrance slide and fade animation.
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutBack),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

    _slideController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final numberStyle = Theme.of(context).numberStyle;
    const darkContent = Color(0xFF1A1A1A);

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
      child: Center(
        child: SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: 270,
                padding: const EdgeInsets.symmetric(
                  vertical: 32,
                  horizontal: 24,
                ),
                decoration: BoxDecoration(
                  color: UIColors.gold,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('🪦', style: TextStyle(fontSize: 72)),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          UIElements.currentScoreIcon,
                          color: darkContent,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${widget.score}',
                          style: numberStyle.copyWith(
                            fontSize: 32,
                            color: darkContent,
                          ),
                        ),
                        if (widget.isNewHighScore) ...[
                          const SizedBox(width: 8),
                          const Text('✨', style: TextStyle(fontSize: 20)),
                        ],
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          UIElements.highScoreIcon,
                          color: darkContent.withOpacity(0.6),
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${widget.highScore}',
                          style: numberStyle.copyWith(
                            fontSize: 20,
                            color: darkContent.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    IconButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        ref.read(gameProvider.notifier).restartGame();
                      },
                      icon: const Icon(Icons.refresh_rounded),
                      iconSize: 56,
                      color: darkContent,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Helper function to display the [GameOverDialog].
void showGameOverDialog({
  required BuildContext context,
  required int score,
  required int highScore,
  required bool isNewHighScore,
}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black26,
    builder:
        (context) => GameOverDialog(
          score: score,
          highScore: highScore,
          isNewHighScore: isNewHighScore,
        ),
  );
}
