import 'package:cryptic_deck/core/battle_engine.dart';
import 'package:cryptic_deck/core/card_models.dart';
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

  test('Resolving clears and notifies when win happens mid-resolution', () {
    final run = RunState(meta: MetaProgress());
    final battle = BattleState(run: run, difficulty: BattleDifficulty.normal);
    battle.damageScale = 4; // one more hit wins immediately
    battle.enemyDrawPile.clear();
    battle.enemyHand.clear();
    battle.board.playerSlots[0] = CardInstance(CardLibrary.byId('stoat'));

    var sawFinishedState = false;
    battle.addListener(() {
      if (!battle.resolving && battle.battleOver) {
        sawFinishedState = true;
      }
    });

    battle.endPlayerTurn();

    expect(battle.battleOver, isTrue);
    expect(battle.resolving, isFalse);
    expect(sawFinishedState, isTrue, reason: 'listeners should see resolving=false on win');
  });
}
