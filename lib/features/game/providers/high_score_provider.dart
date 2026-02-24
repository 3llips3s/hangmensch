import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provides access to the [SharedPreferences] instance.
///
/// This provider must be overridden in `main()` with an initialized instance.
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Initialize this in main()');
});

/// Notifier that manages the player's high score persistent state.
class HighScoreNotifier extends StateNotifier<int> {
  final SharedPreferences _prefs;
  static const _key = 'high_score';

  HighScoreNotifier(this._prefs) : super(_prefs.getInt(_key) ?? 0);

  /// Updates the high score if the [newScore] is greater than the current state.
  Future<void> updateHighScore(int newScore) async {
    if (newScore > state) {
      state = newScore;
      await _prefs.setInt(_key, newScore);
    }
  }
}

/// Provider that exposes the [HighScoreNotifier].
final highScoreProvider = StateNotifierProvider<HighScoreNotifier, int>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return HighScoreNotifier(prefs);
});
