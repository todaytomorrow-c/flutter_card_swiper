import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';

const _labelAngle = math.pi / 2 * 0.2;

class CardLabel extends StatelessWidget {
  const CardLabel._({
    required this.color,
    required this.label,
    required this.angle,
    required this.alignment,
    this.opacity = 1,
  });

  factory CardLabel.right() {
    return const CardLabel._(
      color: Colors.green,
      label: 'RIGHT',
      angle: -_labelAngle,
      alignment: Alignment.topLeft,
    );
  }

  factory CardLabel.left() {
    return const CardLabel._(
      color: Colors.redAccent,
      label: 'LEFT',
      angle: _labelAngle,
      alignment: Alignment.topRight,
    );
  }

  factory CardLabel.up() {
    return const CardLabel._(
      color: Colors.blueAccent,
      label: 'UP',
      angle: _labelAngle,
      alignment: Alignment(0, 0.5),
    );
  }

  factory CardLabel.down() {
    return const CardLabel._(
      color: Colors.grey,
      label: 'DOWN',
      angle: -_labelAngle,
      alignment: Alignment(0, -0.75),
    );
  }

  factory CardLabel.none() {
    return const CardLabel._(
      color: Colors.transparent,
      label: 'KAAS',
      angle: 0,
      alignment: Alignment(0.5, 0.5),
      opacity: 0,
    );
  }

  factory CardLabel.forDirection(CardSwiperDirection direction) {
    switch (direction) {
      case CardSwiperDirection.right:
        return CardLabel.right();
      case CardSwiperDirection.left:
        return CardLabel.left();
      case CardSwiperDirection.top:
        return CardLabel.up();
      case CardSwiperDirection.bottom:
        return CardLabel.down();
      case CardSwiperDirection.none:
        return CardLabel.none();
    }
  }

  final Color color;
  final String label;
  final double angle;
  final Alignment alignment;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    final element = Container(
      alignment: alignment,
      padding: const EdgeInsets.symmetric(
        vertical: 36,
        horizontal: 36,
      ),
      child: Transform.rotate(
        angle: angle,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: color,
              width: 4,
            ),
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
          ),
          padding: const EdgeInsets.all(6),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.4,
              color: color,
              height: 1,
            ),
          ),
        ),
      ),
    );

    if (opacity < 1) {
      return Opacity(
        opacity: opacity,
        child: element,
      );
    }

    return element;
  }
}
