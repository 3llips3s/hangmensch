import 'package:flutter/material.dart';
import 'dart:html' as html;
import 'package:flutter/foundation.dart' show kIsWeb;

class FullscreenButton extends StatelessWidget {
  const FullscreenButton({super.key});

  void _toggleFullscreen() {
    if (!kIsWeb) return;

    final element = html.document.documentElement;
    if (html.document.fullscreenElement == null) {
      element?.requestFullscreen();
    } else {
      html.document.exitFullscreen();
    }
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
