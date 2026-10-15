import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:zing/features/home/presentation/home_screen.dart';

import '../../helpers/pump_app.dart';

void main() {
  /// Home with stub destinations so navigation can be asserted by location.
  Future<void> open(
    WidgetTester tester, {
    DateTime? now,
    String? userName,
    String? signedInAs,
  }) => pumpZing(
    tester,
    logicalSize: const Size(390, 1100),
    signedInAs: signedInAs,
    router: GoRouter(
      initialLocation: '/home',
      routes: [
        GoRoute(
          path: '/home',
          builder: (_, _) => HomeScreen(
            userName: userName,
            now: now ?? DateTime(2026, 10, 15, 9),
          ),
        ),
        for (final p in [
          '/add-material',
          '/library',
          '/profile',
          '/material/:id',
          '/flashcards/:id',
          '/quiz/:id',
        ])
          stubRoute(p),
      ],
    ),
  );

  testWidgets('greets the signed-in user by first name', (tester) async {
    await open(tester, signedInAs: 'Alex Morgan');

    expect(find.text('Good morning'), findsOneWidget);
    expect(find.text('Alex'), findsOneWidget);
    expect(find.text('A'), findsOneWidget); // avatar initial
  });

  testWidgets('falls back to "there" with no name', (tester) async {
    await open(tester);

    expect(find.text('there'), findsOneWidget);
  });

  testWidgets('userName overrides the session name', (tester) async {
    await open(tester, userName: 'Sam', signedInAs: 'Alex Morgan');

    expect(find.text('Sam'), findsOneWidget);
    expect(find.text('Alex'), findsNothing);
  });

  for (final c in [
    (DateTime(2026, 10, 15, 8), 'Good morning'),
    (DateTime(2026, 10, 15, 14), 'Good afternoon'),
    (DateTime(2026, 10, 15, 20), 'Good evening'),
  ]) {
    testWidgets('greeting at ${c.$1.hour}:00 is "${c.$2}"', (tester) async {
      await open(tester, now: c.$1);

      expect(find.text(c.$2), findsOneWidget);
    });
  }

  testWidgets('shows the streak pill and stat tiles', (tester) async {
    await open(tester);

    expect(find.text('7 days'), findsOneWidget);
    expect(find.text('12h'), findsOneWidget);
    expect(find.text('This month'), findsOneWidget);
    expect(find.text('82%'), findsOneWidget);
    expect(find.text('Quiz avg'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
    expect(find.text('Due today'), findsOneWidget);
  });

  testWidgets('continue card features the first material with flashcards', (
    tester,
  ) async {
    await open(tester);

    expect(find.text('CONTINUE STUDYING'), findsOneWidget);
    expect(find.text('Flashcards · 14 of 24 done'), findsOneWidget);
    // Continue card + the matching recent tile.
    expect(find.text('Cell Biology · Chapter 4'), findsNWidgets(2));
  });

  testWidgets('lists only the three most recent materials', (tester) async {
    await open(tester);

    expect(find.text('Recent'), findsOneWidget);
    expect(find.text('Organic Chemistry Notes'), findsOneWidget);
    expect(find.text('Python Basics'), findsOneWidget);
    expect(find.text('Calculus Limits'), findsNothing);
    expect(find.text('Ready'), findsNWidgets(3));
  });

  testWidgets('Resume opens the flashcards for that material', (tester) async {
    await open(tester);

    await tapText(tester, 'Resume');

    expect(find.text('stub:/flashcards/cell-biology'), findsOneWidget);
  });

  for (final c in [
    ('Summarize', '/material/cell-biology'),
    ('Flashcards', '/flashcards/cell-biology'),
    ('Quiz', '/quiz/cell-biology'),
  ]) {
    testWidgets('quick action ${c.$1} opens ${c.$2}', (tester) async {
      await open(tester);

      await tapText(tester, c.$1);

      expect(find.text('stub:${c.$2}'), findsOneWidget);
    });
  }

  testWidgets('tapping a recent material opens its detail', (tester) async {
    await open(tester);

    await tapText(tester, 'Python Basics');

    expect(find.text('stub:/material/python-basics'), findsOneWidget);
  });

  testWidgets('See all goes to the library', (tester) async {
    await open(tester);

    await tapText(tester, 'See all');

    expect(find.text('stub:/library'), findsOneWidget);
  });

  testWidgets('the avatar opens the profile', (tester) async {
    await open(tester);

    await tester.tap(find.byType(CircleAvatar));
    await tester.pumpAndSettle();

    expect(find.text('stub:/profile'), findsOneWidget);
  });

  testWidgets('Add material button opens the import screen', (tester) async {
    await open(tester);

    await tapText(tester, 'Add material');

    expect(find.text('stub:/add-material'), findsOneWidget);
  });
}
