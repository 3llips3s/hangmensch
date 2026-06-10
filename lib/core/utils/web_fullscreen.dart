// Conditionally exports the fullscreen utility based on the platform.
export 'web_fullscreen_stub.dart'
    if (dart.library.js_interop) 'web_fullscreen_web.dart';
