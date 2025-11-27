import 'dart:math';

import 'card_models.dart';
import 'map_node.dart';

class MetaProgress {
  MetaProgress({
    this.unlockedCards = const {},
    this.totalRuns = 0,
    this.wins = 0,
  });

  final Set<String> unlockedCards;
  final int totalRuns;
  final int wins;

  MetaProgress copyWith({Set<String>? unlockedCards, int? totalRuns, int? wins}) {
    return MetaProgress(
      unlockedCards: unlockedCards ?? this.unlockedCards,
      totalRuns: totalRuns ?? this.totalRuns,
      wins: wins ?? this.wins,
    );
  }
}

class RunState {
  RunState({required this.meta})
      : deck = CardLibrary.starterDeck(),
        map = MapState.generate(),
        currency = 0,
        bonesBonus = 0,
        attackBuff = 0;

  final MetaProgress meta;
  List<CardDefinition> deck;
  MapState map;
  int currency;
  int bonesBonus;
  int attackBuff;

  final Random _rng = Random();

  CardDefinition randomReward() {
    final roll = _rng.nextDouble();
    if (roll > 0.8) return CardLibrary.randomCard(rarity: Rarity.rare, rng: _rng);
    if (roll > 0.55) return CardLibrary.randomCard(rarity: Rarity.uncommon, rng: _rng);
    return CardLibrary.randomCard(rarity: Rarity.common, rng: _rng);
  }

  void addCard(CardDefinition card) {
    deck = [...deck, card];
  }

  void buffRandomCard({bool health = false}) {
    if (deck.isEmpty) return;
    final card = deck[_rng.nextInt(deck.length)];
    final buffed = CardDefinition(
      id: '${card.id}-buff-${_rng.nextInt(9999)}',
      name: '${card.name}+',
      attack: card.attack + (health ? 0 : 1),
      health: card.health + (health ? 2 : 0),
      costType: card.costType,
      costAmount: card.costAmount,
      abilities: card.abilities,
      tribe: card.tribe,
      rarity: card.rarity,
      description: health ? 'Campfire toughness' : 'Campfire might',
    );
    deck = [...deck.where((c) => c != card), buffed];
  }
}
