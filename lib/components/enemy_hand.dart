import 'dart:math';

import 'package:briscola/components/card_pile.dart';
import 'package:briscola/components/card.dart';
import 'package:briscola/models/suit.dart';
import 'package:briscola/trump_game.dart';
import 'package:flame/components.dart';

class EnemyHand extends CardPile {
  final Vector2 _scaledPosition;

  EnemyHand({super.position, Vector2? scaledPosition})
      : _scaledPosition =
            scaledPosition ?? Vector2(TrumpGame.cardWidth * 0.8, 0);

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

  Card aiPlay([Card? opponent, Suit? trump]) {
    final random = Random();
    Card card = cards[random.nextInt(cards.length)];
    if (opponent != null && trump != null && opponent.rank.points > 0) {
      if (opponent.suit != trump) {
        // try win without trump
        try {
          card = cards.firstWhere((c) {
            if (c.suit == opponent.suit &&
                c.rank.points > opponent.rank.points) {
              return true;
            }
            return false;
          });
        } catch (e) {
          // use trump
          card = cards.firstWhere((c) {
            if (c.suit == trump) {
              return true;
            }
            return false;
          }, orElse: () => card);
        }
      } else {
        // use trump
        card = cards.firstWhere((c) {
          if (c.suit == trump && c.rank.points > opponent.rank.points) {
            return true;
          }
          return false;
        }, orElse: () => card);
      }
    }
    removeCard(card);
    print('Enemy played ${card.toString()}');
    return card;
  }
}
