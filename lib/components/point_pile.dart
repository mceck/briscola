import 'package:briscola/components/card_pile.dart';
import 'package:briscola/components/card.dart';
import 'package:flame/components.dart';

class PointPile extends CardPile {
  final Vector2 _scaledPosition;

  PointPile({super.position, Vector2? scaledPosition})
      : _scaledPosition = scaledPosition ?? Vector2(-5, 5);

  @override
  void acquireCard(Card card) {
    if (card.isFaceUp) {
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

  int get points => cards.map((c) => c.rank.points).reduce((a, b) => a + b);
}
