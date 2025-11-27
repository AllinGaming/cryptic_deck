import 'package:flutter_test/flutter_test.dart';

import 'package:cryptic_deck/core/map_node.dart';

void main() {
  test('Map generation has boss and pre-boss elite', () {
    final map = MapState.generate(depth: 5);
    expect(map.rows.last.single.type, MapNodeType.boss);
    expect(map.rows[map.rows.length - 2][1].type, MapNodeType.elite);
  });

  test('Map rows advance correctly', () {
    final map = MapState.generate(depth: 4);
    expect(map.currentRow, 0);
    map.advanceRow();
    expect(map.currentRow, 1);
    map.advanceRow();
    map.advanceRow();
    map.advanceRow();
    expect(map.finished, isTrue);
  });
}
