import 'german_noun.dart';

enum GameStatus {
  idle, // Showing "Tap → Los!"
  countdown, // 3-2-1 countdown after restart
  playing, // Timer running, waiting for answer
  revealed, // Article revealed, showing feedback (1s pause)
  gameOver, // All lives lost, showing dialog
}

enum Difficulty {
  easy, // 9s per noun
  medium, // 6s per noun
  hard, // 3s per noun
  infinite, // 1s per noun
}

enum HangmenschPart {
  head, // Mistake 1
  leftArm, // Mistake 2
  rightArm, // Mistake 3
  leftLeg, // Mistake 4
  skirt, // Mistake 5
  rightLeg, // Mistake 6
  eyes, // Mistake 7 (X X - dead)
}

class GameState {
  final GameStatus status;
  final int score;
  final int lives; // 7 to 0
  final Difficulty difficulty;
  final int correctAnswers; // Tracks progression through difficulties
  final double timeRemaining; // Current timer value
  final GermanNoun? currentNoun;
  final String? revealedArticle; // Shown after answer
  final bool wasCorrect; // For coloring revealed article
  final String? lastSelectedArticle; // To highlight the user's choice
  final List<GermanNoun> nounPool; // Remaining words
  final List<GermanNoun> usedNouns; // Already shown words

  const GameState({
    this.status = GameStatus.idle,
    this.score = 0,
    this.lives = 7,
    this.difficulty = Difficulty.easy,
    this.correctAnswers = 0,
    this.timeRemaining = 9.0,
    this.currentNoun,
    this.revealedArticle,
    this.wasCorrect = false,
    this.lastSelectedArticle,
    this.nounPool = const [],
    this.usedNouns = const [],
  });

  // Computed properties
  double get maxTime {
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

  int get mistakeCount => 7 - lives; // For hangmensch drawing (0-7)

  GameState copyWith({
    GameStatus? status,
    int? score,
    int? lives,
    Difficulty? difficulty,
    int? correctAnswers,
    double? timeRemaining,
    GermanNoun? currentNoun,
    String? revealedArticle,
    bool? wasCorrect,
    String? lastSelectedArticle,
    List<GermanNoun>? nounPool,
    List<GermanNoun>? usedNouns,
  }) {
    return GameState(
      status: status ?? this.status,
      score: score ?? this.score,
      lives: lives ?? this.lives,
      difficulty: difficulty ?? this.difficulty,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      timeRemaining: timeRemaining ?? this.timeRemaining,
      currentNoun: currentNoun ?? this.currentNoun,
      revealedArticle: revealedArticle ?? this.revealedArticle,
      wasCorrect: wasCorrect ?? this.wasCorrect,
      lastSelectedArticle: lastSelectedArticle ?? this.lastSelectedArticle,
      nounPool: nounPool ?? this.nounPool,
      usedNouns: usedNouns ?? this.usedNouns,
    );
  }
}
