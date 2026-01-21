/// Data model representing a German noun with its article.
/// 
/// Used throughout the game to display nouns and check if the user
/// selected the correct article (der/die/das).
class GermanNoun {
  /// The definite article: "der", "die", or "das"
  final String article;
  
  /// The German noun (e.g., "Tisch")
  final String noun;
  
  /// The plural form (e.g., "Tische") or "kein Pl." if no plural exists
  final String plural;
  
  /// The English translation (e.g., "table")
  final String translation;

  GermanNoun({
    required this.article,
    required this.noun,
    required this.plural,
    required this.translation,
  });

  /// Factory constructor to create a GermanNoun from a CSV row.
  /// 
  /// Expected row format: [article, noun, plural, translation]
  factory GermanNoun.fromCsv(List<String> row) {
    return GermanNoun(
      article: row[0].trim(),
      noun: row[1].trim(),
      plural: row[2].trim(),
      translation: row[3].trim(),
    );
  }

  @override
  String toString() {
    return '$article $noun ($translation)';
  }
}
