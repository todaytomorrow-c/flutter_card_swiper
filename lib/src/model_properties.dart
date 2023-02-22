part of 'card_swiper.dart';

abstract class SwipeProperties {
  const SwipeProperties({
    required this.index,
    required this.constraints,
    required this.direction,
    required this.swipeProgress,
  });

  ///Index of the current item.
  final int index;

  ///[Constraints] of the whole stack.
  final BoxConstraints constraints;

  ///Direction of the current swipe action.
  final CardSwiperDirection? direction;

  ///Progress of the current swipe action.
  final double swipeProgress;
}

class OverlaySwipeProperties extends SwipeProperties {
  const OverlaySwipeProperties({
    required int index,
    required BoxConstraints constraints,
    required CardSwiperDirection direction,
    required double swipeProgress,
  }) : super(
          index: index,
          constraints: constraints,
          direction: direction,
          swipeProgress: swipeProgress,
        );

  ///Direction of the current swipe action.
  @override
  CardSwiperDirection get direction => super.direction!;
}
