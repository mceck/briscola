import 'package:briscola/components/card_pile.dart';
import 'package:briscola/components/card.dart';
import 'package:briscola/trump_game.dart';
import 'package:flame/components.dart';

class PlayerHand extends CardPile {
  final Vector2 _scaledPosition;

  PlayerHand({super.position, Vector2? scaledPosition})
      : _scaledPosition =
            scaledPosition ?? Vector2(TrumpGame.cardWidth * 0.8, 0);

  @override
  void acquireCard(Card card) {
    if (!card.isFaceUp) {
      card.flip();
    }
    super.acquireCard(card);
    _spreadPile();
  }

  void _spreadPile() {
    final n = cards.length;
    for (var i = 0; i < n; i++) {
      cards[i].position = position;
      cards[i].position.addScaled(_scaledPosition, i.toDouble());
    }
  }
}
