import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Initialize this in main()');
});

class HighScoreNotifier extends StateNotifier<int> {
  final SharedPreferences _prefs;
  static const _key = 'high_score';

  HighScoreNotifier(this._prefs) : super(_prefs.getInt(_key) ?? 0);

  Future<void> updateHighScore(int newScore) async {
    if (newScore > state) {
      state = newScore;
      await _prefs.setInt(_key, newScore);
    }
  }
}

final highScoreProvider = StateNotifierProvider<HighScoreNotifier, int>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return HighScoreNotifier(prefs);
});
