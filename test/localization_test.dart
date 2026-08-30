import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart';
import 'package:pfs_game_01/src/localization/app_localizations.dart';

void main() {
  test('the main player-facing keys exist in French and English', () {
    const keys = [
      'play',
      'levels',
      'settings',
      'credits',
      'placeHint',
      'victoryTitle',
      'music',
      'effects',
      'haptics',
      'reducedMotion',
    ];
    for (final language in ['fr', 'en']) {
      final copy = AppLocalizations(Locale(language));
      for (final key in keys) {
        expect(copy.t(key), isNot(key));
      }
    }
  });
}
