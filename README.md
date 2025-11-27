# Cryptic Deck

![coverage](https://img.shields.io/badge/coverage-84.6%25-brightgreen) [![Pages deploy](https://github.com/AllinGaming/cryptic_deck/actions/workflows/deploy.yml/badge.svg)](https://github.com/AllinGaming/cryptic_deck/actions/workflows/deploy.yml)

[Play in the browser](https://allingaming.github.io/cryptic_deck/)

A pure-Widget Inscryption-inspired roguelike deckbuilder built with Flutter. No external art assets—everything is drawn with Flutter UI.

## What it is
- Lane-based battles (4 lanes each side) using blood/bones costs, sacrifices, and a damage scale win condition.
- Node map with events (battles, campfire, trader, sacrifice, totem, boss).
- Starter deck includes free squirrels (sacrifice fodder) plus attack cards; bones drip in each turn to enable bone-cost plays.
- Built with `provider`, modular core logic (`lib/core`) and UI (`lib/ui`).

## Quick rules
- Goal: push the damage scale to +5 to win (at -5 you lose). HUD shows both sides' HP equivalents.
- Costs: blood cards need sacrifices on your board; bone cards cost bones (gain 1 each turn + from deaths).
- Turn: auto-draw at start, play from hand to lanes, then `End Turn` to resolve attacks.
- Abilities: Flying (hits directly), Bifurcated (adjacent lanes), Guard (-1 dmg), Poison (kill on hit), Undying (returns to discard).
- Events: Campfire buffs HP/ATK, Trader gives a card, Sacrifice adds run ATK buff, Totem adds +1 bones per battle.

## Project structure
- `lib/core/` — cards, board state, battle engine, run/map state, controller.
- `lib/ui/screens/` — menu, map, battle screens with in-app help.
- `lib/ui/widgets/` — reusable card view.
- `test/` — unit tests for battle logic, map generation, and app smoke test.
