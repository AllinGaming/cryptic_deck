import 'dart:math';

import 'package:flutter/foundation.dart';

import 'battle_engine.dart';
import 'map_node.dart';
import 'run_state.dart';

enum GameView { menu, map, battle }

class GameController extends ChangeNotifier {
  GameController();

  GameView view = GameView.menu;
  MetaProgress meta = MetaProgress();
  RunState? run;
  BattleState? battle;
  String eventLog = 'Welcome back to the cabin.';

  void startNewRun() {
    run = RunState(meta: meta);
    eventLog = 'A fresh run begins. Choose your path.';
    view = GameView.map;
    notifyListeners();
  }

  void selectNode(MapNode node) {
    if (run == null) return;
    switch (node.type) {
      case MapNodeType.battle:
        _startBattle(difficulty: BattleDifficulty.normal);
        break;
      case MapNodeType.elite:
        _startBattle(difficulty: BattleDifficulty.elite);
        break;
      case MapNodeType.boss:
        _startBattle(difficulty: BattleDifficulty.boss);
        break;
      case MapNodeType.campfire:
        _campfireEvent();
        break;
      case MapNodeType.trader:
        _traderEvent();
        break;
      case MapNodeType.sacrifice:
        _sacrificeEvent();
        break;
      case MapNodeType.totem:
        _totemEvent();
        break;
    }
    if (node.type != MapNodeType.battle &&
        node.type != MapNodeType.elite &&
        node.type != MapNodeType.boss) {
      run?.map.advanceRow();
      if (run!.map.finished) {
        eventLog = 'Run complete! Victory across the map.';
        view = GameView.menu;
      }
      notifyListeners();
    }
  }

  void _startBattle({BattleDifficulty difficulty = BattleDifficulty.normal}) {
    final currentRun = run;
    if (currentRun == null) return;
    battle = BattleState(run: currentRun, difficulty: difficulty);
    view = GameView.battle;
    notifyListeners();
  }

  void onBattleFinished() {
    final currentBattle = battle;
    final currentRun = run;
    if (currentBattle == null || currentRun == null) return;
    if (currentBattle.playerWon) {
      eventLog = 'Battle won. Damage scale reached the foe.';
      currentRun.map.advanceRow();
      // Reward card
      final reward = currentRun.randomReward();
      currentRun.addCard(reward);
      eventLog = '$eventLog\nPicked up ${reward.name}.';
      if (currentBattle.difficulty == BattleDifficulty.elite) {
        currentRun.currency += 2;
      } else if (currentBattle.difficulty == BattleDifficulty.boss) {
        meta = meta.copyWith(wins: meta.wins + 1);
        eventLog = '$eventLog Boss defeated! Run complete.';
        view = GameView.menu;
        battle = null;
        notifyListeners();
        return;
      }
      view = GameView.map;
    } else {
      meta = meta.copyWith(totalRuns: meta.totalRuns + 1);
      eventLog = 'Run failed. Damage scale tipped against you.';
      view = GameView.menu;
    }
    battle = null;
    notifyListeners();
  }

  void _campfireEvent() {
    final currentRun = run;
    if (currentRun == null) return;
    final healthBuff = Random().nextBool();
    currentRun.buffRandomCard(health: healthBuff);
    eventLog = healthBuff ? 'Campfire: +2 HP to a random card.' : 'Campfire: +1 ATK to a random card.';
  }

  void _traderEvent() {
    final currentRun = run;
    if (currentRun == null) return;
    final reward = currentRun.randomReward();
    currentRun.addCard(reward);
    eventLog = 'Trader offered and you took ${reward.name}.';
  }

  void _sacrificeEvent() {
    final currentRun = run;
    if (currentRun == null) return;
    currentRun.attackBuff += 1;
    eventLog = 'Sacrifice ritual: +1 permanent attack buff for this run.';
  }

  void _totemEvent() {
    final currentRun = run;
    if (currentRun == null) return;
    currentRun.bonesBonus += 1;
    eventLog = 'Totem discovered: +1 bonus bone each battle.';
  }

  void abandonRun() {
    run = null;
    battle = null;
    view = GameView.menu;
    notifyListeners();
  }
}
