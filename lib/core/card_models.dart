import 'dart:math';

enum CardCostType { free, blood, bones }

enum CardAbility { flying, bifurcated, poison, guard, undying }

enum CardTribe { beast, insect, undead, tech, reptile, none }

enum Rarity { common, uncommon, rare }

class CardDefinition {
  CardDefinition({
    required this.id,
    required this.name,
    required this.attack,
    required this.health,
    required this.costType,
    required this.costAmount,
    this.abilities = const [],
    this.tribe = CardTribe.none,
    this.rarity = Rarity.common,
    this.description = '',
  });

  final String id;
  final String name;
  final int attack;
  final int health;
  final CardCostType costType;
  final int costAmount;
  final List<CardAbility> abilities;
  final CardTribe tribe;
  final Rarity rarity;
  final String description;
}

class CardInstance {
  CardInstance(this.definition)
      : instanceId = 'ci_${_idCounter++}',
        currentHp = definition.health,
        currentAtk = definition.attack;

  final CardDefinition definition;
  final String instanceId;
  int currentHp;
  int currentAtk;
  bool exhausted = false;

  bool get isAlive => currentHp > 0;

  CardInstance copy() {
    final copy = CardInstance(definition);
    copy.currentHp = currentHp;
    copy.currentAtk = currentAtk;
    copy.exhausted = exhausted;
    return copy;
  }

  static int _idCounter = 0;
}

class CardLibrary {
  static final List<CardDefinition> cards = [
    CardDefinition(
      id: 'phoenix',
      name: 'Phoenix',
      attack: 0,
      health: 1,
      costType: CardCostType.bones,
      costAmount: 2,
      abilities: const [CardAbility.undying],
      tribe: CardTribe.undead,
      description: 'Returns to discard when it dies.',
    ),
    CardDefinition(
      id: 'squirrel',
      name: 'Squirrel',
      attack: 0,
      health: 1,
      costType: CardCostType.free,
      costAmount: 0,
      tribe: CardTribe.beast,
      description: 'Free sacrificer. Fuels blood costs.',
    ),
    CardDefinition(
      id: 'stoat',
      name: 'Stoat',
      attack: 1,
      health: 2,
      costType: CardCostType.blood,
      costAmount: 1,
      tribe: CardTribe.beast,
      description: 'Loyal starter beast.',
    ),
    CardDefinition(
      id: 'wolf',
      name: 'Wolf',
      attack: 3,
      health: 2,
      costType: CardCostType.blood,
      costAmount: 2,
      tribe: CardTribe.beast,
      description: 'Reliable heavy hitter.',
    ),
    CardDefinition(
      id: 'adder',
      name: 'Adder',
      attack: 1,
      health: 1,
      costType: CardCostType.blood,
      costAmount: 2,
      abilities: const [CardAbility.poison],
      tribe: CardTribe.reptile,
      description: 'Poison kills on hit.',
    ),
    CardDefinition(
      id: 'raven',
      name: 'Raven',
      attack: 2,
      health: 3,
      costType: CardCostType.bones,
      costAmount: 5,
      abilities: const [CardAbility.flying],
      tribe: CardTribe.insect,
      description: 'Flying strikes directly.',
    ),
    CardDefinition(
      id: 'skeleton',
      name: 'Skeleton',
      attack: 1,
      health: 1,
      costType: CardCostType.bones,
      costAmount: 1,
      tribe: CardTribe.undead,
      description: 'Cheap disposable bones user.',
    ),
    CardDefinition(
      id: 'elk',
      name: 'Elk',
      attack: 2,
      health: 4,
      costType: CardCostType.blood,
      costAmount: 2,
      tribe: CardTribe.beast,
      description: 'Sturdy lane blocker.',
    ),
    CardDefinition(
      id: 'mothman',
      name: 'Mothman',
      attack: 1,
      health: 5,
      costType: CardCostType.free,
      costAmount: 0,
      abilities: const [CardAbility.guard],
      rarity: Rarity.rare,
      description: 'Free guardian, low attack.',
    ),
    CardDefinition(
      id: 'hydra',
      name: 'Hydra',
      attack: 2,
      health: 2,
      costType: CardCostType.bones,
      costAmount: 3,
      abilities: const [CardAbility.bifurcated],
      rarity: Rarity.uncommon,
      description: 'Strikes adjacent lanes.',
    ),
    CardDefinition(
      id: 'bloodbot',
      name: 'Bloodbot',
      attack: 4,
      health: 3,
      costType: CardCostType.blood,
      costAmount: 3,
      abilities: const [CardAbility.guard],
      tribe: CardTribe.tech,
      rarity: Rarity.rare,
      description: 'Heavy metallic wall.',
    ),
  ];

  static List<CardDefinition> starterDeck() {
    return [
      byId('squirrel'),
      byId('squirrel'),
      byId('squirrel'),
      byId('stoat'),
      byId('stoat'),
      byId('wolf'),
      byId('skeleton'),
      byId('skeleton'),
      byId('hydra'),
    ];
  }

  static List<CardDefinition> enemySet({bool elite = false, bool boss = false}) {
    final base = [
      byId('stoat'),
      byId('skeleton'),
      byId('wolf'),
      byId('adder'),
      byId('elk'),
    ];
    if (elite) {
      base.addAll([byId('raven'), byId('hydra')]);
    }
    if (boss) {
      base.addAll([byId('bloodbot'), byId('raven')]);
    }
    return List.of(base);
  }

  static CardDefinition byId(String id) {
    return cards.firstWhere((c) => c.id == id);
  }

  static CardDefinition randomCard({Rarity rarity = Rarity.common, Random? rng}) {
    rng ??= Random();
    final options = cards.where((c) => c.rarity == rarity).toList();
    return options[rng.nextInt(options.length)];
  }
}
