import 'package:flutter/material.dart';

import '../../core/card_models.dart';

class CardView extends StatelessWidget {
  const CardView({
    super.key,
    required this.card,
    this.hp,
    this.atk,
    this.selected = false,
    this.onTap,
    this.height = 160,
  });

  final CardDefinition card;
  final int? hp;
  final int? atk;
  final bool selected;
  final VoidCallback? onTap;
  final double height;

  @override
  Widget build(BuildContext context) {
    final color = _colorForCost(card.costType);
    final abilityText = card.abilities.map((a) => _labelAbility(a)).join(', ');
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.all(6),
        padding: const EdgeInsets.all(10),
        height: height,
        width: (height * 0.8).clamp(140, 220),
        decoration: BoxDecoration(
          color: color.withAlpha((255 * 0.15).round()),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? Colors.amberAccent : color,
            width: selected ? 3 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha((255 * 0.3).round()),
              blurRadius: 6,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 6,
              runSpacing: 4,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(minWidth: 80, maxWidth: 140),
                  child: Text(
                    card.name,
                    style: Theme.of(context).textTheme.titleMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                _CostBadge(card: card, color: color),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Text(
                card.description.isEmpty ? 'Tribe: ${card.tribe.name}' : card.description,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
            if (abilityText.isNotEmpty)
              Text(
                abilityText,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Colors.amberAccent.shade100),
              ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                _StatPill(label: 'ATK', value: (atk ?? card.attack).toString()),
                _StatPill(label: 'HP', value: (hp ?? card.health).toString()),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _colorForCost(CardCostType type) {
    switch (type) {
      case CardCostType.free:
        return Colors.greenAccent.shade400;
      case CardCostType.blood:
        return Colors.redAccent.shade200;
      case CardCostType.bones:
        return Colors.blueGrey.shade200;
    }
  }

  String _labelAbility(CardAbility ability) {
    switch (ability) {
      case CardAbility.flying:
        return 'Flying';
      case CardAbility.bifurcated:
        return 'Bifurcated';
      case CardAbility.poison:
        return 'Poison';
      case CardAbility.guard:
        return 'Guard';
      case CardAbility.undying:
        return 'Undying';
    }
  }
}

class _CostBadge extends StatelessWidget {
  const _CostBadge({required this.card, required this.color});

  final CardDefinition card;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final label = switch (card.costType) {
      CardCostType.free => 'Free',
      CardCostType.blood => '${card.costAmount} Blood',
      CardCostType.bones => '${card.costAmount} Bones',
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha((255 * 0.25).round()),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color),
      ),
      child: Text(label, style: Theme.of(context).textTheme.bodySmall),
    );
  }
}

class _StatPill extends StatelessWidget {
  const _StatPill({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black45,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white24),
      ),
      child: Wrap(
        spacing: 6,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          Text(value, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}
