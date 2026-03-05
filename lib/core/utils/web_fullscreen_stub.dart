/// Provides a stub implementation of [toggleFullscreen] for non-web platforms.
bool get isFullscreenSupported => false;
bool get isFullscreenActive => false;
void toggleFullscreen() {}
