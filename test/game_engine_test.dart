import 'package:flutter_test/flutter_test.dart';
import 'package:pfs_game_01/src/game/game_engine.dart';
import 'package:pfs_game_01/src/game/game_models.dart';

void main() {
  test('a placed petal rotates clockwise and is initially inactive', () {
    final engine = GameEngine(buildLevels().first);
    expect(engine.tap(const Cell(3, 2)), isTrue);
    expect(engine.snapshot.placed.single.direction, Direction.north);
    expect(engine.snapshot.isWon, isFalse);
    expect(engine.tap(const Cell(3, 2)), isTrue);
    expect(engine.snapshot.placed.single.direction, Direction.east);
  });

  test('level one can wake its bud with three readable placements', () {
    final engine = GameEngine(buildLevels().first);
    engine.tap(const Cell(3, 2));
    engine.tap(const Cell(3, 2));
    engine.tap(const Cell(4, 2));
    engine.tap(const Cell(4, 1));
    expect(engine.snapshot.isWon, isTrue);
    expect(engine.snapshot.awake, contains(const Cell(4, 0)));
  });

  test('stones, buds and source reject placement without spending a petal', () {
    final level = buildLevels()[2];
    final engine = GameEngine(level);
    expect(engine.tap(level.source), isFalse);
    expect(engine.tap(level.stones.first), isFalse);
    expect(engine.tap(level.buds.first), isFalse);
    expect(engine.snapshot.moves, 0);
    expect(engine.snapshot.messageKey, 'invalid');
  });

  test('petal inventory caps placements', () {
    final engine = GameEngine(buildLevels().first);
    for (var i = 0; i < 3; i++) {
      engine.tap(Cell(i, 0));
    }
    expect(engine.tap(const Cell(4, 4)), isFalse);
    expect(engine.snapshot.messageKey, 'noMoves');
  });
}
