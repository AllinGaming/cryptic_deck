import 'package:flutter_test/flutter_test.dart';

import 'package:cryptic_deck/core/battle_engine.dart';
import 'package:cryptic_deck/core/card_models.dart';
import 'package:cryptic_deck/core/run_state.dart';

void main() {
  test('Bones cost card can be played with turn bones drip', () {
    final run = RunState(meta: MetaProgress());
    run.deck = [CardLibrary.byId('skeleton'), CardLibrary.byId('skeleton')];

    final battle = BattleState(run: run, difficulty: BattleDifficulty.normal);

    expect(battle.playerBones, 1, reason: 'bones drip on turn start');
    final skeleton = battle.playerHand.firstWhere(
      (c) => c.definition.costType == CardCostType.bones,
    );

    final played = battle.playCardToLane(skeleton, 0);
    expect(played, isTrue);
    expect(battle.board.playerSlots[0], isNotNull);
    expect(battle.playerBones, 0);
  });

  test('Logs capture battle events', () {
    final run = RunState(meta: MetaProgress());
    run.deck = [CardLibrary.byId('squirrel'), CardLibrary.byId('squirrel')];
    final battle = BattleState(run: run, difficulty: BattleDifficulty.normal);

    final squirrel = battle.playerHand.first;
    battle.playCardToLane(squirrel, 0);
    battle.endPlayerTurn();

    expect(battle.log, isNotEmpty);
    expect(
      battle.log.join(' '),
      contains('hits scale'),
      reason: 'Attacks should be logged',
    );
  });
}
