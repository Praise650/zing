import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zing/features/home/presentation/home_screen.dart';

import '../../helpers/pump_app.dart';

void main() {
  Future<void> open(WidgetTester tester, [String id = 'cell-biology']) =>
      pumpZing(tester, location: '/material/$id');

  testWidgets('shows title, meta and status badges', (tester) async {
    await open(tester);

    expect(find.text('Cell Biology · Chapter 4'), findsOneWidget);
    expect(find.text('PDF · 18 pages · Added Oct 12'), findsOneWidget);
    expect(find.text('Summary ready'), findsOneWidget);
    expect(find.text('4 cards'), findsOneWidget);
    expect(find.text('Quiz new'), findsOneWidget);
  });

  testWidgets('opens on the AI summary with all sections', (tester) async {
    await open(tester);

    expect(find.text('OVERVIEW'), findsOneWidget);
    expect(
      find.textContaining('Mitochondria convert nutrients'),
      findsOneWidget,
    );
    expect(find.text('KEY CONCEPTS'), findsOneWidget);
    for (final k in ['Glycolysis', 'Krebs cycle', 'Electron transport']) {
      expect(find.text(k), findsOneWidget);
    }
    expect(find.text('TAKEAWAYS'), findsOneWidget);
    expect(
      find.text('One glucose molecule yields about 30 ATP.'),
      findsOneWidget,
    );
  });

  testWidgets('omits concept and takeaway sections when empty', (tester) async {
    await open(tester, 'python-basics');

    expect(find.text('OVERVIEW'), findsOneWidget);
    expect(find.text('KEY CONCEPTS'), findsNothing);
    expect(find.text('TAKEAWAYS'), findsNothing);
  });

  testWidgets('the Preview tab shows the placeholder, and back again', (
    tester,
  ) async {
    await open(tester);

    await tapText(tester, 'Preview');
    expect(
      find.text(
        'Original document preview is not available in this prototype.',
      ),
      findsOneWidget,
    );
    expect(find.text('OVERVIEW'), findsNothing);

    await tapText(tester, 'AI Summary');
    expect(find.text('OVERVIEW'), findsOneWidget);
  });

  testWidgets('Copy puts the summary on the clipboard and confirms', (
    tester,
  ) async {
    String? copied;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') {
          copied = (call.arguments as Map)['text'] as String?;
        }
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );
    await open(tester);

    await tester.tap(zingButton('Copy'));
    await tester.pump();

    expect(find.text('Summary copied'), findsOneWidget);
    expect(copied, startsWith('Mitochondria convert nutrients'));
  });

  testWidgets('Save confirms with a snackbar', (tester) async {
    await open(tester);

    await tester.tap(zingButton('Save'));
    await tester.pump();

    expect(find.text('Saved to library'), findsOneWidget);
  });

  testWidgets('Regenerate confirms with a snackbar', (tester) async {
    await open(tester);

    await tester.tap(zingButton('Regenerate'));
    await tester.pump();

    expect(find.text('Regenerating summary…'), findsOneWidget);
  });

  testWidgets('Flashcards and Quiz open their screens', (tester) async {
    await open(tester);

    await tester.tap(zingButton('Flashcards'));
    await tester.pumpAndSettle();
    expect(find.text('Tap to flip'), findsOneWidget);

    await tester.tap(find.byTooltip('Close'));
    await tester.pumpAndSettle();

    await tester.tap(zingButton('Quiz'));
    await tester.pumpAndSettle();
    expect(find.text('Question 1 of 3'), findsOneWidget);
  });

  testWidgets('Quiz is disabled when the material has no questions', (
    tester,
  ) async {
    await open(tester, 'calculus-limits');

    expect(isEnabled(tester, 'Flashcards'), isTrue);
    expect(isEnabled(tester, 'Quiz'), isFalse);
    expect(find.text('Quiz new'), findsNothing);
  });

  testWidgets('both study actions are disabled for a bare material', (
    tester,
  ) async {
    await open(tester, 'aws-cert');

    expect(isEnabled(tester, 'Flashcards'), isFalse);
    expect(isEnabled(tester, 'Quiz'), isFalse);
    expect(find.text('Summary ready'), findsOneWidget);
    expect(find.textContaining(' cards'), findsNothing);
  });

  testWidgets('an unknown id falls back to the first material', (tester) async {
    await open(tester, 'does-not-exist');

    expect(find.text('Cell Biology · Chapter 4'), findsOneWidget);
  });

  testWidgets('Back leaves the screen', (tester) async {
    await open(tester);

    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();

    expect(find.byType(HomeScreen), findsOneWidget);
  });
}
