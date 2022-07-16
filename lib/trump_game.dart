import 'dart:math';
import 'dart:ui';

import 'package:briscola/components/card.dart';
import 'package:briscola/components/enemy_hand.dart';
import 'package:briscola/components/player_hand.dart';
import 'package:briscola/components/plays.dart';
import 'package:briscola/components/stock.dart';
import 'package:briscola/models/suit.dart';
import 'package:flame/components.dart';
import 'package:flame/experimental.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';

import 'components/point_pile.dart';

class TrumpGame extends FlameGame with HasTappableComponents {
  static const double cardWidth = 1000.0;
  static const double cardHeight = 1400.0;
  static const double cardGap = 175.0;
  static const double cardRadius = 100.0;
  static final Vector2 cardSize = Vector2(cardWidth, cardHeight);

  late final Stock stock;
  late final PlayerHand playerHand;
  late final EnemyHand enemyHand;

  late final PointPile playerPoints;
  late final PointPile enemyPoints;

  late final Plays plays;

  late final Suit trump;

  bool lockMoves = false;
  bool playerTurn = true;

  @override
  Color backgroundColor() => Color.fromARGB(255, 37, 40, 59);

  @override
  Future<void> onLoad() async {
    await Flame.images.load('card-sprites.png');
    final cardSet =
        List.generate(40, (index) => Card((index % 10) + 1, index ~/ 10))
          ..shuffle();

    trump = cardSet.first.suit;

    stock = Stock(position: Vector2(cardGap, cardHeight * 2 + 2 * cardGap));
    playerHand = PlayerHand(
        position:
            Vector2(cardGap + 3.5 * cardWidth, cardHeight * 4 + 2 * cardGap));
    enemyHand =
        EnemyHand(position: Vector2(cardGap + 3.5 * cardWidth, cardGap));
    playerPoints = PointPile(
        position:
            Vector2(cardGap + 7 * cardWidth, cardHeight * 4 + 2 * cardGap));
    enemyPoints =
        PointPile(position: Vector2(cardGap + 7 * cardWidth, cardGap));

    plays = Plays(
        position: Vector2(cardGap + 3.5 * cardWidth, cardGap + 2 * cardHeight));

    final world = World()
      ..addAll(cardSet)
      ..add(stock)
      ..add(playerHand)
      ..add(enemyHand)
      ..add(playerPoints)
      ..add(enemyPoints)
      ..add(plays);
    add(world);

    final camera = CameraComponent(world: world)
      ..viewfinder.visibleGameSize =
          Vector2(cardWidth * 8 + cardGap * 8, 5 * cardHeight + 3 * cardGap)
      ..viewfinder.position = Vector2(cardWidth * 3.5 + cardGap * 4, 0)
      ..viewfinder.anchor = Anchor.topCenter;
    add(camera);

    cardSet.forEach(stock.acquireCard);

    startGame();
  }

  void startGame() {
    var hand = stock.giveCards();
    hand.forEach(playerHand.acquireCard);

    hand = stock.giveCards();
    hand.forEach(enemyHand.acquireCard);

    playerTurn = Random().nextBool();
    if (!playerTurn) {
      final enemyPlay = enemyHand.aiPlay();
      plays.acquireCard(enemyPlay);
    }
  }

  void resetGame() {
    final cards = [...playerPoints.cards, ...enemyPoints.cards];
    playerPoints.clearCards();
    enemyPoints.clearCards();
    cards.shuffle();
    cards.forEach(stock.acquireCard);

    startGame();
  }

  void onCardTap(Card card) {
    if (!lockMoves && playerHand.cards.contains(card)) {
      play(card);
    }
  }

  void play(Card card) async {
    lockMoves = true;
    print('You played ${card.toString()}');
    playerHand.removeCard(card);
    plays.acquireCard(card);
    await sleep();

    Card firstPlay;
    Card secondPlay;
    if (playerTurn) {
      firstPlay = card;
      secondPlay = enemyHand.aiPlay(card, trump);
      plays.acquireCard(secondPlay);
      await sleep();
    } else {
      firstPlay = plays.cards.first;
      secondPlay = card;
    }
    plays.clearCards();

    if (playerTurn == firstWin(firstPlay, secondPlay)) {
      print('You took points');
      playerTurn = true;
      playerPoints.acquireCard(firstPlay);
      playerPoints.acquireCard(secondPlay);
      try {
        playerHand.acquireCard(stock.giveCard());
        enemyHand.acquireCard(stock.giveCard());
      } catch (e) {
        // EMPTY STOCK
      }
    } else {
      print('Enemy took points');
      playerTurn = false;
      enemyPoints.acquireCard(firstPlay);
      enemyPoints.acquireCard(secondPlay);
      try {
        enemyHand.acquireCard(stock.giveCard());
        playerHand.acquireCard(stock.giveCard());
      } catch (e) {
        // EMPTY STOCK
      }
      if (!enemyHand.empty) {
        await sleep();
        final enemyPlay = enemyHand.aiPlay();
        plays.acquireCard(enemyPlay);
      }
    }
    if (playerHand.empty) {
      final who = playerPoints.points > enemyPoints.points ? "YOU" : "ENEMY";
      print(
          "GAME ENDS player: ${playerPoints.points} enemy: ${enemyPoints.points}");
      print("$who WINS");
      await sleep();
      resetGame();
    }
    lockMoves = false;
  }

  bool firstWin(Card first, Card second) {
    if (first.suit == trump && second.suit != trump) {
      return true;
    }
    if (second.suit == trump && first.suit != trump) {
      return false;
    }
    if (first.suit != second.suit) {
      return true;
    }
    return first.rank.points > second.rank.points;
  }

  Future<void> sleep([Duration time = const Duration(milliseconds: 500)]) =>
      Future.delayed(time);
}
