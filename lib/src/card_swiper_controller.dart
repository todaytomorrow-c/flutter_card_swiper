part of 'card_swiper.dart';

//to call the swipe function from outside of the CardSwiper
class CardSwiperController extends ChangeNotifier {
  CardSwiperController({
    List<CardSwiperDirection> enabledDirections = const [
      CardSwiperDirection.left,
      CardSwiperDirection.top,
      CardSwiperDirection.right,
      CardSwiperDirection.bottom
    ],
    int initialIndex = 0,
  })  : _currentIndex = initialIndex,
        _enabledDirections = enabledDirections,
        assert(
          initialIndex >= 0,
          'initialIndex must be non-null and equal to or greater than 0',
        );

  int _currentIndex;
  bool _enabled = true;
  final List<CardSwiperDirection> _enabledDirections;

  /// The [CardSwiperDirection]s a user is allowed to swipe in.
  List<CardSwiperDirection> get enabledDirections => _enabledDirections;

  bool get enabledVerticalSwipe =>
      _enabledDirections.contains(CardSwiperDirection.top) &&
      _enabledDirections.contains(CardSwiperDirection.bottom);

  bool get enabledHorizontalSwipe =>
      _enabledDirections.contains(CardSwiperDirection.left) &&
      _enabledDirections.contains(CardSwiperDirection.left);

  /// Current index of [CardSwiper].
  int get currentIndex => _currentIndex;

  bool get enabled => _enabled;

  set enabled(bool value) {
    _enabled = value;
    notifyListeners();
  }

  set currentIndex(int newValue) {
    if (_currentIndex == newValue) {
      return;
    }
    _currentIndex = newValue;
    notifyListeners();
  }

  CardSwiperState? state;

  //swipe the card by changing the status of the controller
  void swipe() {
    state = CardSwiperState.swipe;
    notifyListeners();
  }

  //swipe the card to the left side by changing the status of the controller
  void swipeLeft() {
    state = CardSwiperState.swipeLeft;
    notifyListeners();
  }

  //swipe the card to the right side by changing the status of the controller
  void swipeRight() {
    state = CardSwiperState.swipeRight;
    notifyListeners();
  }

  //swipe the card to the top side by changing the status of the controller
  void swipeTop() {
    state = CardSwiperState.swipeTop;
    notifyListeners();
  }

  //swipe the card to the bottom side by changing the status of the controller
  void swipeBottom() {
    state = CardSwiperState.swipeBottom;
    notifyListeners();
  }
}
