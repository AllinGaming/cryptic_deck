import 'package:cryptic_deck/core/battle_engine.dart';
import 'package:cryptic_deck/core/run_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Resolving flag toggles during end turn', () {
    final run = RunState(meta: MetaProgress());
    final battle = BattleState(run: run, difficulty: BattleDifficulty.normal);
    expect(battle.resolving, isFalse);
    battle.endPlayerTurn();
    expect(battle.resolving, isFalse, reason: 'reset after resolution');
  });
}
