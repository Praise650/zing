import 'package:flutter_test/flutter_test.dart';
import 'package:zing/features/home/presentation/home_screen.dart';

import '../../helpers/pump_app.dart';

void main() {
  Future<void> open(WidgetTester tester) =>
      pumpZing(tester, location: '/quiz/cell-biology');

  Future<void> pick(WidgetTester tester, String option) async {
    await tester.tap(find.text(option));
    await tester.pumpAndSettle();
  }

  Future<void> check(WidgetTester tester) async {
    await tester.tap(zingButton('Check answer'));
    await tester.pumpAndSettle();
  }

  Future<void> next(WidgetTester tester) async {
    await tester.tap(zingButton('Next question'));
    await tester.pumpAndSettle();
  }

  /// Answers every question: q1 right, q2 wrong, q3 right.
  Future<void> finishWithOneMiss(WidgetTester tester) async {
    await pick(tester, 'Cytoplasm');
    await check(tester);
    await next(tester);
    await pick(tester, 'Water');
    await check(tester);
    await next(tester);
    await pick(tester, 'Mitochondrial matrix');
    await check(tester);
    await tester.tap(zingButton('See results'));
    await tester.pumpAndSettle();
  }

  testWidgets('starts on question 1 with four lettered options', (
    tester,
  ) async {
    await open(tester);

    expect(find.text('Question 1 of 3'), findsOneWidget);
    expect(
      find.text('Where does glycolysis take place in the cell?'),
      findsOneWidget,
    );
    for (final o in [
      'Mitochondria',
      'Cytoplasm',
      'Nucleus',
      'Golgi apparatus',
    ]) {
      expect(find.text(o), findsOneWidget);
    }
    for (final l in ['A', 'B', 'C', 'D']) {
      expect(find.text(l), findsOneWidget);
    }
  });

  testWidgets('Check answer is disabled until an option is chosen', (
    tester,
  ) async {
    await open(tester);
    expect(isEnabled(tester, 'Check answer'), isFalse);

    await pick(tester, 'Nucleus');

    expect(isEnabled(tester, 'Check answer'), isTrue);
  });

  testWidgets('the selection can be changed before checking', (tester) async {
    await open(tester);
    await pick(tester, 'Nucleus');
    await pick(tester, 'Cytoplasm');
    await check(tester);

    expect(find.text('Correct'), findsOneWidget);
  });

  testWidgets('a correct answer shows Correct and the explanation', (
    tester,
  ) async {
    await open(tester);
    await pick(tester, 'Cytoplasm');

    await check(tester);

    expect(find.text('Correct'), findsOneWidget);
    expect(
      find.text(
        'Glycolysis happens in the cytoplasm. It does not need oxygen or mitochondria.',
      ),
      findsOneWidget,
    );
    expect(find.text('✓'), findsOneWidget);
    expect(find.text('✕'), findsNothing);
    expect(zingButton('Next question'), findsOneWidget);
  });

  testWidgets('a wrong answer reveals the right one', (tester) async {
    await open(tester);
    await pick(tester, 'Mitochondria');

    await check(tester);

    expect(find.text('Not quite. The answer is Cytoplasm.'), findsOneWidget);
    expect(find.text('✓'), findsOneWidget); // the correct option
    expect(find.text('✕'), findsOneWidget); // the user's pick
  });

  testWidgets('options are locked after checking', (tester) async {
    await open(tester);
    await pick(tester, 'Mitochondria');
    await check(tester);

    await pick(tester, 'Cytoplasm');

    expect(find.text('Not quite. The answer is Cytoplasm.'), findsOneWidget);
    expect(find.text('Correct'), findsNothing);
  });

  testWidgets('Next question resets the selection', (tester) async {
    await open(tester);
    await pick(tester, 'Cytoplasm');
    await check(tester);

    await next(tester);

    expect(find.text('Question 2 of 3'), findsOneWidget);
    expect(
      find.text('Which molecule is the final electron acceptor?'),
      findsOneWidget,
    );
    expect(find.text('Correct'), findsNothing);
    expect(isEnabled(tester, 'Check answer'), isFalse);
  });

  testWidgets('the last question offers See results', (tester) async {
    await open(tester);
    await pick(tester, 'Cytoplasm');
    await check(tester);
    await next(tester);
    await pick(tester, 'Oxygen');
    await check(tester);
    await next(tester);
    await pick(tester, 'Ribosome');

    await check(tester);

    expect(zingButton('See results'), findsOneWidget);
    expect(zingButton('Next question'), findsNothing);
  });

  testWidgets('results show score, percentage and missed count', (
    tester,
  ) async {
    await open(tester);

    await finishWithOneMiss(tester);

    expect(find.text('Quiz complete'), findsOneWidget);
    expect(find.text('2/3'), findsOneWidget);
    expect(find.text('67% correct'), findsOneWidget);
    expect(find.text('Review 1 missed questions'), findsOneWidget);
    expect(find.text('Correct'), findsOneWidget);
    expect(find.text('Missed'), findsOneWidget);
    expect(find.text('Questions'), findsOneWidget);
  });

  testWidgets('a perfect run scores 100%', (tester) async {
    await open(tester);
    await pick(tester, 'Cytoplasm');
    await check(tester);
    await next(tester);
    await pick(tester, 'Oxygen');
    await check(tester);
    await next(tester);
    await pick(tester, 'Mitochondrial matrix');
    await check(tester);
    await tester.tap(zingButton('See results'));
    await tester.pumpAndSettle();

    expect(find.text('3/3'), findsOneWidget);
    expect(find.text('100% correct'), findsOneWidget);
  });

  testWidgets('Retake quiz starts over', (tester) async {
    await open(tester);
    await finishWithOneMiss(tester);

    await tester.tap(zingButton('Retake quiz'));
    await tester.pumpAndSettle();

    expect(find.text('Question 1 of 3'), findsOneWidget);
    expect(find.text('Quiz complete'), findsNothing);
    expect(isEnabled(tester, 'Check answer'), isFalse);
  });

  testWidgets('Back to material leaves the quiz', (tester) async {
    await open(tester);
    await finishWithOneMiss(tester);

    await tester.tap(zingButton('Back to material'));
    await tester.pumpAndSettle();

    expect(find.byType(HomeScreen), findsOneWidget);
  });

  testWidgets('Close leaves the quiz mid-way', (tester) async {
    await open(tester);

    await tester.tap(find.byTooltip('Close'));
    await tester.pumpAndSettle();

    expect(find.byType(HomeScreen), findsOneWidget);
  });
}
