import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/game_state.dart';
import '../models/german_noun.dart';
import 'nouns_provider.dart';
import 'high_score_provider.dart';

class GameNotifier extends StateNotifier<GameState> {
  final Ref _ref;
  Timer? _timer;

  GameNotifier(this._ref) : super(const GameState());

  void startGame() async {
    debugPrint('GameNotifier: Starting initial game...');
    _startInitialGame();
  }

  void restartGame() async {
    debugPrint('GameNotifier: Restarting game with countdown...');
    state = state.copyWith(
      status: GameStatus.countdown,
      lives: 7, // Clear hangman immediately
      score: 0, // Reset score immediately
      timeRemaining: 9.0, // Reset timer for countdown view
    );
    // 3 seconds countdown handled in UI, then we call _startInitialGame
  }

  void onCountdownComplete() {
    _startInitialGame();
  }

  void _startInitialGame() async {
    try {
      final nouns = await _ref.read(nounsProvider.future);

      if (nouns.isEmpty) {
        debugPrint('GameNotifier: Cannot start, nouns pool is empty!');
        return;
      }

      final shuffledPool = List<GermanNoun>.from(nouns)..shuffle();
      state = GameState(
        status: GameStatus.playing,
        nounPool: shuffledPool,
        currentNoun: shuffledPool.first,
        timeRemaining: 9.0, // Easy mode default
      );

      debugPrint(
        'GameNotifier: Game started with ${shuffledPool.length} nouns.',
      );
      _startTimer();
    } catch (e) {
      debugPrint('GameNotifier: Failed to start game: $e');
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (state.status != GameStatus.playing) {
        timer.cancel();
        return;
      }

      final newTime = state.timeRemaining - 0.1;
      if (newTime <= 0) {
        _handleTimeout();
      } else {
        state = state.copyWith(timeRemaining: newTime);
      }
    });
  }

  void _handleTimeout() {
    _timer?.cancel();
    _processAnswer(null);
  }

  void selectArticle(String article) {
    if (state.status != GameStatus.playing) return;
    _timer?.cancel();
    _processAnswer(article);
  }

  void _processAnswer(String? selectedArticle) {
    final isCorrect =
        selectedArticle != null &&
        selectedArticle.toLowerCase() ==
            state.currentNoun?.article.toLowerCase();

    final newScore = isCorrect ? state.score + 1 : state.score;
    final newLives = isCorrect ? state.lives : state.lives - 1;
    final newCorrectAnswers =
        isCorrect ? state.correctAnswers + 1 : state.correctAnswers;

    state = state.copyWith(
      status: GameStatus.revealed,
      score: newScore,
      lives: newLives,
      correctAnswers: newCorrectAnswers,
      wasCorrect: isCorrect,
      revealedArticle: state.currentNoun?.article,
      lastSelectedArticle: selectedArticle,
    );

    if (isCorrect) {
      _ref.read(highScoreProvider.notifier).updateHighScore(newScore);
    }

    if (newLives <= 0) {
      // 3 second reveal before game over (always incorrect here)
      Future.delayed(const Duration(milliseconds: 3000), () {
        state = state.copyWith(status: GameStatus.gameOver);
      });
    } else {
      // Adaptive reveal duration: 1.5s for correct (faster flow), 3s for incorrect (feedback + animation time)
      final revealDuration = isCorrect ? 1500 : 3000;
      Future.delayed(Duration(milliseconds: revealDuration), () {
        nextNoun();
      });
    }
  }

  void nextNoun() {
    if (state.lives <= 0) return;

    List<GermanNoun> pool = List.from(state.nounPool);
    List<GermanNoun> used = List.from(state.usedNouns);

    if (state.currentNoun != null) {
      used.add(state.currentNoun!);
      pool.removeAt(0);
    }

    if (pool.isEmpty) {
      pool = List.from(used)..shuffle();
      used = [];
    }

    // Check difficulty progression
    Difficulty newDifficulty = state.difficulty;
    bool difficultyIncreased = false;
    if (state.correctAnswers >= 60) {
      newDifficulty = Difficulty.infinite;
    } else if (state.correctAnswers >= 30) {
      newDifficulty = Difficulty.hard;
    } else if (state.correctAnswers >= 10) {
      newDifficulty = Difficulty.medium;
    }

    if (newDifficulty != state.difficulty) {
      difficultyIncreased = true;
    }

    state = state.copyWith(
      status: GameStatus.playing,
      currentNoun: pool.first,
      nounPool: pool,
      usedNouns: used,
      difficulty: newDifficulty,
      timeRemaining: _getMaxTime(newDifficulty),
      // We'll use a listener or a transient flag for the pulse animation
    );

    if (difficultyIncreased) {
      // Trigger a "difficulty pulse" event here if needed,
      // or the UI can watch state.difficulty changes.
    }

    _startTimer();
  }

  double _getMaxTime(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.easy:
        return 9.0;
      case Difficulty.medium:
        return 6.0;
      case Difficulty.hard:
        return 3.0;
      case Difficulty.infinite:
        return 1.0;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final gameProvider = StateNotifierProvider<GameNotifier, GameState>((ref) {
  return GameNotifier(ref);
});
