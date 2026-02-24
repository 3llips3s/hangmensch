import 'package:flutter/material.dart';

/// Defines the global UI elements such as icons, emojis, and game prompts.
class UIElements {
  /// Defines icons used for game statistics and status.
  static const IconData highScoreIcon = Icons.emoji_events_rounded;
  static const IconData currentScoreIcon = Icons.speed_rounded;
  static const IconData livesIcon = Icons.favorite_rounded;

  /// Defines emoji symbols used for decorative elements or labels.
  static const String highScoreLabel = '🏆';
  static const String currentScoreLabel = '📊';
  static const String livesLabel = '❤️';

  /// Represents the eyes of the hangman when the game is lost.
  static const String hangmanEyesX = 'X X';

  /// Contains text strings for game prompts and status messages.
  static const String tapToStart = 'Tap → Los!';
  static const String gameOver = 'Spiel vorbei :(';
}
