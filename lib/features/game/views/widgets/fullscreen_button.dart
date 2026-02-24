import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:hangmensch/core/utils/web_fullscreen.dart' as web_utils;

/// A button that toggles the application's fullscreen mode, primarily for web.
class FullscreenButton extends StatelessWidget {
  const FullscreenButton({super.key});

  /// Delegates the fullscreen toggle to the platform-specific utility.
  void _toggleFullscreen() {
    if (!kIsWeb) return;
    web_utils.toggleFullscreen();
  }

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) return const SizedBox.shrink();

    return IconButton(
      icon: const Icon(Icons.fullscreen),
      color: Colors.white54,
      onPressed: _toggleFullscreen,
      tooltip: 'Toggle Fullscreen',
    );
  }
}
