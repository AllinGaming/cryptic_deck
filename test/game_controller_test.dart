import 'package:flutter_test/flutter_test.dart';

import 'package:cryptic_deck/core/game_controller.dart';
import 'package:cryptic_deck/core/battle_engine.dart';

void main() {
  test('Start new run sets map view', () {
    final controller = GameController();
    controller.startNewRun();
    expect(controller.view, GameView.map);
    expect(controller.run, isNotNull);
  });

  test('Select campfire advances map and buffs deck', () {
    final controller = GameController();
    controller.startNewRun();
    final node = controller.run!.map.currentChoices.first;
    controller.selectNode(node);
    expect(controller.eventLog, isNotEmpty);
  });

  test('Abandon run returns to menu', () {
    final controller = GameController();
    controller.startNewRun();
    controller.abandonRun();
    expect(controller.view, GameView.menu);
    expect(controller.run, isNull);
  });

  test('Finishing battle returns to map', () {
    final controller = GameController()..startNewRun();
    controller.battle = BattleState(run: controller.run!, difficulty: BattleDifficulty.normal);
    controller.battle!.damageScale = 5;
    controller.battle!.battleOver = true;
    controller.battle!.playerWon = true;

    controller.onBattleFinished();

    expect(controller.battle, isNull);
    expect(controller.view, anyOf(GameView.map, GameView.menu));
  });
}
