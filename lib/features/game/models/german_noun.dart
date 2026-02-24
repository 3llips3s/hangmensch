/// Represents a German noun along with its definite article, plural form, and translation.
///
/// Used throughout the game to display nouns and validate user selection of "der", "die", or "das".
class GermanNoun {
  /// The definite article: "der", "die", or "das".
  final String article;

  /// The German noun, such as "Tisch".
  final String noun;

  /// The plural form of the noun or "kein Pl." if no plural exists.
  final String plural;

  /// The English translation of the noun.
  final String translation;

  GermanNoun({
    required this.article,
    required this.noun,
    required this.plural,
    required this.translation,
  });

  /// Creates a [GermanNoun] from a CSV [row].
  ///
  /// Expected [row] format: `[article, noun, plural, translation]`
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
