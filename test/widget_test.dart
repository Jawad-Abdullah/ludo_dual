import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ludo/main.dart';

void main() {
  testWidgets('shows the two-player board and starts a dice roll',
      (tester) async {
    await tester.pumpWidget(const LudoApp());

    expect(find.text('LUDO DUEL'), findsOneWidget);
    expect(find.text('Red'), findsOneWidget);
    expect(find.text('Green'), findsOneWidget);
    expect(find.text('Roll the dice to begin.'), findsOneWidget);

    final dice = find.byKey(const ValueKey('dice-value'));
    expect(dice, findsOneWidget);
    expect(tester.getRect(dice).bottom, lessThanOrEqualTo(600));
    expect(find.text('9'), findsNothing);

    final rollButton = find.byKey(const ValueKey('roll-button'));
    await tester.tap(rollButton);
    await tester.pump(const Duration(milliseconds: 700));

    expect(find.text('Rolling the dice...'), findsNothing);

    final restartButton = find.byKey(const ValueKey('restart-button'));
    await tester.tap(restartButton);
    await tester.pump();
    expect(find.text('Roll the dice to begin.'), findsOneWidget);
  });
}
