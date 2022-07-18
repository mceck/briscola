import 'dart:math';

import 'package:briscola/trump_game.dart';
import 'package:briscola/models/sprites.dart';
import 'package:flame/components.dart';
import 'package:flame/experimental.dart';
import 'package:flame/image_composition.dart';
import 'package:flutter/widgets.dart';

import '../models/rank.dart';
import '../models/suit.dart';

class Card extends PositionComponent with TapCallbacks, HasGameRef<TrumpGame> {
  // card back painting
  static final Paint backBackgroundPaint = Paint()
    ..color = const Color(0xff380c02);
  static final Paint backBorderPaint1 = Paint()
    ..color = const Color(0xffdbaf58)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 10;
  static final Paint backBorderPaint2 = Paint()
    ..color = const Color(0x5CEF971B)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 35;
  static final RRect cardRRect = RRect.fromRectAndRadius(
    TrumpGame.cardSize.toRect(),
    const Radius.circular(TrumpGame.cardRadius),
  );
  static final RRect backRRectInner = cardRRect.deflate(40);
  static final Sprite flameSprite = CardSprites.getSprite(1367, 6, 357, 501);

  // card front painting
  static final Paint frontBackgroundPaint = Paint()
    ..color = const Color.fromARGB(255, 255, 246, 162);
  static final Paint redBorderPaint = Paint()
    ..color = const Color.fromARGB(255, 211, 45, 45)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 10;
  static final Paint blackBorderPaint = Paint()
    ..color = const Color.fromARGB(255, 38, 38, 38)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 10;
  static final Sprite redJack = CardSprites.getSprite(81, 565, 562, 488);
  static final Sprite redQueen = CardSprites.getSprite(717, 541, 486, 515);
  static final Sprite redKing = CardSprites.getSprite(1305, 532, 407, 549);
  static final blueFilter = Paint()
    ..colorFilter = const ColorFilter.mode(
      Color.fromARGB(68, 0, 0, 0),
      BlendMode.srcATop,
    );
  static final Sprite blackJack = CardSprites.getSprite(81, 565, 562, 488)
    ..paint = blueFilter;
  static final Sprite blackQueen = CardSprites.getSprite(717, 541, 486, 515)
    ..paint = blueFilter;
  static final Sprite blackKing = CardSprites.getSprite(1305, 532, 407, 549)
    ..paint = blueFilter;

  final Rank rank;
  final Suit suit;
  bool _faceUp;
  Vector2 newPosition = Vector2(0, 0);

  Card(int intRank, int intSuit)
      : rank = Rank.fromInt(intRank),
        suit = Suit.fromInt(intSuit),
        _faceUp = false,
        super(size: TrumpGame.cardSize);

  bool get isFaceUp => _faceUp;
  void flip() => _faceUp = !_faceUp;

  @override
  String toString() => rank.label + suit.label;

  @override
  void render(Canvas canvas) {
    if (_faceUp) {
      _renderFront(canvas);
    } else {
      _renderBack(canvas);
    }
  }

  @override
  void update(double dt) {
    if (position.x != newPosition.x || position.y != newPosition.y) {
      final xGap = newPosition.x - position.x;
      final yGap = newPosition.y - position.y;
      double velocity = 6.0 * dt;
      position.add(Vector2(xGap * velocity, yGap * velocity));
    }
  }

  void _renderFront(Canvas canvas) {
    canvas.drawRRect(cardRRect, frontBackgroundPaint);
    canvas.drawRRect(
      cardRRect,
      suit.isRed ? redBorderPaint : blackBorderPaint,
    );
    final rankSprite = suit.isBlack ? rank.blackSprite : rank.redSprite;
    final suitSprite = suit.sprite;
    _drawSprite(canvas, rankSprite, 0.1, 0.08);
    _drawSprite(canvas, rankSprite, 0.1, 0.08, rotate: true);
    _drawSprite(canvas, suitSprite, 0.1, 0.18, scale: 0.5);
    _drawSprite(canvas, suitSprite, 0.1, 0.18, scale: 0.5, rotate: true);

    switch (rank.value) {
      case 1:
        _drawSprite(canvas, suitSprite, 0.5, 0.5, scale: 2.5);
        break;
      case 2:
        _drawSprite(canvas, suitSprite, 0.5, 0.25);
        _drawSprite(canvas, suitSprite, 0.5, 0.25, rotate: true);
        break;
      case 3:
        _drawSprite(canvas, suitSprite, 0.5, 0.2);
        _drawSprite(canvas, suitSprite, 0.5, 0.5);
        _drawSprite(canvas, suitSprite, 0.5, 0.2, rotate: true);
        break;
      case 4:
        _drawSprite(canvas, suitSprite, 0.3, 0.25);
        _drawSprite(canvas, suitSprite, 0.7, 0.25);
        _drawSprite(canvas, suitSprite, 0.3, 0.25, rotate: true);
        _drawSprite(canvas, suitSprite, 0.7, 0.25, rotate: true);
        break;
      case 5:
        _drawSprite(canvas, suitSprite, 0.3, 0.25);
        _drawSprite(canvas, suitSprite, 0.7, 0.25);
        _drawSprite(canvas, suitSprite, 0.3, 0.25, rotate: true);
        _drawSprite(canvas, suitSprite, 0.7, 0.25, rotate: true);
        _drawSprite(canvas, suitSprite, 0.5, 0.5);
        break;
      case 6:
        _drawSprite(canvas, suitSprite, 0.3, 0.25);
        _drawSprite(canvas, suitSprite, 0.7, 0.25);
        _drawSprite(canvas, suitSprite, 0.3, 0.5);
        _drawSprite(canvas, suitSprite, 0.7, 0.5);
        _drawSprite(canvas, suitSprite, 0.3, 0.25, rotate: true);
        _drawSprite(canvas, suitSprite, 0.7, 0.25, rotate: true);
        break;
      case 7:
        _drawSprite(canvas, suitSprite, 0.3, 0.2);
        _drawSprite(canvas, suitSprite, 0.7, 0.2);
        _drawSprite(canvas, suitSprite, 0.5, 0.35);
        _drawSprite(canvas, suitSprite, 0.3, 0.5);
        _drawSprite(canvas, suitSprite, 0.7, 0.5);
        _drawSprite(canvas, suitSprite, 0.3, 0.2, rotate: true);
        _drawSprite(canvas, suitSprite, 0.7, 0.2, rotate: true);
        break;
      // case 8:
      //   _drawSprite(canvas, suitSprite, 0.3, 0.2);
      //   _drawSprite(canvas, suitSprite, 0.7, 0.2);
      //   _drawSprite(canvas, suitSprite, 0.5, 0.35);
      //   _drawSprite(canvas, suitSprite, 0.3, 0.5);
      //   _drawSprite(canvas, suitSprite, 0.7, 0.5);
      //   _drawSprite(canvas, suitSprite, 0.3, 0.2, rotate: true);
      //   _drawSprite(canvas, suitSprite, 0.7, 0.2, rotate: true);
      //   _drawSprite(canvas, suitSprite, 0.5, 0.35, rotate: true);
      //   break;
      // case 9:
      //   _drawSprite(canvas, suitSprite, 0.3, 0.2);
      //   _drawSprite(canvas, suitSprite, 0.7, 0.2);
      //   _drawSprite(canvas, suitSprite, 0.5, 0.3);
      //   _drawSprite(canvas, suitSprite, 0.3, 0.4);
      //   _drawSprite(canvas, suitSprite, 0.7, 0.4);
      //   _drawSprite(canvas, suitSprite, 0.3, 0.2, rotate: true);
      //   _drawSprite(canvas, suitSprite, 0.7, 0.2, rotate: true);
      //   _drawSprite(canvas, suitSprite, 0.3, 0.4, rotate: true);
      //   _drawSprite(canvas, suitSprite, 0.7, 0.4, rotate: true);
      //   break;
      // case 10:
      //   _drawSprite(canvas, suitSprite, 0.3, 0.2);
      //   _drawSprite(canvas, suitSprite, 0.7, 0.2);
      //   _drawSprite(canvas, suitSprite, 0.5, 0.3);
      //   _drawSprite(canvas, suitSprite, 0.3, 0.4);
      //   _drawSprite(canvas, suitSprite, 0.7, 0.4);
      //   _drawSprite(canvas, suitSprite, 0.3, 0.2, rotate: true);
      //   _drawSprite(canvas, suitSprite, 0.7, 0.2, rotate: true);
      //   _drawSprite(canvas, suitSprite, 0.5, 0.3, rotate: true);
      //   _drawSprite(canvas, suitSprite, 0.3, 0.4, rotate: true);
      //   _drawSprite(canvas, suitSprite, 0.7, 0.4, rotate: true);
      //   break;
      case 8:
        _drawSprite(canvas, suit.isRed ? redJack : blackJack, 0.5, 0.5);
        break;
      case 9:
        _drawSprite(canvas, suit.isRed ? redQueen : blackQueen, 0.5, 0.5);
        break;
      case 10:
        _drawSprite(canvas, suit.isRed ? redKing : blackKing, 0.5, 0.5);
        break;
    }
  }

  void _renderBack(Canvas canvas) {
    canvas.drawRRect(cardRRect, backBackgroundPaint);
    canvas.drawRRect(cardRRect, backBorderPaint1);
    canvas.drawRRect(backRRectInner, backBorderPaint2);
    flameSprite.render(canvas, position: size / 2, anchor: Anchor.center);
  }

  void _drawSprite(
    Canvas canvas,
    Sprite sprite,
    double relativeX,
    double relativeY, {
    double scale = 1,
    bool rotate = false,
  }) {
    if (rotate) {
      canvas.save();
      canvas.translate(size.x / 2, size.y / 2);
      canvas.rotate(pi);
      canvas.translate(-size.x / 2, -size.y / 2);
    }
    sprite.render(
      canvas,
      position: Vector2(relativeX * size.x, relativeY * size.y),
      anchor: Anchor.center,
      size: sprite.srcSize.scaled(scale),
    );
    if (rotate) {
      canvas.restore();
    }
  }

  @override
  bool onTapDown(TapDownEvent event) {
    gameRef.onCardTap(this);
    return true;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Card &&
          runtimeType == other.runtimeType &&
          suit == other.suit &&
          rank == other.rank;

  @override
  int get hashCode => suit.hashCode + rank.hashCode;
}
