import 'package:flutter_test/flutter_test.dart';
import 'package:zing/features/flashcards/presentation/flashcard_screen.dart';
import 'package:zing/features/home/presentation/home_screen.dart';

import '../../helpers/pump_app.dart';

void main() {
  Future<void> open(WidgetTester tester) =>
      pumpZing(tester, location: '/flashcards/cell-biology');

  Future<void> flip(WidgetTester tester) async {
    await tester.tap(find.byType(FlipCard));
    await tester.pumpAndSettle();
  }

  Future<void> rate(WidgetTester tester, String label) async {
    await tester.tap(find.text(label));
    await tester.pumpAndSettle();
  }

  testWidgets('starts on the first card, question side up', (tester) async {
    await open(tester);

    expect(find.text('1/4'), findsOneWidget);
    expect(find.text('QUESTION'), findsOneWidget);
    expect(
      find.text(
        'What is the final electron acceptor in the electron transport chain?',
      ),
      findsOneWidget,
    );
    expect(find.text('Tap to flip'), findsOneWidget);
    expect(find.text('Oxygen'), findsNothing);
  });

  testWidgets('shows the four rating buttons with intervals', (tester) async {
    await open(tester);

    for (final l in ['Again', 'Hard', 'Good', 'Easy']) {
      expect(find.text(l), findsOneWidget);
    }
    for (final i in ['1 min', '1 day', '3 days', '7 days']) {
      expect(find.text(i), findsOneWidget);
    }
  });

  testWidgets('tapping the card reveals the answer and explanation', (
    tester,
  ) async {
    await open(tester);

    await flip(tester);

    expect(find.text('ANSWER'), findsOneWidget);
    expect(find.text('Oxygen'), findsOneWidget);
    expect(
      find.text(
        'Oxygen accepts electrons and combines with hydrogen to form water.',
      ),
      findsOneWidget,
    );
    expect(find.text('Tap to flip back'), findsOneWidget);
    expect(find.text('QUESTION'), findsNothing);
  });

  testWidgets('tapping again flips back to the question', (tester) async {
    await open(tester);
    await flip(tester);

    await flip(tester);

    expect(find.text('QUESTION'), findsOneWidget);
    expect(find.text('Oxygen'), findsNothing);
  });

  testWidgets('rating moves to the next card, question side up', (
    tester,
  ) async {
    await open(tester);
    await flip(tester);

    await rate(tester, 'Good');

    expect(find.text('2/4'), findsOneWidget);
    expect(find.text('Where does glycolysis take place?'), findsOneWidget);
    expect(find.text('QUESTION'), findsOneWidget);
  });

  testWidgets('rating without flipping first is allowed', (tester) async {
    await open(tester);

    await rate(tester, 'Hard');

    expect(find.text('2/4'), findsOneWidget);
  });

  testWidgets('rating every card shows the completion summary', (tester) async {
    await open(tester);

    for (final l in ['Easy', 'Good', 'Again', 'Hard']) {
      await rate(tester, l);
    }

    expect(find.text('Deck complete'), findsOneWidget);
    expect(find.text('You knew 2 of 4 cards well.'), findsOneWidget);
    expect(find.byType(FlipCard), findsNothing);
  });

  testWidgets('Review again restarts the deck from card one', (tester) async {
    await open(tester);
    for (final l in ['Easy', 'Easy', 'Easy', 'Easy']) {
      await rate(tester, l);
    }

    await tester.tap(zingButton('Review again'));
    await tester.pumpAndSettle();

    expect(find.text('1/4'), findsOneWidget);
    expect(find.text('Deck complete'), findsNothing);
  });

  testWidgets('Done leaves the deck', (tester) async {
    await open(tester);
    for (final l in ['Easy', 'Easy', 'Easy', 'Easy']) {
      await rate(tester, l);
    }

    await tester.tap(zingButton('Done'));
    await tester.pumpAndSettle();

    expect(find.byType(HomeScreen), findsOneWidget);
  });

  testWidgets('Close leaves the deck', (tester) async {
    await open(tester);

    await tester.tap(find.byTooltip('Close'));
    await tester.pumpAndSettle();

    expect(find.byType(HomeScreen), findsOneWidget);
  });

  testWidgets('Close pops back when opened from another screen', (
    tester,
  ) async {
    await pumpZing(tester, location: '/material/cell-biology');
    await tapText(tester, 'Flashcards');
    expect(find.byType(FlashcardScreen), findsOneWidget);

    await tester.tap(find.byTooltip('Close'));
    await tester.pumpAndSettle();

    expect(find.byType(FlashcardScreen), findsNothing);
    expect(find.text('Cell Biology · Chapter 4'), findsOneWidget);
  });
}
