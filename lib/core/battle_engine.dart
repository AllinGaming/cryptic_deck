import 'dart:math';

import 'package:flutter/foundation.dart';

import 'board_state.dart';
import 'card_models.dart';
import 'run_state.dart';

enum BattleDifficulty { normal, elite, boss }

class BattleState extends ChangeNotifier {
  BattleState({required this.run, required this.difficulty}) {
    _setupPiles();
    _startPlayerTurn();
  }

  final RunState run;
  final BattleDifficulty difficulty;
  final BoardState board = BoardState();

  late final Random _rng = Random();
  final List<CardInstance> playerHand = [];
  final List<CardInstance> playerDrawPile = [];
  final List<CardInstance> playerDiscard = [];

  final List<CardInstance> enemyDrawPile = [];
  final List<CardInstance> enemyHand = [];

  int playerBones = 0;
  int enemyBones = 0;
  int damageScale = 0;
  int turn = 1;
  bool playerTurn = true;
  bool battleOver = false;
  bool playerWon = false;
  String status = 'Battle start. Draw or play.';
  final List<String> log = [];
  bool resolving = false;

  void _setupPiles() {
    playerBones = run.bonesBonus;
    _pushLog('Battle start. Bones bonus: +${run.bonesBonus}.');
    final playerInstances = run.deck
        .map((c) => CardInstance(c)..currentAtk = c.attack + run.attackBuff)
        .toList();
    playerInstances.shuffle(_rng);
    playerDrawPile.addAll(playerInstances);

    final enemyDefs = CardLibrary.enemySet(
      elite: difficulty == BattleDifficulty.elite,
      boss: difficulty == BattleDifficulty.boss,
    );
    final copies = difficulty == BattleDifficulty.boss
        ? 3
        : difficulty == BattleDifficulty.elite
            ? 2
            : 1;
    for (var i = 0; i < copies; i++) {
      enemyDrawPile.addAll(enemyDefs.map(CardInstance.new));
    }
    enemyDrawPile.shuffle(_rng);

    for (var i = 0; i < 2; i++) {
      _drawCard(toPlayer: true);
    }
    _drawCard(toPlayer: false);
    _pushLog('Opening draw complete.');
  }

  void _startPlayerTurn() {
    if (battleOver) return;
    playerTurn = true;
    turn += 1;
    playerBones += 1; // small drip to enable early bones plays
    status = 'Your turn. Play a card or end turn.';
    _pushLog('Turn $turn start. +1 bone (now $playerBones).');
    _drawCard(toPlayer: true);
    notifyListeners();
  }

  void _drawCard({required bool toPlayer}) {
    final pile = toPlayer ? playerDrawPile : enemyDrawPile;
    final hand = toPlayer ? playerHand : enemyHand;
    if (pile.isEmpty) {
      _pushLog('${toPlayer ? 'You' : 'Enemy'} tried to draw but deck is empty.');
      return;
    }
    hand.add(pile.removeLast());
    _pushLog('${toPlayer ? 'You' : 'Enemy'} drew a card.');
  }

  bool playCardToLane(CardInstance card, int laneIndex) {
    if (battleOver || !playerTurn) return false;
    if (board.playerSlots[laneIndex] != null) {
      status = 'Lane is occupied.';
      notifyListeners();
      return false;
    }
    if (!_payCost(card.definition)) {
      status = 'Cannot pay cost.';
      notifyListeners();
      return false;
    }
    playerHand.removeWhere((c) => c.instanceId == card.instanceId);
    board.playerSlots[laneIndex] = card;
    status = 'Played ${card.definition.name}.';
    _pushLog('Played ${card.definition.name} to lane ${laneIndex + 1}.');
    notifyListeners();
    return true;
  }

  bool _payCost(CardDefinition def) {
    switch (def.costType) {
      case CardCostType.free:
        return true;
      case CardCostType.blood:
        return _sacrificeForBlood(def.costAmount);
      case CardCostType.bones:
        if (playerBones >= def.costAmount) {
          playerBones -= def.costAmount;
          _pushLog('Paid ${def.costAmount} bones.');
          return true;
        }
        return false;
    }
  }

  bool _sacrificeForBlood(int amount) {
    final alive = board.playerSlots.whereType<CardInstance>().toList();
    if (alive.length < amount) return false;
    for (var i = 0; i < amount; i++) {
      final victim = alive[i];
      final lane = board.playerSlots.indexWhere((c) => c?.instanceId == victim.instanceId);
      if (lane != -1) {
        _killCreature(isPlayer: true, lane: lane, giveBones: true);
      }
    }
    _pushLog('Sacrificed $amount creature(s) for blood.');
    return true;
  }

  void endPlayerTurn() {
    if (battleOver) return;
    playerTurn = false;
    resolving = true;
    status = 'Resolving attacks...';
    _pushLog('You end turn. Attacks resolve.');
    _resolveCombat(fromPlayer: true);
    if (_checkVictory()) {
      resolving = false;
      return;
    }
    _enemyMainPhase();
    if (_checkVictory()) {
      resolving = false;
      return;
    }
    _resolveCombat(fromPlayer: false);
    resolving = false;
    if (_checkVictory()) return;
    _startPlayerTurn();
  }

  void _enemyMainPhase() {
    _drawCard(toPlayer: false);
    for (final card in List<CardInstance>.from(enemyHand)) {
      final lane = _findOpenEnemyLane();
      if (lane == -1) break;
      enemyHand.remove(card);
      board.enemySlots[lane] = card;
      _pushLog('Enemy played ${card.definition.name} to lane ${lane + 1}.');
      break;
    }
  }

  int _findOpenEnemyLane() {
    for (var i = 0; i < board.enemySlots.length; i++) {
      if (board.enemySlots[i] == null) return i;
    }
    return -1;
  }

  void _resolveCombat({required bool fromPlayer}) {
    final attackers = fromPlayer ? board.playerSlots : board.enemySlots;
    for (var lane = 0; lane < attackers.length; lane++) {
      final attacker = attackers[lane];
      if (attacker == null) continue;
      _attackLane(attacker: attacker, lane: lane, fromPlayer: fromPlayer);
    }
  }

  void _attackLane({
    required CardInstance attacker,
    required int lane,
    required bool fromPlayer,
  }) {
    final abilities = attacker.definition.abilities;
    final defenders = fromPlayer ? board.enemySlots : board.playerSlots;
    final isFlying = abilities.contains(CardAbility.flying);
    final targets = <int>{lane};
    if (abilities.contains(CardAbility.bifurcated)) {
      if (lane - 1 >= 0) targets.add(lane - 1);
      if (lane + 1 < defenders.length) targets.add(lane + 1);
    }
    for (final targetLane in targets) {
      final defender = defenders[targetLane];
      if (defender == null || isFlying) {
        damageScale += fromPlayer ? attacker.currentAtk : -attacker.currentAtk;
        _pushLog(
            '${fromPlayer ? 'Your' : 'Enemy'} ${attacker.definition.name} hits scale for ${attacker.currentAtk}.');
        continue;
      }
      var damage = attacker.currentAtk;
      if (defender.definition.abilities.contains(CardAbility.guard)) {
        damage = max(0, damage - 1);
      }
      defender.currentHp -= damage;
      _pushLog(
          '${fromPlayer ? 'Your' : 'Enemy'} ${attacker.definition.name} hits ${defender.definition.name} for $damage.');
      if (abilities.contains(CardAbility.poison)) {
        defender.currentHp = 0;
        _pushLog('Poison! ${defender.definition.name} dies.');
      }
      if (defender.currentHp <= 0) {
        _killCreature(isPlayer: !fromPlayer, lane: targetLane, giveBones: true);
      }
    }
    notifyListeners();
  }

  void _killCreature({required bool isPlayer, required int lane, bool giveBones = false}) {
    final slots = isPlayer ? board.playerSlots : board.enemySlots;
    final creature = slots[lane];
    if (creature == null) return;
    slots[lane] = null;
    if (giveBones) {
      playerBones += 1;
      if (!isPlayer) {
        enemyBones += 1;
      }
    }
    _pushLog('${isPlayer ? 'Your' : 'Enemy'} ${creature.definition.name} died.');
    if (isPlayer && creature.definition.abilities.contains(CardAbility.undying)) {
      playerDiscard.add(CardInstance(creature.definition));
      _pushLog('${creature.definition.name} returns to discard (undying).');
    }
  }

  bool _checkVictory() {
    if (damageScale >= 5) {
      battleOver = true;
      playerWon = true;
      status = 'You win! Return to map.';
      _pushLog('You won the battle.');
      notifyListeners();
      return true;
    }
    if (damageScale <= -5) {
      battleOver = true;
      playerWon = false;
      status = 'You lose. The run ends.';
      _pushLog('You lost the battle.');
      notifyListeners();
      return true;
    }
    return false;
  }

  void concede() {
    battleOver = true;
    playerWon = false;
    status = 'You conceded.';
    _pushLog('You conceded.');
    notifyListeners();
  }

  void _pushLog(String entry) {
    log.add(entry);
    if (log.length > 60) {
      log.removeAt(0);
    }
  }
}
