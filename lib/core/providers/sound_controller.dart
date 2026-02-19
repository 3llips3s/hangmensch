import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SoundController extends Notifier<bool> {
  // Use separate players for different sound types to allow overlap if needed,
  // or use a single one to prevent cacophony.
  // Given "tied to specific function", let's use a single player for game events
  // to ensure they are distinct and don't overlap messily, OR distinct players
  // if we want correct guess (bubble) to not be cut off by something else immediately?
  // User asked to avoid "race conditions".
  // A single player ensures sequential playback (new sound cuts old).
  // This is usually desired for UI/gameplay feedback unless it's background + SFX.
  late AudioPlayer _sfxPlayer;

  // Asset Paths
  static const String correctSound = 'audio/bubble.mp3';
  static const String wrongSound = 'audio/rope.mp3';
  static const String gameOverSound = 'audio/trapdoor.mp3';

  @override
  bool build() {
    _sfxPlayer = AudioPlayer();

    // Set release mode to stop to save resources
    _sfxPlayer.setReleaseMode(ReleaseMode.stop);

    // Preload sounds to avoid latency on first play
    _preloadSounds();

    // Dispose player when provider is destroyed
    ref.onDispose(() {
      _sfxPlayer.dispose();
    });

    // Default: Not muted (false)
    return false;
  }

  Future<void> _preloadSounds() async {
    // Preload sounds to ensure low latency
    try {
      await _sfxPlayer.audioCache.loadAll([
        correctSound,
        wrongSound,
        gameOverSound,
      ]);
    } catch (e) {
      // Handle or log error
      debugPrint('Error preloading sounds: $e');
    }
  }

  Future<void> toggleMute() async {
    state = !state;
    if (state) {
      await _sfxPlayer.setVolume(0);
    } else {
      await _sfxPlayer.setVolume(1.0);
    }
  }

  Future<void> playCorrect() async {
    if (state) return;
    try {
      if (_sfxPlayer.state == PlayerState.playing) {
        await _sfxPlayer.stop();
      }
      await _sfxPlayer.play(AssetSource(correctSound));
    } catch (e) {
      // Handle potential errors silently or log
    }
  }

  Future<void> playWrong() async {
    if (state) return;
    try {
      if (_sfxPlayer.state == PlayerState.playing) {
        await _sfxPlayer.stop();
      }
      await _sfxPlayer.play(AssetSource(wrongSound));
    } catch (e) {
      // Handle errors
    }
  }

  Future<void> playGameOver() async {
    if (state) return;
    try {
      if (_sfxPlayer.state == PlayerState.playing) {
        await _sfxPlayer.stop();
      }
      await _sfxPlayer.play(AssetSource(gameOverSound));
    } catch (e) {
      // Handle errors
    }
  }
}

final soundControllerProvider = NotifierProvider<SoundController, bool>(
  () => SoundController(),
);
