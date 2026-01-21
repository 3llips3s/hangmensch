import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/game_state.dart';
import '../models/german_noun.dart';
import 'nouns_provider.dart';
import 'high_score_provider.dart';

class GameNotifier extends StateNotifier<GameState> {
  final Ref _ref;
  Timer? _timer;

  GameNotifier(this._ref) : super(const GameState());

  void startGame() {
    final nounsAsync = _ref.read(nounsProvider);
    nounsAsync.whenData((nouns) {
      final shuffledPool = List<GermanNoun>.from(nouns)..shuffle();
      state = GameState(
        status: GameStatus.playing,
        nounPool: shuffledPool,
        currentNoun: shuffledPool.first,
        timeRemaining: 6.0, // Default easy time
      );
      _startTimer();
    });
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
    );

    if (isCorrect) {
      _ref.read(highScoreProvider.notifier).updateHighScore(newScore);
    }

    if (newLives <= 0) {
      Future.delayed(const Duration(milliseconds: 1000), () {
        state = state.copyWith(status: GameStatus.gameOver);
      });
    } else {
      Future.delayed(const Duration(milliseconds: 1000), () {
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

  double _getMaxTime(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.easy:
        return 6.0;
      case Difficulty.medium:
        return 4.0;
      case Difficulty.hard:
        return 2.0;
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
