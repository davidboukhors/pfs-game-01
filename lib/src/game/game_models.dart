enum Direction { north, east, south, west }

extension DirectionRotation on Direction {
  Direction get clockwise => Direction.values[(index + 1) % 4];
  int get dx => this == Direction.east
      ? 1
      : this == Direction.west
      ? -1
      : 0;
  int get dy => this == Direction.south
      ? 1
      : this == Direction.north
      ? -1
      : 0;
}

class Cell {
  const Cell(this.x, this.y);
  final int x;
  final int y;
  Cell move(Direction direction) => Cell(x + direction.dx, y + direction.dy);
  @override
  bool operator ==(Object other) =>
      other is Cell && other.x == x && other.y == y;
  @override
  int get hashCode => Object.hash(x, y);
}

class PlacedPetal {
  const PlacedPetal({required this.cell, this.direction = Direction.north});
  final Cell cell;
  final Direction direction;
  PlacedPetal rotate() =>
      PlacedPetal(cell: cell, direction: direction.clockwise);
}

class LevelDefinition {
  const LevelDefinition({
    required this.id,
    required this.titleKey,
    required this.subtitleKey,
    required this.size,
    required this.source,
    required this.buds,
    this.stones = const {},
    required this.petals,
  });
  final int id;
  final String titleKey;
  final String subtitleKey;
  final int size;
  final Cell source;
  final Set<Cell> buds;
  final Set<Cell> stones;
  final int petals;
}

class GameSnapshot {
  const GameSnapshot({
    required this.level,
    required this.placed,
    required this.awake,
    required this.remainingPetals,
    required this.moves,
    required this.isWon,
    this.messageKey,
  });
  final LevelDefinition level;
  final List<PlacedPetal> placed;
  final Set<Cell> awake;
  final int remainingPetals;
  final int moves;
  final bool isWon;
  final String? messageKey;
}

List<LevelDefinition> buildLevels() => [
  LevelDefinition(
    id: 1,
    titleKey: 'level1Title',
    subtitleKey: 'level1Subtitle',
    size: 5,
    source: Cell(2, 2),
    buds: {Cell(4, 0)},
    petals: 3,
  ),
  LevelDefinition(
    id: 2,
    titleKey: 'level2Title',
    subtitleKey: 'level2Subtitle',
    size: 5,
    source: Cell(3, 2),
    buds: {Cell(0, 2), Cell(3, 4)},
    stones: {Cell(1, 4)},
    petals: 4,
  ),
  LevelDefinition(
    id: 3,
    titleKey: 'level3Title',
    subtitleKey: 'level3Subtitle',
    size: 5,
    source: Cell(4, 0),
    buds: {Cell(1, 0), Cell(4, 3)},
    stones: {Cell(2, 2), Cell(1, 3)},
    petals: 5,
  ),
  LevelDefinition(
    id: 4,
    titleKey: 'level4Title',
    subtitleKey: 'level4Subtitle',
    size: 6,
    source: Cell(5, 1),
    buds: {Cell(1, 1), Cell(3, 1), Cell(5, 5)},
    stones: {Cell(2, 4), Cell(4, 3)},
    petals: 10,
  ),
  LevelDefinition(
    id: 5,
    titleKey: 'level5Title',
    subtitleKey: 'level5Subtitle',
    size: 6,
    source: Cell(5, 0),
    buds: {Cell(0, 0), Cell(3, 0), Cell(5, 5)},
    stones: {Cell(1, 2), Cell(2, 2), Cell(4, 2), Cell(4, 3)},
    petals: 10,
  ),
  LevelDefinition(
    id: 6,
    titleKey: 'level6Title',
    subtitleKey: 'level6Subtitle',
    size: 6,
    source: Cell(3, 3),
    buds: {Cell(0, 0), Cell(0, 5), Cell(5, 0), Cell(5, 5)},
    stones: {Cell(1, 1), Cell(1, 4), Cell(4, 1), Cell(4, 4)},
    petals: 8,
  ),
];
