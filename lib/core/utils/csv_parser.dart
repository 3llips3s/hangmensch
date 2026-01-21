import 'package:csv/csv.dart';
import 'package:flutter/services.dart';

/// Utility class for loading and parsing CSV files from assets.
class CsvParser {
  /// Loads a CSV file from assets and returns its contents as a list of rows.
  /// 
  /// Each row is a list of dynamic values representing the columns.
  /// The first row typically contains headers.
  /// 
  /// [assetPath] - The path to the CSV file in assets (e.g., 'assets/data/nouns_dev.csv')
  static Future<List<List<dynamic>>> loadCsv(String assetPath) async {
    final csvString = await rootBundle.loadString(assetPath);
    return const CsvToListConverter().convert(csvString);
  }
}
