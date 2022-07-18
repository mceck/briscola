import 'package:briscola/components/card_pile.dart';
import 'package:briscola/components/card.dart';
import 'package:briscola/trump_game.dart';
import 'package:flame/components.dart';

class Stock extends CardPile {
  final Vector2 _scaledPosition;

  Stock({super.position, Vector2? scaledPosition})
      : _scaledPosition = scaledPosition ?? Vector2(-5, 5);

  @override
  void acquireCard(Card card) {
    assert(!card.isFaceUp);
    super.acquireCard(card);
    _spreadPile();
  }

  void _spreadPile() {
    final n = cards.length;
    for (var i = 0; i < n; i++) {
      cards[i].newPosition = position.clone();
      if (i == 0) {
        if (!cards[i].isFaceUp) {
          cards[i].flip();
        }
        cards[i].newPosition.add(Vector2(TrumpGame.cardWidth, 0));
      }
      cards[i].newPosition.addScaled(_scaledPosition, i.toDouble());
    }
  }

  List<Card> giveCards([int n = 3]) {
    final List<Card> ret = [];
    for (int i = 0; i < n; i++) {
      ret.add(giveCard());
    }
    return ret;
  }

  Card giveCard() {
    final ret = cards.last;
    cards.removeLast();
    return ret;
  }
}
