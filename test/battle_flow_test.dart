import 'package:flutter_test/flutter_test.dart';

import 'package:cryptic_deck/core/battle_engine.dart';
import 'package:cryptic_deck/core/card_models.dart';
import 'package:cryptic_deck/core/run_state.dart';

void main() {
  test('Blood cost play with sacrifices works', () {
    final run = RunState(meta: MetaProgress());
    run.deck = [
      CardLibrary.byId('squirrel'),
      CardLibrary.byId('squirrel'),
      CardLibrary.byId('wolf'),
    ];

    final battle = BattleState(run: run, difficulty: BattleDifficulty.normal);
    final squirrel1 = battle.playerHand.firstWhere((c) => c.definition.id == 'squirrel');
    battle.playCardToLane(squirrel1, 0);
    final squirrel2 = battle.playerHand.firstWhere((c) => c.definition.id == 'squirrel');
    battle.playCardToLane(squirrel2, 1);

    final wolf = battle.playerHand.firstWhere((c) => c.definition.id == 'wolf');
    final played = battle.playCardToLane(wolf, 2);

    expect(played, isTrue);
    expect(battle.board.playerSlots[2]?.definition.id, 'wolf');
    expect(battle.board.playerSlots[0], isNull);
    expect(battle.board.playerSlots[1], isNull);
    expect(battle.playerBones, 3, reason: 'turn drip + 2 sacrifices');
  });

  test('Flying hits scale directly', () {
    final run = RunState(meta: MetaProgress());
    run.bonesBonus = 5; // ensure we can pay raven bones cost
    run.deck = [CardLibrary.byId('raven')];
    final battle = BattleState(run: run, difficulty: BattleDifficulty.normal);
    final raven = battle.playerHand.firstWhere((c) => c.definition.id == 'raven');
    battle.playCardToLane(raven, 0);
    battle.endPlayerTurn(); // player attack then enemy turn

    expect(battle.damageScale, greaterThan(0), reason: 'flying should deal direct scale damage');
  });
}
