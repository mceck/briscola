import 'package:briscola/models/sprites.dart';
import 'package:flame/components.dart';
import 'package:flutter/foundation.dart';

@immutable
class Rank {
  final int value;
  final String label;
  final Sprite redSprite;
  final Sprite blackSprite;
  final int points;

  static late final List<Rank> _singletons = [
    Rank._(1, 'A', 11, 335, 164, 789, 161, 120, 129),
    Rank._(2, '2', 0, 20, 19, 15, 322, 83, 125),
    Rank._(3, '3', 10, 122, 19, 117, 322, 80, 127),
    Rank._(4, '4', 0, 213, 12, 208, 315, 93, 132),
    Rank._(5, '5', 0, 314, 21, 309, 324, 85, 125),
    Rank._(6, '6', 0, 419, 17, 414, 320, 84, 129),
    Rank._(7, '7', 0, 509, 21, 505, 324, 92, 128),
    // Rank._(8, '8', 612, 19, 607, 322, 78, 127),
    // Rank._(9, '9', 709, 19, 704, 322, 84, 130),
    // Rank._(10, '10', 810, 20, 805, 322, 137, 127),
    Rank._(8, 'J', 2, 15, 170, 469, 167, 56, 126),
    Rank._(9, 'Q', 3, 92, 168, 547, 165, 132, 128),
    Rank._(10, 'K', 4, 243, 170, 696, 167, 92, 123),
  ];

  factory Rank.fromInt(int value) {
    assert(value >= 1 && value <= 10);
    return _singletons[value - 1];
  }

  Rank._(
    this.value,
    this.label,
    this.points,
    double x1,
    double y1,
    double x2,
    double y2,
    double w,
    double h,
  )   : redSprite = CardSprites.getSprite(x1, y1, w, h),
        blackSprite = CardSprites.getSprite(x2, y2, w, h);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Rank && runtimeType == other.runtimeType && value == other.value;

  @override
  int get hashCode => value.hashCode;
}
