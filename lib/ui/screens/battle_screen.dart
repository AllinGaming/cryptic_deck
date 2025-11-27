import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/battle_engine.dart';
import '../../core/card_models.dart';
import '../../core/game_controller.dart';
import '../widgets/card_view.dart';

class BattleScreen extends StatefulWidget {
  const BattleScreen({super.key});

  @override
  State<BattleScreen> createState() => _BattleScreenState();
}

class _BattleScreenState extends State<BattleScreen> {
  CardInstance? _selected;

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<GameController>();
    final battle = controller.battle;
    if (battle == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('Battle - Turn ${battle.turn}'),
        actions: [
          IconButton(
            onPressed: () => _showHelp(context),
            icon: const Icon(Icons.help_outline),
            tooltip: 'Battle help',
          ),
          IconButton(
            onPressed: () {
              battle.concede();
              controller.onBattleFinished();
            },
            icon: const Icon(Icons.flag),
            tooltip: 'Concede',
          )
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  children: [
                    _BattleHud(battle: battle),
                    _BoardRow(
                      label: 'Enemy Row (damage toward you)',
                      slots: battle.board.enemySlots,
                      onTapLane: null,
                      isPlayerRow: false,
                    ),
                    const Divider(height: 1, color: Colors.white24),
                    _BoardRow(
                      label: 'Your Row (tap a slot to place selected card)',
                      slots: battle.board.playerSlots,
                      onTapLane: (lane) {
                        if (_selected == null) return;
                        final placed = battle.playCardToLane(_selected!, lane);
                        if (placed) setState(() => _selected = null);
                      },
                      isPlayerRow: true,
                      highlightedLane: _selected != null ? -1 : null,
                    ),
                    _HandArea(
                      battle: battle,
                      selected: _selected,
                      onSelect: (card) => setState(() => _selected = card),
                    ),
                    const SizedBox(height: 6),
                    _LogArea(log: battle.log),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: battle.battleOver ? null : battle.endPlayerTurn,
                            child: const Text('End Turn'),
                          ),
                          if (battle.battleOver)
                            ElevatedButton(
                              onPressed: controller.onBattleFinished,
                              child: const Text('Return to Map'),
                            ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        battle.status,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _showHelp(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1C1C1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.help_outline),
                  const SizedBox(width: 8),
                  Text('Battle Help', style: Theme.of(context).textTheme.titleLarge),
                ],
              ),
              const SizedBox(height: 12),
              _HelpBullet(
                title: 'Goal',
                body: 'Push the damage scale to +5 to win (at -5 you lose). HP shown below tracks the same scale.',
              ),
              _HelpBullet(
                title: 'Costs',
                body:
                    'Blood cards: sacrifice your board units equal to cost. Bone cards: pay bones (gain bones when things die +1/turn).',
              ),
              _HelpBullet(
                title: 'Turn',
                body: 'Draw automatically at start. Play from hand, then End Turn to resolve attacks.',
              ),
              _HelpBullet(
                title: 'Abilities',
                body:
                    'Bifurcated: hits adjacent lanes; Guard: -1 damage taken; Poison: kill on hit; Flying: skip blockers; Undying: returns to discard.',
              ),
              _HelpBullet(
                title: 'Sacrifice Tip',
                body: 'Play a blood-cost card and select victims when prompted to pay the cost.',
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Close'),
                ),
              )
            ],
          ),
        );
      },
    );
  }
}

class _BattleHud extends StatelessWidget {
  const _BattleHud({required this.battle});
  final BattleState battle;

  @override
  Widget build(BuildContext context) {
    final playerHp = (5 + battle.damageScale).clamp(0, 10);
    final enemyHp = (5 - battle.damageScale).clamp(0, 10);
    return Container(
      padding: const EdgeInsets.all(12),
      color: Colors.white10,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceEvenly,
            spacing: 12,
            runSpacing: 8,
            children: [
              _HudPill(
                label: 'Your HP (scale)',
                value: playerHp.toString(),
                icon: Icons.favorite,
              ),
              _HudPill(
                label: 'Enemy HP (scale)',
                value: enemyHp.toString(),
                icon: Icons.heart_broken,
              ),
              _HudPill(
                label: 'Bones (your costs)',
                value: battle.playerBones.toString(),
                icon: Icons.bubble_chart,
              ),
              _HudPill(
                label: 'Enemy Bones',
                value: battle.enemyBones.toString(),
                icon: Icons.water_drop,
              ),
              _HudPill(
                label: 'Damage Scale (+5 win / -5 loss)',
                value: battle.damageScale.toString(),
                icon: Icons.compare_arrows,
              ),
              _HudPill(
                label: battle.playerWon ? 'Victory' : 'Battle State',
                value: battle.battleOver ? 'Over' : 'Ongoing',
                icon: battle.playerWon ? Icons.emoji_events : Icons.sports_martial_arts,
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Tip: sacrifice allies for blood, bones pay bone cards, push the scale to +5 to win.',
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _BoardRow extends StatelessWidget {
  const _BoardRow({
    required this.label,
    required this.slots,
    required this.isPlayerRow,
    this.onTapLane,
    this.highlightedLane,
  });

  final String label;
  final List<CardInstance?> slots;
  final bool isPlayerRow;
  final void Function(int lane)? onTapLane;
  final int? highlightedLane;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          Text(label, style: Theme.of(context).textTheme.titleMedium),
          LayoutBuilder(
            builder: (context, constraints) {
              final available = constraints.maxWidth;
              final laneWidth = (available / slots.length) - 20;
              final clampedWidth = laneWidth.clamp(90, 150).toDouble();
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(slots.length, (index) {
                    final card = slots[index];
                    final empty = card == null;
                    return GestureDetector(
                      onTap: onTapLane != null ? () => onTapLane!(index) : null,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        margin: const EdgeInsets.all(6),
                        width: clampedWidth,
                        height: 150,
                        decoration: BoxDecoration(
                          color: empty ? Colors.white12 : Colors.black54,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: empty
                                ? Colors.white24
                                : (isPlayerRow ? Colors.tealAccent : Colors.redAccent),
                            width: 2,
                          ),
                        ),
                        child: empty
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.add,
                                    color:
                                        highlightedLane == index ? Colors.amberAccent : Colors.white24,
                                  ),
                                  const SizedBox(height: 4),
                                  Text('Lane ${index + 1}',
                                      style: Theme.of(context).textTheme.bodySmall),
                                ],
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(card.definition.name, overflow: TextOverflow.ellipsis),
                                  const SizedBox(height: 4),
                                  Text('ATK ${card.currentAtk} • HP ${card.currentHp}'),
                                  Text(
                                    card.definition.abilities.isEmpty
                                        ? 'No ability'
                                        : card.definition.abilities.map((a) => a.name).join(', '),
                                    style: Theme.of(context).textTheme.bodySmall,
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                      ),
                    );
                  }),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _HandArea extends StatelessWidget {
  const _HandArea({required this.battle, required this.selected, required this.onSelect});

  final BattleState battle;
  final CardInstance? selected;
  final void Function(CardInstance) onSelect;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 170, maxHeight: 190),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        itemCount: battle.playerHand.length,
        itemBuilder: (context, index) {
          final card = battle.playerHand[index];
          return CardView(
            card: card.definition,
            atk: card.currentAtk,
            hp: card.currentHp,
            height: 170,
            selected: selected?.instanceId == card.instanceId,
            onTap: battle.battleOver ? null : () => onSelect(card),
          );
        },
      ),
    );
  }
}

class _LogArea extends StatelessWidget {
  const _LogArea({required this.log});

  final List<String> log;

  @override
  Widget build(BuildContext context) {
    final entries = log.reversed.toList();
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24),
      ),
      height: 180,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Battle Log', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 6),
          Expanded(
            child: ListView.builder(
              reverse: true,
              itemCount: entries.length,
              itemBuilder: (context, index) {
                return Text(
                  entries[index],
                  style: Theme.of(context).textTheme.bodySmall,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _HudPill extends StatelessWidget {
  const _HudPill({required this.label, required this.value, required this.icon});

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white12,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Theme.of(context).textTheme.bodySmall),
              Text(value, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ],
      ),
    );
  }
}

class _HelpBullet extends StatelessWidget {
  const _HelpBullet({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('- '),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: Theme.of(context).textTheme.bodyMedium,
                children: [
                  TextSpan(
                    text: '$title: ',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: body),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
