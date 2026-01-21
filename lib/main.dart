import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'features/game/providers/nouns_provider.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'features/game/providers/high_score_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
      title: 'Hangmensch',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(scaffoldBackgroundColor: Colors.black),
      home: const NounsTestScreen(),
    );
  }
}

/// Temporary test screen to verify CSV loading works correctly.
/// This will be replaced with the actual GameScreen in Phase 3.
class NounsTestScreen extends ConsumerWidget {
  const NounsTestScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nounsAsync = ref.watch(nounsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hangmensch - CSV Test'),
        backgroundColor: Colors.black,
      ),
      body: Center(
        child: nounsAsync.when(
          data: (nouns) {
            // Print first 10 nouns to console for verification
            debugPrint('✅ Loaded ${nouns.length} nouns successfully!');
            for (var i = 0; i < 10 && i < nouns.length; i++) {
              debugPrint('  ${i + 1}. ${nouns[i]}');
            }

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.check_circle,
                  color: Color(0xFFFFCE00), // German gold
                  size: 80,
                ),
                const SizedBox(height: 24),
                Text(
                  'Loaded ${nouns.length} nouns',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Sample: ${nouns.first}',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF888888),
                  ),
                ),
              ],
            );
          },
          loading:
              () => const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Color(0xFFFFCE00)),
                  SizedBox(height: 16),
                  Text(
                    'Loading nouns...',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
          error:
              (error, stack) => Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error,
                    color: Color(0xFFDD0000), // German red
                    size: 80,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Error loading nouns',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '$error',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFFDD0000),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
        ),
      ),
    );
  }
}
