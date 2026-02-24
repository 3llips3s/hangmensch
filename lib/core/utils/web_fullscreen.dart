/// Conditionally exports the fullscreen utility based on the platform.
export 'web_fullscreen_stub.dart'
    if (dart.library.html) 'web_fullscreen_web.dart';
