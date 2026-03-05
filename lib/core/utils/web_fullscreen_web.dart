import 'dart:html' as html;

/// Whether the current browser environment supports the Fullscreen API.
bool get isFullscreenSupported => html.document.fullscreenEnabled ?? false;

/// Whether the browser is currently in fullscreen mode.
bool get isFullscreenActive => html.document.fullscreenElement != null;

/// Toggles the browser's fullscreen mode for the root document element.
void toggleFullscreen() {
  final element = html.document.documentElement;
  try {
    if (html.document.fullscreenElement == null) {
      element?.requestFullscreen();
    } else {
      html.document.exitFullscreen();
    }
  } catch (e) {
    // Fail silently - some browsers (like iOS Safari) may throw even if requested on an element
  }
}
