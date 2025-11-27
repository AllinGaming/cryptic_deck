import 'card_models.dart';

class BoardState {
  BoardState()
      : playerSlots = List<CardInstance?>.filled(4, null),
        enemySlots = List<CardInstance?>.filled(4, null);

  final List<CardInstance?> playerSlots;
  final List<CardInstance?> enemySlots;

  Iterable<CardInstance> get allCreatures sync* {
    for (final card in playerSlots) {
      if (card != null) yield card;
    }
    for (final card in enemySlots) {
      if (card != null) yield card;
    }
  }

  void clearLane(bool isPlayer, int lane) {
    if (isPlayer) {
      playerSlots[lane] = null;
    } else {
      enemySlots[lane] = null;
    }
  }
}
