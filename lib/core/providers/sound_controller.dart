import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Manages sound effect playback and mute state for the application.
class SoundController extends Notifier<bool> {
  /// The audio player used for sound effects.
  late AudioPlayer _sfxPlayer;

  /// Defines relative asset paths for audio files.
  static const String correctSound = 'audio/bubble.mp3';
  static const String wrongSound = 'audio/rope.mp3';
  static const String gameOverSound = 'audio/trapdoor.mp3';

  @override
  bool build() {
    _sfxPlayer = AudioPlayer();

    /// Sets the release mode to stop to optimize resource utilization.
    _sfxPlayer.setReleaseMode(ReleaseMode.stop);

    _preloadSounds();

    /// Disposes the [_sfxPlayer] when the provider is destroyed.
    ref.onDispose(() {
      _sfxPlayer.dispose();
    });

    return false;
  }

  /// Preloads audio assets into the cache to ensure low latency during playback.
  Future<void> _preloadSounds() async {
    try {
      await _sfxPlayer.audioCache.loadAll([
        correctSound,
        wrongSound,
        gameOverSound,
      ]);
    } catch (e) {
      debugPrint('Error preloading sounds: $e');
    }
  }

  /// Toggles the mute state and adjusts volume accordingly.
  Future<void> toggleMute() async {
    state = !state;
    if (state) {
      await _sfxPlayer.setVolume(0);
    } else {
      await _sfxPlayer.setVolume(1.0);
    }
  }

  /// Plays the [correctSound] effect if not muted.
  Future<void> playCorrect() async {
    if (state) return;
    try {
      if (_sfxPlayer.state == PlayerState.playing) {
        await _sfxPlayer.stop();
      }
      await _sfxPlayer.play(AssetSource(correctSound));
    } catch (e) {
      // Errors are handled silently for playback stability
    }
  }

  /// Plays the [wrongSound] effect if not muted.
  Future<void> playWrong() async {
    if (state) return;
    try {
      if (_sfxPlayer.state == PlayerState.playing) {
        await _sfxPlayer.stop();
      }
      await _sfxPlayer.play(AssetSource(wrongSound));
    } catch (e) {
      // Errors are handled silently for playback stability
    }
  }

  /// Plays the [gameOverSound] effect if not muted.
  Future<void> playGameOver() async {
    if (state) return;
    try {
      if (_sfxPlayer.state == PlayerState.playing) {
        await _sfxPlayer.stop();
      }
      await _sfxPlayer.play(AssetSource(gameOverSound));
    } catch (e) {
      // Errors are handled silently for playback stability
    }
  }
}

/// Provider that exposes the [SoundController].
final soundControllerProvider = NotifierProvider<SoundController, bool>(
  () => SoundController(),
);
