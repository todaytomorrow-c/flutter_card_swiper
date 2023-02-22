import 'package:flutter/widgets.dart';
import 'package:flutter_card_swiper/src/enums.dart';

import 'model_properties.dart';

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

/// Builder for displaying an overlay on the most foreground card.
typedef CardSwiperOverlayBuilder = Widget Function(
  BuildContext context,
  OverlaySwipeProperties swipeProperty,
);
