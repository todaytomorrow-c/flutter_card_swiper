// import 'package:example/card_label.dart';
import 'package:example/example_candidate_model.dart';
import 'package:example/example_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';

void main() {
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Example(),
    ),
  );
}

class Example extends StatefulWidget {
  const Example({
    Key? key,
  }) : super(key: key);

  @override
  State<Example> createState() => _ExamplePageState();
}

class _ExamplePageState extends State<Example> {
  final CardSwiperController controller = CardSwiperController(
    enabledDirections: const [
      CardSwiperDirection.top,
      CardSwiperDirection.left,
      CardSwiperDirection.right
    ],
  );

  final cards = candidates
      .map((candidate) => ExampleCardContainer(child: ExampleCard(candidate)))
      .toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Flexible(
              child: CardSwiper(
                controller: controller,
                onSwipe: _swipe,
                padding: const EdgeInsets.all(8.0),
                itemCount: candidates.length,
                itemBuilder: (context, properties) {
                  return ExampleCardContainer(
                    child: ExampleCard(candidates[properties.stackIndex]),
                  );
                },
                detailsBuilder: (context, index) {
                  return ExampleCardContainer(
                    child: SizedBox.expand(
                      child: ColoredBox(
                        color: Colors.amber,
                        child: Text(candidates[index].name),
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // FloatingActionButton(
                  //   onPressed: controller.swipe,
                  //   child: const Icon(Icons.rotate_right),
                  // ),
                  FloatingActionButton(
                    onPressed: controller.enabledDirections
                            .contains(CardSwiperDirection.left)
                        ? controller.swipeLeft
                        : null,
                    child: const Icon(Icons.keyboard_arrow_left),
                  ),
                  FloatingActionButton(
                    onPressed: controller.enabledDirections
                            .contains(CardSwiperDirection.right)
                        ? controller.swipeRight
                        : null,
                    child: const Icon(Icons.keyboard_arrow_right),
                  ),
                  FloatingActionButton(
                    onPressed: controller.enabledDirections
                            .contains(CardSwiperDirection.top)
                        ? controller.swipeTop
                        : null,
                    child: const Icon(Icons.keyboard_arrow_up),
                  ),
                  FloatingActionButton(
                    disabledElevation: 0,
                    backgroundColor: Colors.amberAccent,
                    onPressed: controller.enabledDirections
                            .contains(CardSwiperDirection.bottom)
                        ? controller.swipeBottom
                        : null,
                    child: const Icon(Icons.keyboard_arrow_down),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  void _swipe(int index, CardSwiperDirection direction) {
    debugPrint('the card $index was swiped to the: ${direction.name}');
  }
}
