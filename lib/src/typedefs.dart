part of 'card_swiper.dart';

typedef CardSwiperOnSwipe = void Function(
  int index,
  CardSwiperDirection direction,
);

typedef CardSwiperOnEnd = void Function();

typedef CardSwiperOnTapDisabled = void Function();

typedef CardSwiperCardBuilder = Widget Function(
  BuildContext context,
  Widget child,
);

typedef CardSwiperItemBuilder = Widget Function(
  BuildContext context,
  ItemSwipeProperties swipeProperty,
);

/// Builder for displaying an overlay on the most foreground card.
typedef CardSwiperOverlayBuilder = Widget Function(
  BuildContext context,
  OverlaySwipeProperties swipeProperty,
);
