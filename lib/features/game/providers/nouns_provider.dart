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
  final rows = await CsvParser.loadCsv('assets/data/nouns_dev.csv');

  debugPrint('CSV loaded with ${rows.length} rows');
  if (rows.isNotEmpty) {
    debugPrint('First row: ${rows[0]}');
    if (rows.length > 1) {
      debugPrint('Second row: ${rows[1]}');
    }
  }

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

  return nouns;
});
