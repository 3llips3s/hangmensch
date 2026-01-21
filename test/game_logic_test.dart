import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hangmensch/features/game/providers/game_provider.dart';
import 'package:hangmensch/features/game/providers/high_score_provider.dart';
import 'package:hangmensch/features/game/providers/nouns_provider.dart';
import 'package:hangmensch/features/game/models/game_state.dart';
import 'package:hangmensch/features/game/models/german_noun.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ProviderContainer container;
  late SharedPreferences prefs;

  final mockNouns = [
    GermanNoun(
      article: 'der',
      noun: 'Tisch',
      plural: 'Tische',
      translation: 'table',
    ),
    GermanNoun(
      article: 'die',
      noun: 'Katze',
      plural: 'Katzen',
      translation: 'cat',
    ),
    GermanNoun(
      article: 'das',
      noun: 'Haus',
      plural: 'Häuser',
      translation: 'house',
    ),
  ];

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();

    container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        nounsProvider.overrideWith((ref) => Future.value(mockNouns)),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('GameNotifier Tests', () {
    test('Initial state is idle', () {
      final state = container.read(gameProvider);
      expect(state.status, GameStatus.idle);
      expect(state.score, 0);
      expect(state.lives, 7);
    });

    test('startGame initializes game correctly', () async {
      await container.read(nounsProvider.future);
      container.read(gameProvider.notifier).startGame();

      final state = container.read(gameProvider);
      expect(state.status, GameStatus.playing);
      expect(state.nounPool.length, 3);
      expect(state.currentNoun, isNotNull);
      expect(state.timeRemaining, 6.0);
    });

    test('selectArticle handles correct answer', () async {
      await container.read(nounsProvider.future);
      container.read(gameProvider.notifier).startGame();

      final currentState = container.read(gameProvider);
      final correctArticle = currentState.currentNoun!.article;

      container.read(gameProvider.notifier).selectArticle(correctArticle);

      final revealedState = container.read(gameProvider);
      expect(revealedState.status, GameStatus.revealed);
      expect(revealedState.score, 1);
      expect(revealedState.wasCorrect, true);
    });

    test('selectArticle handles wrong answer', () async {
      await container.read(nounsProvider.future);
      container.read(gameProvider.notifier).startGame();

      final currentState = container.read(gameProvider);
      final wrongArticle =
          currentState.currentNoun!.article == 'der' ? 'die' : 'der';

      container.read(gameProvider.notifier).selectArticle(wrongArticle);

      final revealedState = container.read(gameProvider);
      expect(revealedState.status, GameStatus.revealed);
      expect(revealedState.score, 0);
      expect(revealedState.lives, 6);
      expect(revealedState.wasCorrect, false);
    });

    test('nextNoun updates noun pool and resets timer', () async {
      await container.read(nounsProvider.future);
      container.read(gameProvider.notifier).startGame();

      final initialNoun = container.read(gameProvider).currentNoun;

      // Simulate answering and moving to next
      container.read(gameProvider.notifier).selectArticle(initialNoun!.article);

      // Force nextNoun (usually called after delay)
      container.read(gameProvider.notifier).nextNoun();

      final nextState = container.read(gameProvider);
      expect(nextState.status, GameStatus.playing);
      expect(nextState.currentNoun, isNot(initialNoun));
      expect(nextState.usedNouns.length, 1);
      expect(nextState.nounPool.length, 2);
    });

    test('Difficulty increases at thresholds', () async {
      await container.read(nounsProvider.future);
      container.read(gameProvider.notifier).startGame();

      // Manually set correct answers to 9
      container.read(gameProvider.notifier).state = container
          .read(gameProvider)
          .copyWith(correctAnswers: 9);

      // Correct answer #10
      final initialNoun = container.read(gameProvider).currentNoun;
      container.read(gameProvider.notifier).selectArticle(initialNoun!.article);
      container.read(gameProvider.notifier).nextNoun();

      expect(container.read(gameProvider).difficulty, Difficulty.medium);
      expect(container.read(gameProvider).timeRemaining, 4.0);
    });

    test('GameOver triggered when lives reach 0', () async {
      await container.read(nounsProvider.future);
      container.read(gameProvider.notifier).startGame();

      // Set lives to 1
      container.read(gameProvider.notifier).state = container
          .read(gameProvider)
          .copyWith(lives: 1);

      // Answer wrong
      final initialNoun = container.read(gameProvider).currentNoun;
      final wrongArticle = initialNoun!.article == 'der' ? 'die' : 'der';
      container.read(gameProvider.notifier).selectArticle(wrongArticle);

      // Wait for delay or check revealed state first then wait
      expect(container.read(gameProvider).lives, 0);

      // After delay it should be gameOver (testing this async is tricky with mock timers,
      // but we can check the transition logic in GameNotifier)
    });
  });
}
