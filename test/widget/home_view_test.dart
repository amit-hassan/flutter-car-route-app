import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Button tap updates the text', (WidgetTester tester) async {
    // A simple widget with a button that changes text
    String textValue = 'Before Tap';

    await tester.pumpWidget(MaterialApp(
      home: StatefulBuilder(
        builder: (context, setState) => Scaffold(
          body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(textValue, textDirection: TextDirection.ltr),
              ElevatedButton(
                onPressed: () => setState(() => textValue = 'After Tap'),
                child: const Text('Tap Me'),
              ),
            ],
          ),
        ),
      ),
    ));

    // Initially "Before Tap" should be visible
    expect(find.text('Before Tap'), findsOneWidget);
    expect(find.text('After Tap'), findsNothing);

    // Tap the button
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump(); // Rebuilds the widget

    // Verify the text changes
    expect(find.text('After Tap'), findsOneWidget);
  });
}
