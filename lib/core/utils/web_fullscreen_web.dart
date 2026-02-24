import 'dart:html' as html;

/// Toggles the browser's fullscreen mode for the root document element.
void toggleFullscreen() {
  final element = html.document.documentElement;
  if (html.document.fullscreenElement == null) {
    element?.requestFullscreen();
  } else {
    html.document.exitFullscreen();
  }
}
