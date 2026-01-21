import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

/// Utility class for loading and parsing CSV files from assets.
class CsvParser {
  /// Loads a CSV file from assets and returns its contents as a list of rows.
  static Future<List<List<dynamic>>> loadCsv(String assetPath) async {
    try {
      final csvString = await rootBundle.loadString(assetPath);

      // Split by any newline variant (\r\n, \n, \r)
      final lines = csvString.split(RegExp(r'\r\n|\n|\r'));
      final rows = <List<dynamic>>[];

      for (final line in lines) {
        final trimmed = line.trim();
        if (trimmed.isEmpty) continue;

        // Split by comma
        rows.add(trimmed.split(','));
      }

      debugPrint('CsvParser: Found ${rows.length} rows in $assetPath');
      return rows;
    } catch (e) {
      debugPrint('CsvParser Error: $e');
      rethrow;
    }
  }
}
