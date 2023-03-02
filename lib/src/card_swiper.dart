import 'dart:async';
import 'dart:math';
import 'package:flip_card/flip_card.dart';
import 'package:flip_card/flip_card_controller.dart';
import 'package:flutter/widgets.dart';

part 'card_swiper_controller.dart';
part 'enums.dart';
part 'swipe_properties.dart';
part 'typedefs.dart';

class CardSwiper<T extends Widget> extends StatefulWidget {
  /// list of widgets for the swiper
  // final List<T> cards;

  /// controller to trigger actions
  final CardSwiperController controller;

  /// duration of every animation
  final Duration duration;

  /// padding of the swiper
  final EdgeInsetsGeometry padding;

  /// maximum angle the card reaches while swiping
  final double maxAngle;

  /// threshold from which the card is swiped away
  final int threshold;

  /// scale of the card that is behind the front card
  // final double scale;

  /// set to true if swiping should be disabled, exception: triggered from the outside
  final bool isDisabled;

  /// function that gets called with the new index and detected swipe direction when the user swiped or swipe is triggered by controller
  final CardSwiperOnSwipe? onSwipe;

  /// function that gets called when there is no widget left to be swiped away
  final CardSwiperOnEnd? onEnd;

  final int itemCount;

  final CardSwiperItemBuilder itemBuilder;
  final Widget Function(BuildContext context, int index) detailsBuilder;

  // final CardSwiperCardBuilder cardBuilder;

  // final CardSwiperOverlayBuilder? overlayBuilder;

  final Function()? onTap;

  /// function that gets triggered when the swiper is disabled
  final CardSwiperOnTapDisabled? onTapDisabled;

  /// direction in which the card gets swiped when triggered by controller, default set to right
  final CardSwiperDirection direction;

  const CardSwiper({
    Key? key,
    // required this.cards,
    required this.itemCount,
    required this.itemBuilder,
    required this.detailsBuilder,
    required this.controller,
    this.padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
    this.duration = const Duration(milliseconds: 200),
    this.maxAngle = 30,
    this.threshold = 175,
    this.isDisabled = false,
    this.onTap,
    this.onTapDisabled,
    this.onSwipe,
    this.onEnd,
    this.direction = CardSwiperDirection.right,
  })  : assert(
          maxAngle >= 0 && maxAngle <= 360,
          'maxAngle must be between 0 and 360',
        ),
        assert(
          threshold >= 1 && threshold <= 200,
          'threshold must be between 1 and 200',
        ),
        assert(
          direction != CardSwiperDirection.none,
          'direction must not be none',
        ),
        super(key: key);

  @override
  State createState() => _CardSwiperState<T>();
}

class _CardSwiperState<T extends Widget> extends State<CardSwiper<T>>
    with SingleTickerProviderStateMixin {
  double _left = 0;
  double _top = 0;
  double _total = 0;
  double _angle = 0;
  final double _initialScale = 0.9;
  late double _scale = _initialScale;
  final double _initialDifference = 50;
  late double _difference = _initialDifference;
  double _progress = 0;

  SwipeType _swipeType = SwipeType.none;
  bool _tapOnTop = false; //position of starting drag point on card

  late AnimationController _animationController;
  late Animation<double> _leftAnimation;
  late Animation<double> _topAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _differenceAnimation;

  final flipController = FlipCardController();

  CardSwiperDirection detectedDirection = CardSwiperDirection.none;

  double get _maxAngle => widget.maxAngle * (pi / 180);

  int get _currentIndex => widget.controller.currentIndex;
  bool get _isFinished => _currentIndex == widget.itemCount;
  bool get _canSwipe => _currentIndex <= widget.itemCount && !widget.isDisabled;
  bool get _hasFrontItem => _currentIndex < widget.itemCount;
  bool get _hasMiddleItem => _currentIndex + 1 < widget.itemCount;
  bool get _hasBackItem => _currentIndex + 2 < widget.itemCount;
  bool get _hasHiddenItem => _currentIndex + 3 < widget.itemCount;

  @override
  void initState() {
    super.initState();

    widget.controller.addListener(_controllerListener);

    if (!_canSwipe) {
      widget.controller.enabled = false;
    }

    _animationController = AnimationController(
      duration: widget.duration,
      vsync: this,
    )
      ..addListener(_animationListener)
      ..addStatusListener(_animationStatusListener);
  }

  @override
  void dispose() {
    super.dispose();
    _animationController.dispose();
    widget.controller.removeListener(_controllerListener);
    widget.controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Padding(
          padding: widget.padding,
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              return Stack(
                clipBehavior: Clip.none,
                fit: StackFit.expand,
                alignment: AlignmentDirectional.topCenter,
                children: [
                  if (_hasHiddenItem) _hiddenItem(constraints),
                  if (_hasBackItem) _backItem(constraints),
                  if (_hasMiddleItem) _middleItem(constraints),
                  if (_hasFrontItem) _frontItem(constraints),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _cardBox({
    required BoxConstraints constraints,
    required Widget child,
  }) {
    return SizedBox(
      width: constraints.maxWidth,
      height: constraints.maxHeight - 50,
      child: child,
    );
  }

  Widget _frontItem(BoxConstraints constraints) {
    return Positioned(
      top: _top,
      left: _left,
      child: GestureDetector(
        onTap: () {
          unawaited(flipController.toggleCard());

          if (widget.isDisabled) {
            widget.onTapDisabled?.call();
          } else {
            widget.onTap?.call();
          }
        },
        onPanStart: (tapInfo) {
          if (!widget.isDisabled) {
            final renderBox = context.findRenderObject()! as RenderBox;
            final position = renderBox.globalToLocal(tapInfo.globalPosition);

            if (position.dy < (renderBox.size.height / 3) * 2) _tapOnTop = true;
          }
        },
        onPanUpdate: (tapInfo) {
          if (!widget.isDisabled) {
            setState(() {
              _left += tapInfo.delta.dx;
              _top += tapInfo.delta.dy;
              _total = _left + _top;
              _calculateAngle();
              _calculateScale();
              _calculateDifference();
              _calculateDirection();
              _calculateProgress();
            });
          }
        },
        onPanEnd: (tapInfo) {
          if (_canSwipe) {
            flipController.toggleCardWithoutAnimation();
            _tapOnTop = false;
            _onEndAnimation();
            _animationController.forward();
          }
        },
        child: Transform.rotate(
          angle: _angle,
          child: _cardBox(
            constraints: constraints,
            child: FlipCard(
              flipOnTouch: false,
              controller: flipController,
              front: widget.itemBuilder(
                context,
                ItemSwipeProperties(
                  index: 0,
                  stackIndex: _currentIndex,
                  constraints: constraints,
                  direction: detectedDirection,
                  swipeProgress: _progress,
                ),
              ),
              back: widget.detailsBuilder(context, _currentIndex),
            ),
          ),
        ),
      ),
    );
  }

  Widget _middleItem(BoxConstraints constraints) {
    return Positioned(
      top: _difference,
      left: 0,
      child: Transform.scale(
        origin: const Offset(0.5, 1.0),
        scale: _scale,
        child: _cardBox(
          constraints: constraints,
          child: widget.itemBuilder(
            context,
            ItemSwipeProperties(
              index: 1,
              stackIndex: _currentIndex + 1,
              constraints: constraints,
              direction: detectedDirection,
              swipeProgress: _progress,
            ),
          ),
        ),
      ),
    );
  }

  Widget _backItem(BoxConstraints constraints) {
    return Positioned(
      top: _difference + (_initialDifference * _initialScale),
      left: 0,
      child: Transform.scale(
        origin: const Offset(0.5, 1.0),
        scale: _scale * _initialScale,
        child: _cardBox(
          constraints: constraints,
          child: widget.itemBuilder(
            context,
            ItemSwipeProperties(
              index: 2,
              stackIndex: _currentIndex + 2,
              constraints: constraints,
              direction: detectedDirection,
              swipeProgress: _progress,
            ),
          ),
        ),
      ),
    );
  }

  Widget _hiddenItem(BoxConstraints constraints) {
    final opacity = (_initialDifference - _difference) / _initialDifference;
    return Positioned(
      top: _initialDifference + (_initialDifference * _initialScale),
      left: 0,
      child: Opacity(
        opacity: opacity.clamp(0, 1),
        child: Transform.scale(
          origin: const Offset(0.5, 1.0),
          scale: _initialScale * _initialScale,
          child: _cardBox(
            constraints: constraints,
            child: widget.itemBuilder(
              context,
              ItemSwipeProperties(
                index: 3,
                stackIndex: _currentIndex + 3,
                constraints: constraints,
                direction: detectedDirection,
                swipeProgress: _progress,
              ),
            ),
          ),
        ),
      ),
    );
  }

  //swipe widget from the outside
  void _controllerListener() {
    switch (widget.controller.state) {
      case CardSwiperState.swipe:
        _swipe(context, widget.direction);
        break;
      case CardSwiperState.swipeLeft:
        _swipe(context, CardSwiperDirection.left);
        break;
      case CardSwiperState.swipeRight:
        _swipe(context, CardSwiperDirection.right);
        break;
      case CardSwiperState.swipeTop:
        _swipe(context, CardSwiperDirection.top);
        break;
      case CardSwiperState.swipeBottom:
        _swipe(context, CardSwiperDirection.bottom);
        break;
      default:
        break;
    }
  }

  //when value of controller changes
  void _animationListener() {
    if (_animationController.status == AnimationStatus.forward) {
      setState(() {
        _left = _leftAnimation.value;
        _top = _topAnimation.value;
        _scale = _scaleAnimation.value;
        _difference = _differenceAnimation.value;
      });
    }
  }

  //when the status of animation changes
  void _animationStatusListener(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      setState(() {
        if (_swipeType == SwipeType.swipe) {
          widget.onSwipe?.call(_currentIndex, detectedDirection);
          widget.controller.currentIndex = _currentIndex + 1;
          if (_currentIndex >= widget.itemCount) {
            widget.controller.enabled = false;
          }

          if (_isFinished) {
            widget.onEnd?.call();
          }
        }
        _animationController.reset();
        _left = 0;
        _top = 0;
        _total = 0;
        _angle = 0;
        _progress = 0;
        detectedDirection = CardSwiperDirection.none;
        _scale = _initialScale;
        _difference = _initialDifference;
        _swipeType = SwipeType.none;
      });
    }
  }

  void _calculateAngle() {
    if (_angle <= _maxAngle && _angle >= -_maxAngle) {
      _angle = (_maxAngle / 100) * (_left / 10);
      if (!_tapOnTop) _angle *= -1;
    }
  }

  void _calculateScale() {
    if (_scale <= 1.0 && _scale >= _initialScale) {
      _scale = (_total > 0)
          ? _initialScale + (_total / 5000)
          : _initialScale + -1 * (_total / 5000);
    }
  }

  void _calculateDifference() {
    if (_difference >= 0 && _difference <= _difference) {
      _difference = (_total > 0)
          ? _initialDifference - (_total / 10)
          : _initialDifference + (_total / 10);
    }
  }

  void _calculateDirection() {
    if (widget.controller.enabledDirections.contains(CardSwiperDirection.top) &&
        _top < -40 &&
        _top.abs() > _left.abs()) {
      detectedDirection = CardSwiperDirection.top;
    } else if (widget.controller.enabledDirections
            .contains(CardSwiperDirection.bottom) &&
        _top > 40 &&
        _top.abs() > _left.abs()) {
      detectedDirection = CardSwiperDirection.bottom;
    } else if (widget.controller.enabledDirections
            .contains(CardSwiperDirection.right) &&
        _left > 10 &&
        _left.abs() > _top.abs()) {
      detectedDirection = CardSwiperDirection.right;
    } else if (widget.controller.enabledDirections
            .contains(CardSwiperDirection.left) &&
        _left < -10 &&
        _left.abs() > _top.abs()) {
      detectedDirection = CardSwiperDirection.left;
    } else {
      detectedDirection = CardSwiperDirection.none;
    }
  }

  void _calculateProgress() {
    switch (detectedDirection) {
      case CardSwiperDirection.top:
        _progress = _top / -widget.threshold;
        break;
      case CardSwiperDirection.bottom:
        _progress = _top / widget.threshold;
        break;
      case CardSwiperDirection.right:
        _progress = _left / widget.threshold;
        break;
      case CardSwiperDirection.left:
        _progress = _left / -widget.threshold;
        break;
      case CardSwiperDirection.none:
        _progress = 0;
        break;
    }
  }

  void _onEndAnimation() {
    if (_left < -widget.threshold &&
            widget.controller.enabledDirections
                .contains(CardSwiperDirection.left) ||
        _left > widget.threshold &&
            widget.controller.enabledDirections
                .contains(CardSwiperDirection.right)) {
      _swipeHorizontal(context);
    } else if (_top < -widget.threshold &&
            widget.controller.enabledDirections
                .contains(CardSwiperDirection.top) ||
        _top > widget.threshold &&
            widget.controller.enabledDirections
                .contains(CardSwiperDirection.bottom)) {
      _swipeVertical(context);
    } else {
      _goBack(context);
    }
  }

  void _swipe(BuildContext context, CardSwiperDirection direction) {
    if (!_canSwipe ||
        !widget.controller.enabledDirections.contains(direction)) {
      return;
    }

    switch (direction) {
      case CardSwiperDirection.left:
        _left = -1;
        _swipeHorizontal(context);
        break;
      case CardSwiperDirection.right:
        _left = widget.threshold + 1;
        _swipeHorizontal(context);
        break;
      case CardSwiperDirection.top:
        _top = -1;
        _swipeVertical(context);
        break;
      case CardSwiperDirection.bottom:
        _top = widget.threshold + 1;
        _swipeVertical(context);
        break;
      default:
        break;
    }
    _animationController.forward();
  }

  //moves the card away to the left or right
  void _swipeHorizontal(BuildContext context) {
    _leftAnimation = Tween<double>(
      begin: _left,
      end: (_left == 0 && widget.direction == CardSwiperDirection.right) ||
              _left > widget.threshold
          ? MediaQuery.of(context).size.width
          : -MediaQuery.of(context).size.width,
    ).animate(_animationController);
    _topAnimation = Tween<double>(
      begin: _top,
      end: _top + _top,
    ).animate(_animationController);
    _scaleAnimation = Tween<double>(
      begin: _scale,
      end: 1.0,
    ).animate(_animationController);
    _differenceAnimation = Tween<double>(
      begin: _difference,
      end: 0,
    ).animate(_animationController);

    _swipeType = SwipeType.swipe;
    if (_left > widget.threshold ||
        _left == 0 && widget.direction == CardSwiperDirection.right) {
      detectedDirection = CardSwiperDirection.right;
    } else {
      detectedDirection = CardSwiperDirection.left;
    }
  }

  //moves the card away to the top or bottom
  void _swipeVertical(BuildContext context) {
    _leftAnimation = Tween<double>(
      begin: _left,
      end: _left + _left,
    ).animate(_animationController);
    _topAnimation = Tween<double>(
      begin: _top,
      end: (_top == 0 && widget.direction == CardSwiperDirection.bottom) ||
              _top > widget.threshold
          ? MediaQuery.of(context).size.height
          : -MediaQuery.of(context).size.height,
    ).animate(_animationController);
    _scaleAnimation = Tween<double>(
      begin: _scale,
      end: 1.0,
    ).animate(_animationController);
    _differenceAnimation = Tween<double>(
      begin: _difference,
      end: 0,
    ).animate(_animationController);

    _swipeType = SwipeType.swipe;
    if (_top > widget.threshold ||
        _top == 0 && widget.direction == CardSwiperDirection.bottom) {
      detectedDirection = CardSwiperDirection.bottom;
    } else {
      detectedDirection = CardSwiperDirection.top;
    }
  }

  //moves the card back to starting position
  void _goBack(BuildContext context) {
    _leftAnimation = Tween<double>(
      begin: _left,
      end: 0,
    ).animate(_animationController);
    _topAnimation = Tween<double>(
      begin: _top,
      end: 0,
    ).animate(_animationController);
    _scaleAnimation = Tween<double>(
      begin: _scale,
      end: _initialScale,
    ).animate(_animationController);
    _differenceAnimation = Tween<double>(
      begin: _difference,
      end: _initialDifference,
    ).animate(_animationController);

    _swipeType = SwipeType.back;
  }
}
