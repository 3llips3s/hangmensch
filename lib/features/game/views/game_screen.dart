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
import '../../../core/constants/ui_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/web_fullscreen.dart' as web_utils;

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
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      _showDialog();
    }
  }

  @override
  Widget build(BuildContext context) {
    final gameNotifier = ref.read(gameProvider.notifier);
    final gameState = ref.watch(gameProvider);

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

    // True only when running on web AND not in fullscreen mode.
    // Native apps always use false — no layout changes there.
    final isCompact = kIsWeb && !web_utils.isFullscreenActive;

    return Scaffold(
      body: SafeArea(
        top: false,
        bottom: !kIsWeb,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: LayoutConstants.maxWidth,
            ),
            child: Padding(
              padding: LayoutConstants.screenPadding(context).copyWith(
                top: 8,
                bottom: isCompact ? 8 : LayoutConstants.verticalPadding,
              ),
              child: Column(
                children: [
                  const TopBar(),
                  const Spacer(flex: 3),
                  Center(
                    child: GallowsView(
                      gameState: gameState,
                      onDeathAnimationComplete: _onDeathAnimationComplete,
                    ),
                  ),
                  const Spacer(flex: 1),
                  const CircularTimer(),
                  // Zero-height overlay: label renders into the Spacer below without
                  // taking any layout space, so NounDisplay remains perfectly centered
                  // between the equal Spacer(2) above and below it. Safe on all platforms
                  // because the label (≤22px) always fits within Spacer(2).
                  SizedBox(
                    height: 0,
                    child: OverflowBox(
                      alignment: Alignment.topCenter,
                      maxHeight: 22,
                      maxWidth: 200,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: const _DifficultyLabel(),
                      ),
                    ),
                  ),
                  const Spacer(flex: 2),
                  SizedBox(
                    height: isCompact ? 80 : 100,
                    child: Center(child: NounDisplay(isCompact: isCompact)),
                  ),
                  const Spacer(flex: 2),
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
                  if (isCompact) const SizedBox(height: 20),
                  if (!isCompact) const Spacer(flex: 1),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [const FullscreenButton(), _MuteButton()],
                  ),
                  if (!isCompact)
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

/// A label that fades in/out to display the current difficulty name.
///
/// Manages its own animation lifecycle and responds to [gameProvider] state changes.
/// Rendered as a zero-layout-height overlay in [GameScreen] so it never displaces
/// surrounding widgets.
class _DifficultyLabel extends ConsumerStatefulWidget {
  const _DifficultyLabel();

  @override
  ConsumerState<_DifficultyLabel> createState() => _DifficultyLabelState();
}

class _DifficultyLabelState extends ConsumerState<_DifficultyLabel>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  String? _label;

  static const _labels = {
    'easy': 'chill',
    'medium': 'zügig',
    'hard': 'hektik',
    'infinite': 'blitz',
  };

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Triggers the fade animation for the given [difficultyName].
  void _trigger(String difficultyName) {
    setState(() => _label = _labels[difficultyName] ?? difficultyName);
    _controller.forward(from: 0.0).then((_) {
      if (mounted) setState(() => _label = null);
    });
  }

  @override
  Widget build(BuildContext context) {
    final numberStyle = Theme.of(context).numberStyle;

    ref.listen(gameProvider.select((s) => s.difficulty), (previous, next) {
      if (previous != null && next != previous) _trigger(next.name);
    });

    ref.listen(gameProvider.select((s) => s.status), (previous, next) {
      if (next.name == 'playing' &&
          (previous?.name == 'idle' || previous?.name == 'countdown')) {
        _trigger(ref.read(gameProvider).difficulty.name);
      }
    });

    if (_label == null) return const SizedBox.shrink();

    return FadeTransition(
      opacity: TweenSequence<double>([
        TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 25),
        TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 50),
        TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 25),
      ]).animate(_controller),
      child: Text(
        _label!,
        textAlign: TextAlign.center,
        style: numberStyle.copyWith(
          fontSize: 11,
          color: UIColors.gold,
          letterSpacing: 1.2,
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
