import 'game_models.dart';

class GameEngine {
  GameEngine(this.level);
  final LevelDefinition level;
  final List<PlacedPetal> _placed = [];
  String? _messageKey;

  GameSnapshot get snapshot {
    final awake = _computeAwake();
    return GameSnapshot(
      level: level,
      placed: List.unmodifiable(_placed),
      awake: awake,
      remainingPetals: level.petals - _placed.length,
      moves: _placed.length,
      isWon: awake.containsAll(level.buds),
      messageKey: _messageKey,
    );
  }

  void clearMessage() => _messageKey = null;

  bool tap(Cell cell) {
    _messageKey = null;
    final index = _placed.indexWhere((petal) => petal.cell == cell);
    if (index >= 0) {
      _placed[index] = _placed[index].rotate();
      return true;
    }
    if (level.stones.contains(cell) ||
        cell == level.source ||
        level.buds.contains(cell)) {
      _messageKey = 'invalid';
      return false;
    }
    if (_placed.length >= level.petals) {
      _messageKey = 'noMoves';
      return false;
    }
    _placed.add(PlacedPetal(cell: cell));
    return true;
  }

  Set<Cell> _computeAwake() {
    final byCell = {for (final petal in _placed) petal.cell: petal};
    final reached = <Cell>{level.source};
    final queue = <Cell>[level.source];
    while (queue.isNotEmpty) {
      final current = queue.removeAt(0);
      final candidates = current == level.source
          ? Direction.values.map(current.move)
          : (byCell[current] == null
                ? const <Cell>[]
                : [current.move(byCell[current]!.direction)]);
      for (final next in candidates) {
        if (next.x < 0 ||
            next.y < 0 ||
            next.x >= level.size ||
            next.y >= level.size) {
          continue;
        }
        if (level.stones.contains(next) || reached.contains(next)) {
          continue;
        }
        reached.add(next);
        if (byCell.containsKey(next) || level.buds.contains(next)) {
          queue.add(next);
        }
      }
    }
    return reached.intersection(level.buds);
  }
}
