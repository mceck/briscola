import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class ScoreText extends PositionComponent {
  final _paint = TextPaint(
    style: const TextStyle(
      fontSize: 1000,
      color: Color(0xffffffff),
      fontWeight: FontWeight.bold,
      backgroundColor: Color(0x50000000),
    ),
  );

  String _text = '';
  bool _show = false;

  ScoreText({super.position}) : super(priority: 9999);

  @override
  void render(Canvas canvas) {
    if (_show) {
      _paint.render(canvas, _text, position);
    }
  }

  void show(String text) async {
    _show = true;
    _text = text;
  }

  void hide() {
    _text = '';
    _show = false;
  }
}
