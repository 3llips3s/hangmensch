import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/theme/app_theme.dart';
import 'features/game/providers/high_score_provider.dart';
import 'features/game/views/game_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Enable Immersive sticky mode as requested by user
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: const HangmenschApp(),
    ),
  );
}

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
