import 'package:cryptic_deck/core/battle_engine.dart';
import 'package:cryptic_deck/core/game_controller.dart';
import 'package:cryptic_deck/ui/screens/battle_screen.dart';
import 'package:cryptic_deck/ui/screens/map_screen.dart';
import 'package:cryptic_deck/ui/screens/menu_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('Menu screen shows start button and help', (tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => GameController(),
        child: const MaterialApp(home: MenuScreen()),
      ),
    );
    expect(find.textContaining('Cryptic Deck'), findsOneWidget);
    expect(find.byIcon(Icons.play_arrow), findsOneWidget);
    expect(find.byIcon(Icons.info_outline), findsOneWidget);
    await tester.tap(find.byIcon(Icons.info_outline));
    await tester.pumpAndSettle();
    expect(find.textContaining('Game Overview'), findsOneWidget);
  });

  testWidgets('Map screen renders rows and deck grid', (tester) async {
    final controller = GameController()..startNewRun();
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: controller,
        child: const MaterialApp(home: MapScreen()),
      ),
    );
    expect(find.text('Node Map'), findsOneWidget);
    expect(find.textContaining('Deck ('), findsOneWidget);
    await tester.tap(find.byIcon(Icons.help_outline));
    await tester.pumpAndSettle();
    expect(find.textContaining('How to play'), findsOneWidget);
  });

  testWidgets('Battle screen renders hand and log', (tester) async {
    final controller = GameController()..startNewRun();
    controller.battle = BattleState(run: controller.run!, difficulty: BattleDifficulty.normal);
    controller.view = GameView.battle;

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: controller,
        child: const MaterialApp(home: BattleScreen()),
      ),
    );

    expect(find.textContaining('Battle - Turn'), findsOneWidget);
    expect(find.text('Battle Log'), findsOneWidget);
    expect(find.textContaining('ATK'), findsWidgets);
    await tester.tap(find.byIcon(Icons.help_outline));
    await tester.pumpAndSettle();
    expect(find.textContaining('Battle Help'), findsOneWidget);
  });
}
