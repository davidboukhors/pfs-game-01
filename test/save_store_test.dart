import 'package:flutter_test/flutter_test.dart';
import 'package:pfs_game_01/src/persistence/save_store.dart';

void main() {
  test('save round-trips completed levels and accessibility settings', () {
    const original = PlayerSave(
      completedLevels: {1, 3, 6},
      currentLevel: 4,
      music: false,
      effects: true,
      haptics: false,
      reducedMotion: true,
      languageCode: 'fr',
    );
    final restored = PlayerSave.fromJson(original.toJson());
    expect(restored.completedLevels, original.completedLevels);
    expect(restored.currentLevel, 4);
    expect(restored.music, isFalse);
    expect(restored.haptics, isFalse);
    expect(restored.reducedMotion, isTrue);
    expect(restored.languageCode, 'fr');
  });

  test('malformed persisted value is caught by the loading boundary', () {
    expect(
      () => PlayerSave.fromJson(<String, dynamic>{'completedLevels': 'bad'}),
      throwsA(isA<TypeError>()),
    );
  });
}
