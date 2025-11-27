import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/game_controller.dart';
import 'ui/screens/battle_screen.dart';
import 'ui/screens/map_screen.dart';
import 'ui/screens/menu_screen.dart';

void main() {
  runApp(const CrypticDeckApp());
}

class CrypticDeckApp extends StatelessWidget {
  const CrypticDeckApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GameController(),
      child: MaterialApp(
        title: 'Cryptic Deck',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          colorScheme: const ColorScheme.dark(
            primary: Colors.tealAccent,
            secondary: Colors.orangeAccent,
            surface: Color(0xFF161616),
          ),
          scaffoldBackgroundColor: const Color(0xFF111113),
          textTheme: const TextTheme(
            displaySmall: TextStyle(letterSpacing: 2, fontWeight: FontWeight.w700),
            titleMedium: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        home: const GameRoot(),
      ),
    );
  }
}

class GameRoot extends StatelessWidget {
  const GameRoot({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<GameController>();
    switch (controller.view) {
      case GameView.menu:
        return const MenuScreen();
      case GameView.map:
        return const MapScreen();
      case GameView.battle:
        return const BattleScreen();
    }
  }
}
