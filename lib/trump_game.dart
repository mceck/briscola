import 'dart:math';
import 'dart:ui';

import 'package:briscola/components/card.dart';
import 'package:briscola/components/enemy_hand.dart';
import 'package:briscola/components/player_hand.dart';
import 'package:briscola/components/plays.dart';
import 'package:briscola/components/stock.dart';
import 'package:briscola/components/text.dart';
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

  late final ScoreText score;

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

    score = ScoreText(position: Vector2(cardGap, cardGap + cardHeight / 2));

    final world = World()
      ..addAll(cardSet)
      ..add(stock)
      ..add(playerHand)
      ..add(enemyHand)
      ..add(playerPoints)
      ..add(enemyPoints)
      ..add(plays)
      ..add(score);
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
      animatePlay(enemyPlay, true).then((_) => plays.acquireCard(enemyPlay));
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
    await animatePlay(card, playerTurn);
    print('You played ${card.toString()}');
    playerHand.removeCard(card);
    plays.acquireCard(card);
    await sleep();

    Card firstPlay;
    Card secondPlay;
    if (playerTurn) {
      firstPlay = card;
      secondPlay = enemyHand.aiPlay(card, trump);
      await animatePlay(secondPlay, false);
      plays.acquireCard(secondPlay);
      await sleep();
    } else {
      firstPlay = plays.cards.first;
      secondPlay = card;
    }

    if (playerTurn == firstWin(firstPlay, secondPlay)) {
      print('You took points');
      await animatePoints(playerPoints);
      plays.clearCards();
      playerTurn = true;
      playerPoints.acquireCard(firstPlay);
      playerPoints.acquireCard(secondPlay);
      try {
        Card c = stock.giveCard();
        await animatePick(c, playerHand);
        playerHand.acquireCard(c);
        c = stock.giveCard();
        await animatePick(c, enemyHand);
        enemyHand.acquireCard(c);
      } catch (e) {
        // EMPTY STOCK
      }
    } else {
      print('Enemy took points');
      await animatePoints(enemyPoints);
      plays.clearCards();
      playerTurn = false;
      enemyPoints.acquireCard(firstPlay);
      enemyPoints.acquireCard(secondPlay);
      try {
        Card c = stock.giveCard();
        await animatePick(c, enemyHand);
        enemyHand.acquireCard(c);
        c = stock.giveCard();
        await animatePick(c, playerHand);
        playerHand.acquireCard(c);
      } catch (e) {
        // EMPTY STOCK
      }
      if (!enemyHand.empty) {
        await sleep();
        final enemyPlay = enemyHand.aiPlay();
        await animatePlay(enemyPlay, true);

        plays.acquireCard(enemyPlay);
      }
    }
    if (playerHand.empty) {
      final who = playerPoints.points > enemyPoints.points ? "YOU" : "ENEMY";
      score.show(
          ' GAME ENDS \n player: ${playerPoints.points} \n enemy: ${enemyPoints.points} \n $who WINS ');

      await sleep(const Duration(seconds: 5));
      score.hide();
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

  Future<void> animatePoints(PositionComponent target) async {
    for (var c in plays.cards) {
      c.flip();
    }
    final xGap = target.position.x - plays.cards[0].position.x;
    final yGap = target.position.y - plays.cards[0].position.y;

    for (int i = 0; i < 40; i++) {
      plays.cards[0].position.add(Vector2(xGap / 40, yGap / 40));
      plays.cards[1].position
          .add(Vector2((xGap - cardWidth - cardGap) / 40, yGap / 40));
      await sleep(const Duration(milliseconds: 5));
    }
  }

  Future<void> animatePlay(Card c, bool first) async {
    if (!c.isFaceUp) {
      c.flip();
    }
    final xGap =
        (first ? plays.position.x : plays.position.x + cardGap + cardWidth) -
            c.position.x;
    final yGap = plays.position.y - c.position.y;
    for (int i = 0; i < 40; i++) {
      c.position.add(Vector2(xGap / 40, yGap / 40));
      await sleep(const Duration(milliseconds: 5));
    }
  }

  Future<void> animatePick(Card c, PositionComponent target) async {
    final xGap = target.position.x - c.position.x;
    final yGap = target.position.y - c.position.y;
    for (int i = 0; i < 40; i++) {
      c.position.add(Vector2(xGap / 40, yGap / 40));
      await sleep(const Duration(milliseconds: 5));
    }
  }

  Future<void> sleep([Duration time = const Duration(milliseconds: 500)]) =>
      Future.delayed(time);
}
