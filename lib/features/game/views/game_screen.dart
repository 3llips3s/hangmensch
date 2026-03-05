import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
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

/// Represents the primary game screen where the core gameplay loop occurs.
class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  bool _dialogShown = false;

  /// Displays the game over dialog with final [score] and [highScore].
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

  /// Handles the completion of the death animation by triggering the game over dialog.
  void _onDeathAnimationComplete() async {
    /// Wait for the audio and visual cues to conclude before showing the dialog.
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      _showDialog();
    }
  }

  @override
  Widget build(BuildContext context) {
    final gameNotifier = ref.read(gameProvider.notifier);
    final gameState = ref.watch(gameProvider);

    /// Listens for game state transitions to trigger sound effects.
    ref.listen(gameProvider, (previous, next) {
      if (previous == null) return;
      final soundController = ref.read(soundControllerProvider.notifier);

      if (next.score > previous.score) {
        soundController.playCorrect();
      }
    });

    if (gameState.status != GameStatus.gameOver) {
      _dialogShown = false;
    }

    return Scaffold(
      body: SafeArea(
        top: false,
        bottom: !kIsWeb,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: LayoutConstants.maxWidth,
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isShortScreen = constraints.maxHeight < 620;
                final isVeryShortScreen = constraints.maxHeight < 540;

                return Padding(
                  padding: LayoutConstants.screenPadding(context).copyWith(
                    top: 8,
                    bottom:
                        (kIsWeb && isShortScreen)
                            ? 16
                            : LayoutConstants.verticalPadding,
                  ),
                  child: Column(
                    children: [
                      const TopBar(),
                      Spacer(flex: isShortScreen ? 1 : 3),
                      Center(
                        child: GallowsView(
                          gameState: gameState,
                          onDeathAnimationComplete: _onDeathAnimationComplete,
                        ),
                      ),
                      Spacer(flex: isShortScreen ? 1 : 1),
                      const CircularTimer(),
                      Spacer(flex: isShortScreen ? 1 : 2),
                      SizedBox(
                        height: isVeryShortScreen ? 70 : 100,
                        child: const Center(child: NounDisplay()),
                      ),
                      Spacer(flex: isShortScreen ? 1 : 2),
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
                      if (!isShortScreen) const Spacer(flex: 1),
                      if (isShortScreen) const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [const FullscreenButton(), _MuteButton()],
                      ),
                      if (!isShortScreen)
                        const SizedBox(height: LayoutConstants.spaceSm),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

/// A private component for toggling the game's mute state.
class _MuteButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isMuted = ref.watch(soundControllerProvider);
    final gameState = ref.watch(gameProvider);
    final isPlaying = gameState.status == GameStatus.playing;

    return Padding(
      padding: const EdgeInsets.only(right: 4.0),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: isPlaying ? 0.25 : 1.0,
        child: IconButton(
          iconSize: 26,
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
