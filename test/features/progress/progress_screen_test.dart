import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zing/features/progress/presentation/progress_screen.dart';

import '../../helpers/pump_app.dart';

void main() {
  Future<void> open(WidgetTester tester) =>
      pumpZing(tester, location: '/progress');

  Finder inProgress(Finder f) => inScreen<ProgressScreen>(f);

  testWidgets('shows the headline metrics', (tester) async {
    await open(tester);

    expect(inProgress(find.text('Progress')), findsOneWidget);
    expect(find.text('Study time'), findsOneWidget);
    expect(find.text('12h 40m'), findsOneWidget);
    expect(find.text('Avg quiz score'), findsOneWidget);
    expect(find.text('82%'), findsOneWidget);
    expect(find.text('Current streak'), findsOneWidget);
    expect(find.text('7 days'), findsOneWidget);
    expect(find.text('Longest streak'), findsOneWidget);
    expect(find.text('21 days'), findsOneWidget);
  });

  testWidgets('weekly chart has a bar and label for every day', (tester) async {
    final semantics = tester.ensureSemantics();
    await open(tester);

    expect(find.text('This week'), findsOneWidget);
    expect(find.text('minutes'), findsOneWidget);
    for (final l in ['M', 'T', 'W', 'F', 'S']) {
      expect(find.text(l), findsWidgets);
    }
    expect(find.bySemanticsLabel(RegExp('M: 35 minutes')), findsOneWidget);
    expect(find.bySemanticsLabel(RegExp('S: 90 minutes')), findsOneWidget);
    expect(find.bySemanticsLabel(RegExp('W: 20 minutes')), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('bar heights are proportional to minutes, peak is tallest', (
    tester,
  ) async {
    await open(tester);

    final bars = tester
        .widgetList<Container>(
          find.descendant(
            of: find.byType(Column),
            matching: find.byType(Container),
          ),
        )
        .where((c) => c.constraints?.maxHeight == c.constraints?.minHeight)
        .map((c) => c.constraints!.maxHeight)
        .where((h) => h <= 96 && h > 0)
        .toList();

    expect(bars, contains(96.0)); // Saturday, the 90 minute peak
    expect(bars.where((h) => h == 96.0), hasLength(1));
    expect(bars, contains(closeTo(20 / 90 * 96, .01))); // Wednesday
  });

  testWidgets('lists recent achievements', (tester) async {
    await open(tester);

    expect(find.text('Recent achievements'), findsOneWidget);
    expect(find.text('7 day streak'), findsOneWidget);
    expect(find.text('100 cards'), findsOneWidget);
    expect(find.text('Quiz 90%+'), findsOneWidget);
    expect(find.byIcon(Icons.local_fire_department), findsOneWidget);
    expect(find.byIcon(Icons.emoji_events), findsOneWidget);
  });
}
