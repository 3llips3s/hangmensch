import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/game_provider.dart';
import '../models/game_state.dart';
import '../../../../core/providers/sound_controller.dart';
import 'widgets/top_bar.dart';
import 'widgets/article_button.dart';
import 'widgets/circular_timer.dart';
import 'widgets/noun_display.dart';
import 'widgets/fullscreen_button.dart';
import 'widgets/gallows_view.dart';
import 'widgets/game_over_dialog.dart';
import '../providers/high_score_provider.dart';
import '../../../core/constants/layout_constants.dart';

class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  bool _dialogShown = false;

  // We'll rely on the provider implementation.
  // If the provider is auto-disposed, it might stop music.
  // I defined it as NotifierProvider, which is not auto-disposed by default unless modifier is used.
  // I should probably stop it.

  void _showDialog() {
    if (_dialogShown) return;
    _dialogShown = true;

    final gameState = ref.read(gameProvider);
    final highScore = ref.read(highScoreProvider);

    showGameOverDialog(
      context: context,
      score: gameState.score,
      highScore: highScore,
      isNewHighScore: gameState.score >= highScore && gameState.score > 0,
    );
  }

  void _onDeathAnimationComplete() {
    _showDialog();
  }

  @override
  Widget build(BuildContext context) {
    final gameNotifier = ref.read(gameProvider.notifier);
    final gameState = ref.watch(gameProvider);

    // Listen for game events to play sounds
    ref.listen(gameProvider, (previous, next) {
      if (previous == null) return;
      final soundController = ref.read(soundControllerProvider.notifier);

      // Check for score increase (Correct Guess)
      if (next.score > previous.score) {
        soundController.playCorrect();
      }

      // Check for lives decrease (Incorrect Guess)
      if (next.lives < previous.lives) {
        soundController.playWrong();
      }

      // Check for Game Over triggers
      if (next.status == GameStatus.gameOver &&
          previous.status != GameStatus.gameOver) {
        soundController.playGameOver();
      }
    });

    // Reset dialog flag when game restarts
    if (gameState.status != GameStatus.gameOver) {
      _dialogShown = false;
    }

    return Scaffold(
      body: SafeArea(
        top: false, // Allow content to extend to very top
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: LayoutConstants.maxWidth,
            ),
            child: Padding(
              padding: LayoutConstants.screenPadding(context),
              child: Column(
                children: [
                  // 1. Top Bar (HUD)
                  const TopBar(),

                  // 2. Gallows Area
                  Expanded(
                    flex: 5,
                    child: Center(
                      child: GallowsView(
                        gameState: gameState,
                        onDeathAnimationComplete: _onDeathAnimationComplete,
                      ),
                    ),
                  ),
                  // 2b. Spacing
                  // const SizedBox(height: 8),

                  // 3. Circular Timer
                  const CircularTimer(),

                  const SizedBox(height: 8),

                  // 4. Noun + Translation (centered in remaining space)
                  const Expanded(flex: 2, child: Center(child: NounDisplay())),

                  const SizedBox(height: 8),

                  // 5. Article Buttons
                  Padding(
                    padding: const EdgeInsets.only(
                      bottom: kToolbarHeight * 0.5,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ArticleButton(
                          article: 'der',
                          onTap: () => gameNotifier.selectArticle('der'),
                          isEnabled: gameState.status == GameStatus.playing,
                        ),
                        ArticleButton(
                          article: 'die',
                          onTap: () => gameNotifier.selectArticle('die'),
                          isEnabled: gameState.status == GameStatus.playing,
                        ),
                        ArticleButton(
                          article: 'das',
                          onTap: () => gameNotifier.selectArticle('das'),
                          isEnabled: gameState.status == GameStatus.playing,
                        ),
                      ],
                    ),
                  ),

                  // 6. Footer (Fullscreen Toggle + Mute Toggle)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [const FullscreenButton(), _MuteButton()],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MuteButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isMuted = ref.watch(soundControllerProvider);
    return IconButton(
      icon: Icon(
        isMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
        color: Colors.white54,
      ),
      onPressed: () {
        ref.read(soundControllerProvider.notifier).toggleMute();
      },
      tooltip: isMuted ? 'Unmute' : 'Mute',
    );
  }
}
