import 'package:flutter_test/flutter_test.dart';

import 'package:cryptic_deck/core/card_models.dart';
import 'package:cryptic_deck/core/run_state.dart';

void main() {
  test('Random reward can return rare and common', () {
    final run = RunState(meta: MetaProgress());
    final rare = run.randomReward();
    expect(CardLibrary.cards.contains(rare), isTrue);
    final common = run.randomReward();
    expect(CardLibrary.cards.contains(common), isTrue);
  });

  test('Buff random card increases stats', () {
    final run = RunState(meta: MetaProgress());
    final before = run.deck.first;
    run.buffRandomCard(health: true);
    final changed = run.deck.any((c) => c.health != before.health || c.attack != before.attack);
    expect(changed, isTrue);
  });
}
