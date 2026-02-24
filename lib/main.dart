import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/theme/app_theme.dart';
import 'features/game/providers/high_score_provider.dart';
import 'features/game/views/game_screen.dart';

/// Main entry point for the Hangmensch application.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  /// Enables immersive sticky mode for a better full-screen mobile experience.
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: const HangmenschApp(),
    ),
  );
}

/// The root widget of the application, configuring the global theme and home screen.
class HangmenschApp extends StatelessWidget {
  const HangmenschApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const GameScreen(),
    );
  }
}
