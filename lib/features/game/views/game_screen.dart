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

  // Provider logic handles sound playback.

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

  void _onDeathAnimationComplete() async {
    // Wait for the trapdoor sound (now 3s long) to play out mostly/fully before showing dialog
    // The drop animation itself takes some time, but the sound is 3s.
    // We add a delay to ensure the player hears the "fall" and the silence/thud before UI interruption.
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      _showDialog();
    }
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
        // Sound is now handled in GallowsView to sync with animation
      }

      // Check for Game Over triggers
      // We do NOT play sound here anymore.
      // The sound will be triggered by the GallowsView when the drop animation starts.
      // This allows perfect sync with the visual "trapdoor opening".
      if (next.status == GameStatus.gameOver &&
          previous.status != GameStatus.gameOver) {
        // Handled in GallowsView/onDeathAnimationComplete logic or sync
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
              // LayoutConstants.screenPadding includes vertical padding (32.0).
              // Since we are in SafeArea, this adds to the top.
              // We want to reduce the top gap.
              padding: LayoutConstants.screenPadding(context).copyWith(top: 8),
              child: Column(
                children: [
                  // 1. Top Bar (HUD)
                  const TopBar(),

                  // 2. Gallows Area
                  const Spacer(flex: 3),
                  Center(
                    child: GallowsView(
                      gameState: gameState,
                      onDeathAnimationComplete: _onDeathAnimationComplete,
                    ),
                  ),
                  const Spacer(flex: 1),

                  // 3. Circular Timer
                  const CircularTimer(),
                  const Spacer(flex: 2),

                  // 4. Noun + Translation (centered in remaining space)
                  const SizedBox(
                    height: 100,
                    child: Center(child: NounDisplay()),
                  ),
                  const Spacer(flex: 2),

                  // 5. Article Buttons
                  Row(
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
                  const SizedBox(height: LayoutConstants.spaceSm),

                  // 6. Footer (Fullscreen Toggle + Mute Toggle)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [const FullscreenButton(), _MuteButton()],
                  ),
                  const SizedBox(height: LayoutConstants.spaceSm),
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
    final gameState = ref.watch(gameProvider);
    final isPlaying = gameState.status == GameStatus.playing;

    return Padding(
      // Align with the "Das" button (rightmost article button)
      // Article buttons have some internal spacing, but let's approximate
      // or match the screen padding if they are flush.
      // The layout uses mainAxisAlignment.spaceEvenly for articles.
      // To strictly "flush" right might require visual checking or using the same spacing.
      // Let's add standard right padding to move it inward.
      padding: const EdgeInsets.only(right: 4.0),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: isPlaying ? 0.25 : 1.0,
        child: IconButton(
          iconSize: 26, // Significantly bigger
          icon: Icon(
            isMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
            color: Colors.white54,
          ),
          onPressed: () {
            ref.read(soundControllerProvider.notifier).toggleMute();
          },
          tooltip: isMuted ? 'Unmute' : 'Mute',
        ),
      ),
    );
  }
}
