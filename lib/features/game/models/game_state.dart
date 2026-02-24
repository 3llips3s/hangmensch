import 'german_noun.dart';

/// Defines the possible states of the game flow.
enum GameStatus {
  /// Indicates the game is idle, awaiting user interaction.
  idle,

  /// Indicates a countdown is in progress before a new round.
  countdown,

  /// Indicates the game is active and the timer is running.
  playing,

  /// Indicates the correct article has been revealed for feedback.
  revealed,

  /// Indicates the game has ended after all lives are lost.
  gameOver,
}

/// Defines the difficulty levels available in the game.
enum Difficulty {
  /// Easy difficulty with 9 seconds per noun.
  easy,

  /// Medium difficulty with 6 seconds per noun.
  medium,

  /// Hard difficulty with 3 seconds per noun.
  hard,

  /// Infinite difficulty with 1 second per noun.
  infinite,
}

/// Defines the body parts of the hangmensch character corresponding to mistakes.
enum HangmenschPart {
  /// Represents the head, corresponding to the first mistake.
  head,

  /// Represents the left arm, corresponding to the second mistake.
  leftArm,

  /// Represents the right arm, corresponding to the third mistake.
  rightArm,

  /// Represents the left leg, corresponding to the fourth mistake.
  leftLeg,

  /// Represents the skirt, corresponding to the fifth mistake.
  skirt,

  /// Represents the right leg, corresponding to the sixth mistake.
  rightLeg,

  /// Represents the dead eyes, corresponding to the seventh and final mistake.
  eyes,
}

/// Represents the immutable state of the game at any given point.
class GameState {
  /// The current status of the game flow.
  final GameStatus status;

  /// The player's current total score.
  final int score;

  /// The number of lives remaining (from 7 down to 0).
  final int lives;

  /// The current game difficulty level.
  final Difficulty difficulty;

  /// The number of consecutive correct answers in the current level.
  final int correctAnswers;

  /// The time remaining in seconds for the current noun.
  final double timeRemaining;

  /// The current German noun being displayed.
  final GermanNoun? currentNoun;

  /// The article that was revealed after the user's choice.
  final String? revealedArticle;

  /// Whether the last user selection was correct.
  final bool wasCorrect;

  /// The last article selected by the user.
  final String? lastSelectedArticle;

  /// The pool of remaining nouns to be shown.
  final List<GermanNoun> nounPool;

  /// The collection of nouns already shown in the current session.
  final List<GermanNoun> usedNouns;

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

  /// Returns the maximum allowed time based on the current [difficulty].
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

  /// Calculates the number of mistakes made based on [lives] remaining.
  int get mistakeCount => 7 - lives;

  /// Returns a copy of the state with the specified fields replaced.
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
