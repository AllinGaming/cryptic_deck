import 'package:flutter_test/flutter_test.dart';

import 'package:cryptic_deck/core/battle_engine.dart';
import 'package:cryptic_deck/core/card_models.dart';
import 'package:cryptic_deck/core/run_state.dart';

CardInstance ci(String id) => CardInstance(CardLibrary.byId(id));

void main() {
  test('Poison kills regardless of hp', () {
    final run = RunState(meta: MetaProgress());
    run.deck = [CardLibrary.byId('adder')];
    final battle = BattleState(run: run, difficulty: BattleDifficulty.normal);
    battle.enemyDrawPile.clear();
    battle.enemyHand.clear();
    battle.board.playerSlots[0] = ci('adder');
    battle.board.enemySlots[0] = ci('elk');

    battle.endPlayerTurn(); // resolve player attacks

    expect(battle.board.enemySlots[0], isNull, reason: 'poison should kill elk');
  });

  test('Guard reduces damage by 1', () {
    final run = RunState(meta: MetaProgress());
    run.deck = [CardLibrary.byId('stoat')]; // atk 1
    final battle = BattleState(run: run, difficulty: BattleDifficulty.normal);
    battle.enemyDrawPile.clear();
    battle.enemyHand.clear();
    battle.board.playerSlots[0] = ci('stoat');
    battle.board.enemySlots[0] = ci('bloodbot'); // guard ability

    battle.endPlayerTurn();

    final defender = battle.board.enemySlots[0]!;
    expect(defender.currentHp, 3, reason: 'guard should mitigate damage');
  });

  test('Bifurcated hits both adjacent lanes', () {
    final run = RunState(meta: MetaProgress());
    run.deck = [CardLibrary.byId('hydra')];
    final battle = BattleState(run: run, difficulty: BattleDifficulty.normal);
    battle.enemyDrawPile.clear();
    battle.enemyHand.clear();
    battle.board.playerSlots[1] = ci('hydra'); // center
    battle.board.enemySlots[0] = ci('skeleton');
    battle.board.enemySlots[2] = ci('skeleton');

    battle.endPlayerTurn();

    expect(battle.board.enemySlots[0], isNull);
    expect(battle.board.enemySlots[2], isNull);
  });

  test('Flying hits scale when lane empty', () {
    final run = RunState(meta: MetaProgress());
    run.bonesBonus = 5;
    run.deck = [CardLibrary.byId('raven')];
    final battle = BattleState(run: run, difficulty: BattleDifficulty.normal);
    battle.enemyDrawPile.clear();
    battle.enemyHand.clear();
    battle.board.playerSlots[0] = ci('raven');
    battle.board.enemySlots[0] = null;

    battle.endPlayerTurn();

    expect(battle.damageScale, greaterThan(0));
  });

  test('Undying returns to discard on death', () {
    final run = RunState(meta: MetaProgress());
    run.deck = [CardLibrary.byId('phoenix')];
    final battle = BattleState(run: run, difficulty: BattleDifficulty.normal);
    battle.enemyDrawPile.clear();
    battle.enemyHand.clear();
    // enemy will kill phoenix
    battle.board.playerSlots[0] = ci('phoenix');
    final enemyHydra = ci('hydra');
    enemyHydra.currentAtk = 3;
    battle.board.enemySlots[0] = enemyHydra;

    battle.endPlayerTurn(); // enemy attacks after player phase

    final resurrected = battle.playerDiscard.where((c) => c.definition.id == 'phoenix');
    expect(resurrected.length, greaterThan(0));
  });
}
