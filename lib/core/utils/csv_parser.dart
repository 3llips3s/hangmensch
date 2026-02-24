import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

/// Utility class for loading and parsing CSV files from assets.
class CsvParser {
  /// Loads a CSV file from the specified [assetPath] and returns its contents as a list of rows.
  static Future<List<List<dynamic>>> loadCsv(String assetPath) async {
    try {
      final csvString = await rootBundle.loadString(assetPath);

      /// Splits the CSV content by any newline variant (\r\n, \n, or \r).
      final lines = csvString.split(RegExp(r'\r\n|\n|\r'));
      final rows = <List<dynamic>>[];

      for (final line in lines) {
        final trimmed = line.trim();
        if (trimmed.isEmpty) continue;

        /// Adds a row to the collection by splitting the [trimmed] line by comma.
        rows.add(trimmed.split(','));
      }

      /// Logs the number of rows successfully parsed from the [assetPath].
      debugPrint('CsvParser: Found ${rows.length} rows in $assetPath');
      return rows;
    } catch (e) {
      debugPrint('CsvParser Error: $e');
      rethrow;
    }
  }
}
