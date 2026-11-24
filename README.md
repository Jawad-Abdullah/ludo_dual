# Ludo Duel

A simple, local two-player Ludo game built with Flutter. Red and Green take turns rolling one dice and moving four tokens.
The board shows all four traditional Ludo colors; only Red and Green are playable.

## Run the app

1. Install Flutter and connect a device, start an emulator, or use a desktop target.
2. From this project folder, run `flutter pub get`.
3. Run `flutter run`.

## How to play

- Tap **Roll dice** on your turn.
- A token can leave its home only when you roll a 6.
- After rolling, tap one of your highlighted tokens to move it.
- A roll that would move a token past the finish is not a legal move.
- Rolling a 6 gives you another turn. If you have no legal move, the turn passes.
- The first player to bring all four tokens home wins. Tap the refresh button to restart.

## Implementation

The game screen is a `StatefulWidget`; `setState()` updates the dice, turn, token positions, and status. A timer animates the rolling dice, `AnimatedContainer` animates token changes, and a `CustomPainter` draws the board and dice pips. The game uses a simplified two-player ruleset with no token captures.
