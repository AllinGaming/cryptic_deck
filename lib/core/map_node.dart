import 'dart:math';

enum MapNodeType { battle, elite, campfire, sacrifice, trader, totem, boss }

class MapNode {
  MapNode({
    required this.id,
    required this.type,
    required this.row,
    required this.label,
  });

  final String id;
  final MapNodeType type;
  final int row;
  final String label;
}

class MapState {
  MapState({required this.rows, this.currentRow = 0});

  final List<List<MapNode>> rows;
  int currentRow;

  MapNode get currentBossNode => rows.last.firstWhere((n) => n.type == MapNodeType.boss);

  List<MapNode> get currentChoices => rows[currentRow];

  bool get onBoss => currentRow == rows.length - 1;

  bool get finished => currentRow >= rows.length;

  void advanceRow() {
    currentRow = (currentRow + 1).clamp(0, rows.length);
  }

  static MapState generate({int depth = 5, Random? seed}) {
    final rng = seed ?? Random();
    final generated = <List<MapNode>>[];
    for (int row = 0; row < depth; row++) {
      if (row == depth - 1) {
        generated.add([
          MapNode(
            id: 'boss-$row',
            type: MapNodeType.boss,
            row: row,
            label: 'Boss',
          )
        ]);
        continue;
      }
      generated.add(List.generate(3, (index) {
        final type = _rollNodeType(rng);
        return MapNode(
          id: 'node-$row-$index',
          type: type,
          row: row,
          label: _labelForType(type),
        );
      }));
    }
    // Ensure last row before boss has an elite to ramp challenge.
    final preBossRow = generated[depth - 2];
    preBossRow[1] = MapNode(
      id: 'elite-${depth - 2}-1',
      type: MapNodeType.elite,
      row: depth - 2,
      label: 'Elite',
    );

    return MapState(rows: generated);
  }

  static MapNodeType _rollNodeType(Random rng) {
    final roll = rng.nextDouble();
    if (roll < 0.35) return MapNodeType.battle;
    if (roll < 0.55) return MapNodeType.campfire;
    if (roll < 0.7) return MapNodeType.trader;
    if (roll < 0.85) return MapNodeType.sacrifice;
    return MapNodeType.totem;
  }

  static String _labelForType(MapNodeType type) {
    switch (type) {
      case MapNodeType.battle:
        return 'Battle';
      case MapNodeType.elite:
        return 'Elite';
      case MapNodeType.campfire:
        return 'Campfire';
      case MapNodeType.sacrifice:
        return 'Sacrifice';
      case MapNodeType.trader:
        return 'Trader';
      case MapNodeType.totem:
        return 'Totem';
      case MapNodeType.boss:
        return 'Boss';
    }
  }
}
