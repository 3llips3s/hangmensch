import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/game_provider.dart';
import '../models/game_state.dart';
import 'widgets/top_bar.dart';
import 'widgets/article_button.dart';
import 'widgets/circular_timer.dart';
import 'widgets/noun_display.dart';
import 'widgets/fullscreen_button.dart';
import '../../../core/constants/layout_constants.dart';

class GameScreen extends ConsumerWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameNotifier = ref.read(gameProvider.notifier);
    final gameState = ref.watch(gameProvider);

    return Scaffold(
      body: SafeArea(
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

                  // 2. Gallows Area (Placeholder for Phase 5)
                  const Expanded(
                    flex: 3,
                    child: Center(
                      child: Text(
                        '🎨 Gallows Area',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 3. Circular Timer
                  const CircularTimer(),

                  const Spacer(),

                  // 4. Noun + Translation
                  const NounDisplay(),

                  const Spacer(),

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

                  const SizedBox(height: 16),

                  // 6. Footer (Fullscreen Toggle)
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [FullscreenButton()],
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
