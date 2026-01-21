import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/game_provider.dart';
import '../models/game_state.dart';
import 'widgets/top_bar.dart';
import 'widgets/article_button.dart';
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
                  const TopBar(),

                  // Progress indicator (placeholder for Phase 4)
                  const SizedBox(height: 8),
                  const LinearProgressIndicator(
                    value: 0.5,
                    backgroundColor: Color(0xFF222222),
                    valueColor: AlwaysStoppedAnimation(Color(0xFFFFCE00)),
                  ),

                  const Spacer(),

                  // Hangmensch Area (placeholder for Phase 5)
                  const Center(
                    child: Text(
                      '🎨 Hangmensch Area',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),

                  const Spacer(),

                  // Noun Area (placeholder for Phase 4)
                  Center(
                    child: Text(
                      gameState.status == GameStatus.idle
                          ? 'Tap -> Los'
                          : gameState.currentNoun?.noun ?? '',
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const Spacer(),

                  // Article Buttons
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

                  const SizedBox(height: 32),

                  // Start Button (Temporary until GameStatus handled properly in UI)
                  if (gameState.status == GameStatus.idle)
                    ElevatedButton(
                      onPressed: () => gameNotifier.startGame(),
                      child: const Text('START'),
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
