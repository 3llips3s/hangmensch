import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/game_state.dart';
import '../models/german_noun.dart';
import 'nouns_provider.dart';
import 'high_score_provider.dart';

/// Notifier that manages the core game logic, including score, lives, and timer states.
class GameNotifier extends StateNotifier<GameState> {
  final Ref _ref;
  Timer? _timer;

  GameNotifier(this._ref) : super(const GameState());

  /// Starts the initial game session.
  void startGame() async {
    _startInitialGame();
  }

  /// Restarts the game by initiating a countdown and resetting core metrics.
  void restartGame() async {
    state = state.copyWith(
      status: GameStatus.countdown,
      lives: 7,
      score: 0,
      timeRemaining: 9.0,
    );
  }

  /// Handles the transition after the UI countdown is complete.
  void onCountdownComplete() {
    _startInitialGame();
  }

  /// Initializes the game state with a fresh pool of nouns and starts the timer.
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
        timeRemaining: 9.0,
      );

      _startTimer();
    } catch (e) {
      debugPrint('GameNotifier: Failed to start game: $e');
    }
  }

  /// Starts or resumes the periodic timer for the current round.
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

  /// Handles the expiration of the timer for the current noun.
  void _handleTimeout() {
    _timer?.cancel();
    _processAnswer(null);
  }

  /// Registers the [article] selected by the user and progresses the game.
  void selectArticle(String article) {
    if (state.status != GameStatus.playing) return;
    _timer?.cancel();
    _processAnswer(article);
  }

  /// Processes the [selectedArticle], updates score/lives, and schedules the next round.
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
      /// Shows feedback for 3 seconds before transitioning to game over.
      Future.delayed(const Duration(milliseconds: 3000), () {
        state = state.copyWith(status: GameStatus.gameOver);
      });
    } else {
      /// Uses adaptive reveal duration: 1.5s for correct, 3s for incorrect feedback.
      final revealDuration = isCorrect ? 1500 : 3000;
      Future.delayed(Duration(milliseconds: revealDuration), () {
        nextNoun();
      });
    }
  }

  /// Progresses the game to the [nextNoun], updating the pool and difficulty as needed.
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

    /// Evaluates difficulty progression based on [correctAnswers].
    Difficulty newDifficulty = state.difficulty;
    if (state.correctAnswers >= 60) {
      newDifficulty = Difficulty.infinite;
    } else if (state.correctAnswers >= 30) {
      newDifficulty = Difficulty.hard;
    } else if (state.correctAnswers >= 10) {
      newDifficulty = Difficulty.medium;
    }

    state = state.copyWith(
      status: GameStatus.playing,
      currentNoun: pool.first,
      nounPool: pool,
      usedNouns: used,
      difficulty: newDifficulty,
      timeRemaining: _getMaxTime(newDifficulty),
    );

    _startTimer();
  }

  /// Returns the maximum duration allowed for the given [difficulty].
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
