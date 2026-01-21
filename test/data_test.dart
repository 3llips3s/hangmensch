import 'package:flutter_test/flutter_test.dart';
import 'package:hangmensch/features/game/models/german_noun.dart';

void main() {
  group('GermanNoun Model Tests', () {
    test('fromCsv creates a valid model from a list of strings', () {
      final row = ['die', 'Kapelle', 'Kapellen', 'Chapel'];
      final noun = GermanNoun.fromCsv(row);

      expect(noun.article, 'die');
      expect(noun.noun, 'Kapelle');
      expect(noun.plural, 'Kapellen');
      expect(noun.translation, 'Chapel');
    });

    test('fromCsv trims whitespace from values', () {
      final row = [' die ', ' Kapelle ', ' Kapellen ', ' Chapel '];
      final noun = GermanNoun.fromCsv(row);

      expect(noun.article, 'die');
      expect(noun.noun, 'Kapelle');
      expect(noun.plural, 'Kapellen');
      expect(noun.translation, 'Chapel');
    });

    test('toString returns formatted article and noun', () {
      final noun = GermanNoun(
        article: 'das',
        noun: 'Haus',
        plural: 'Häuser',
        translation: 'house',
      );

      expect(noun.toString(), 'das Haus (house)');
    });
  });

  group('CSV Parsing Logic Verification', () {
    // since CsvParser uses rootBundle (assets) we test mapping logic in nounsProvider
    test('Mapping logic correctly transforms CSV rows', () {
      final rows = [
        ['article', 'noun', 'plural', 'english'], // header
        ['die', 'Kapelle', 'Kapellen', 'Chapel'],
        ['der', 'Speer', 'Speere', 'Spear'],
      ];

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

      expect(nouns.length, 2);
      expect(nouns[0].noun, 'Kapelle');
      expect(nouns[1].noun, 'Speer');
    });
  });
}
