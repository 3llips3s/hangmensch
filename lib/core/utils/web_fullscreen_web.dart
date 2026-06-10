import 'package:web/web.dart' as web;

/// Whether the current browser environment supports the Fullscreen API.
bool get isFullscreenSupported => web.document.fullscreenEnabled;

/// Whether the browser is currently in fullscreen mode.
bool get isFullscreenActive => web.document.fullscreenElement != null;

/// Toggles the browser's fullscreen mode for the root document element.
void toggleFullscreen() {
  final element = web.document.documentElement;
  try {
    if (web.document.fullscreenElement == null) {
      element?.requestFullscreen();
    } else {
      web.document.exitFullscreen();
    }
  } catch (e) {
    // Fail silently - some browsers (like iOS Safari) may throw even if requested on an element
  }
}
