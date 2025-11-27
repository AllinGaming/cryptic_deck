import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/game_controller.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<GameController>();
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F10),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Cryptic Deck',
                style: Theme.of(context).textTheme.displaySmall,
              ),
              const SizedBox(height: 16),
              Text(
                'A Flutter take on Inscryption-style deck duels.',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: controller.startNewRun,
                icon: const Icon(Icons.play_arrow),
                label: const Text('Start New Run'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () => _showInfo(context),
                icon: const Icon(Icons.info_outline),
                label: const Text('How to play'),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white24),
                ),
                child: Text(
                  controller.eventLog,
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showInfo(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1C1C1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (ctx) {
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.info_outline),
                  const SizedBox(width: 8),
                  Text('Game Overview', style: Theme.of(context).textTheme.titleLarge),
                ],
              ),
              const SizedBox(height: 12),
              _InfoLine('Goal', 'Push damage scale to +5 to win battles, reach boss on the map.'),
              _InfoLine('Costs', 'Blood: sacrifice your board units. Bones: gained on deaths +1 each turn.'),
              _InfoLine('Deck', 'You start with squirrels (free sacrifices) plus basic attackers.'),
              _InfoLine('Turn', 'Auto draw each turn, play cards to lanes, End Turn to resolve attacks.'),
              _InfoLine('Events',
                  'Campfire buffs a card, Trader gives a card, Sacrifice adds run ATK buff, Totem gives +1 bones/battle.'),
              _InfoLine('Abilities',
                  'Flying hits directly, Bifurcated hits adjacent, Guard reduces damage, Poison kills, Undying returns.'),
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

class _InfoLine extends StatelessWidget {
  const _InfoLine(this.title, this.text);

  final String title;
  final String text;

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
