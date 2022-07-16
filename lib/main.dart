import 'package:flutter/widgets.dart';
import 'package:flame/game.dart';
import 'package:briscola/trump_game.dart';

void main() {
  final game = TrumpGame();
  runApp(GameWidget(
    game: game,
    mouseCursor: SystemMouseCursors.click,
  ));
}
