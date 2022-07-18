import 'package:briscola/trump_game.dart';
import 'package:briscola/components/card.dart';
import 'package:flame/components.dart';

class CardPile extends PositionComponent {
  final List<Card> cards = [];

  CardPile({super.position}) : super(size: TrumpGame.cardSize);

  void acquireCard(Card card) {
    card.newPosition = position.clone();
    card.priority = cards.length;
    cards.add(card);
  }

  void removeCard(Card c) {
    cards.remove(c);
  }

  void clearCards() {
    cards.clear();
  }

  bool get empty => cards.isEmpty;
}
