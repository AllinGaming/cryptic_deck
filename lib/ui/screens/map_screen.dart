import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/card_models.dart';
import '../../core/game_controller.dart';
import '../../core/map_node.dart';
import '../../core/run_state.dart';
import '../widgets/card_view.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<GameController>();
    final RunState run = controller.run!;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Node Map'),
        actions: [
          IconButton(
            onPressed: () => _showHelp(context),
            icon: const Icon(Icons.help_outline),
            tooltip: 'Help',
          ),
          IconButton(
            onPressed: controller.abandonRun,
            icon: const Icon(Icons.exit_to_app),
            tooltip: 'Abandon Run',
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 900;
          final mapPane = _MapColumn(
            map: run.map,
            onNodeSelected: controller.selectNode,
            currentRow: run.map.currentRow,
          );
          final deckPane = _DeckPanel(deck: run.deck, eventLog: controller.eventLog);
          if (isWide) {
            return Row(
              children: [
                Expanded(flex: 2, child: mapPane),
                Expanded(flex: 3, child: deckPane),
              ],
            );
          }
          return ListView(
            children: [
              SizedBox(height: 320, child: mapPane),
              SizedBox(height: constraints.maxHeight - 320, child: deckPane),
            ],
          );
        },
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
                  const Icon(Icons.map),
                  const SizedBox(width: 8),
                  Text('How to play', style: Theme.of(context).textTheme.titleLarge),
                ],
              ),
              const SizedBox(height: 10),
              _HelpLine(title: 'Goal', text: 'Fight through nodes to the boss. Wins push meta progress.'),
              _HelpLine(
                  title: 'Blood vs Bones',
                  text:
                      'Blood cards need sacrifices on your board. Bones pay bone-cost cards; gain bones when things die and +1 each turn.'),
              _HelpLine(
                  title: 'Turn',
                  text: 'Draw auto at start. Play cards from hand, then End Turn to resolve attacks.'),
              _HelpLine(
                  title: 'Abilities',
                  text:
                      'Flying hits directly. Bifurcated hits adjacent lanes. Guard -1 dmg. Poison kills on hit. Undying returns to discard.'),
              _HelpLine(
                  title: 'Events',
                  text:
                      'Campfire buffs HP/ATK. Trader gives a card. Sacrifice grants run ATK buff. Totem adds +1 bones per battle.'),
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

class _MapColumn extends StatelessWidget {
  const _MapColumn({
    required this.map,
    required this.onNodeSelected,
    required this.currentRow,
  });

  final MapState map;
  final void Function(MapNode) onNodeSelected;
  final int currentRow;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: map.rows.length,
      itemBuilder: (context, rowIndex) {
        final row = map.rows[rowIndex];
        final isCurrent = rowIndex == currentRow;
        return AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: isCurrent ? 1.0 : 0.4,
          child: Card(
            color: isCurrent
                ? Colors.deepOrange.shade200.withAlpha((255 * 0.15).round())
                : Colors.white12,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: 12,
                runSpacing: 10,
                children: row.map((node) {
                  return ConstrainedBox(
                    constraints: const BoxConstraints(minWidth: 100),
                    child: ElevatedButton(
                      onPressed: isCurrent ? () => onNodeSelected(node) : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _colorForType(node.type),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(node.label),
                          const SizedBox(height: 4),
                          Text(
                            node.type.name.toUpperCase(),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        );
      },
    );
  }

  Color _colorForType(MapNodeType type) {
    switch (type) {
      case MapNodeType.battle:
        return Colors.redAccent.shade200;
      case MapNodeType.elite:
        return Colors.deepPurple.shade300;
      case MapNodeType.campfire:
        return Colors.orange.shade300;
      case MapNodeType.sacrifice:
        return Colors.brown.shade400;
      case MapNodeType.trader:
        return Colors.green.shade400;
      case MapNodeType.totem:
        return Colors.blueGrey.shade400;
      case MapNodeType.boss:
        return Colors.black87;
    }
  }
}

class _DeckPanel extends StatelessWidget {
  const _DeckPanel({required this.deck, required this.eventLog});

  final List<CardDefinition> deck;
  final String eventLog;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black12,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Deck (${deck.length} cards)', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text('Recent event:', style: Theme.of(context).textTheme.bodySmall),
                Text(eventLog, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final columns = (constraints.maxWidth / 180).floor().clamp(1, 3);
                return GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    childAspectRatio: 0.65,
                  ),
                  itemCount: deck.length,
                  itemBuilder: (context, index) {
                    final card = deck[index];
                    return CardView(card: card, height: 200);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _HelpLine extends StatelessWidget {
  const _HelpLine({required this.title, required this.text});

  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• '),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: Theme.of(context).textTheme.bodyMedium,
                children: [
                  TextSpan(text: '$title: ', style: const TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: text),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
