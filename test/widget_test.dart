// This is a basic Flutter widget test.
// To perform an interaction with a widget in your test, use the WidgetTester utility that Flutter
// provides. For example, you can send tap and scroll gestures. You can also use WidgetTester to
// find child widgets in the widget tree, read text, and verify that the values of widget properties
// are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('my first widget test', (WidgetTester tester) async {
    // you can use keys to locale the widget you need to test
    var sliderKey = UniqueKey();
    var value = 0.0;
    // Tells the tester to build a UI based on the widget tree passed to it.
    await tester.pumpWidget(
      StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
        return MaterialApp(
          home: Material(
            child: Center(
              child: Slider(
                key: sliderKey,
                value: value,
                onChanged: (double newValue) {
                  setState(() {
                    value = newValue;
                  });
                },
              ),
            ),
          ),
        );
      }),
    );
    expect(value, equals(0.0));

    await tester.tap(find.byKey(sliderKey));
    expect(value, equals(0.5));
  });
}
