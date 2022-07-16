import 'package:briscola/models/sprites.dart';
import 'package:flame/components.dart';
import 'package:flutter/foundation.dart';

@immutable
class Suit {
  final int value;
  final String label;
  final Sprite sprite;

  static late final List<Suit> _singletons = [
    Suit._(0, '♥', 1176, 17, 172, 183),
    Suit._(1, '♦', 973, 14, 177, 182),
    Suit._(2, '♣', 974, 226, 184, 172),
    Suit._(3, '♠', 1178, 220, 176, 182),
  ];

  Suit._(this.value, this.label, double x, double y, double w, double h)
      : sprite = CardSprites.getSprite(x, y, w, h);

  factory Suit.fromInt(int index) {
    assert(index >= 0 && index <= 3);
    return _singletons[index];
  }

  bool get isRed => value <= 1;
  bool get isBlack => value >= 2;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Suit && runtimeType == other.runtimeType && value == other.value;

  @override
  int get hashCode => value.hashCode;
}
