import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/csv_parser.dart';
import '../models/german_noun.dart';

/// Provider that asynchronously loads German nouns from the CSV file.
///
/// Returns a [List<GermanNoun>] containing all nouns from the development
/// dataset (nouns_dev.csv). The full dataset will be used in production.
///
/// Usage:
/// ```dart
/// final nouns = ref.watch(nounsProvider);
/// nouns.when(
///   data: (list) => Text('Loaded ${list.length} nouns'),
///   loading: () => CircularProgressIndicator(),
///   error: (e, s) => Text('Error: $e'),
/// );
/// ```
final nounsProvider = FutureProvider<List<GermanNoun>>((ref) async {
  try {
    debugPrint('Attempting to load CSV: assets/data/nouns_dev.csv');
    final rows = await CsvParser.loadCsv('assets/data/nouns_dev.csv');

    debugPrint('CSV loaded successfully. Row count: ${rows.length}');

    // Skip header row, parse remaining rows into GermanNoun objects
    final nouns = <GermanNoun>[];
    for (var i = 1; i < rows.length; i++) {
      final row = rows[i];
      if (row.length >= 4) {
        nouns.add(
          GermanNoun.fromCsv([
            row[0].toString(),
            row[1].toString(),
            row[2].toString(),
            row[3].toString(),
          ]),
        );
      }
    }

    if (nouns.isEmpty) {
      debugPrint('WARNING: No nouns were parsed from CSV!');
    } else {
      debugPrint('Parsed ${nouns.length} nouns successfully.');
    }

    return nouns;
  } catch (e, stack) {
    debugPrint('ERROR loading nouns: $e');
    debugPrint('Stack trace: $stack');
    rethrow;
  }
});
