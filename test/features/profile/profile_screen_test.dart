import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zing/features/authentication/presentation/sign_in_screen.dart';
import 'package:zing/features/profile/presentation/profile_screen.dart';

import '../../helpers/pump_app.dart';

void main() {
  Future<void> open(WidgetTester tester) => pumpZing(
    tester,
    location: '/profile',
    signedInAs: 'Alex Morgan',
    logicalSize: const Size(390, 1100),
  );

  Finder inProfile(Finder f) => inScreen<ProfileScreen>(f);

  ThemeMode themeMode(WidgetTester tester) =>
      tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode!;

  bool switchValue(WidgetTester tester, int i) =>
      tester.widget<Switch>(find.byType(Switch).at(i)).value;

  testWidgets('shows the signed-in user', (tester) async {
    await open(tester);

    expect(find.text('Alex Morgan'), findsOneWidget);
    expect(find.text('alex@uni.edu'), findsOneWidget);
    expect(find.text('A'), findsOneWidget);
  });

  testWidgets('shows goals, notifications, appearance and account', (
    tester,
  ) async {
    await open(tester);

    for (final s in [
      'LEARNING GOALS',
      'NOTIFICATIONS',
      'APPEARANCE',
      'ACCOUNT',
    ]) {
      expect(find.text(s), findsOneWidget);
    }
    expect(find.text('Daily study goal'), findsOneWidget);
    expect(find.text('30 min'), findsOneWidget);
    expect(find.text('Exam target'), findsOneWidget);
    expect(find.text('Dec 12'), findsOneWidget);
    expect(find.text('Daily reminder'), findsOneWidget);
    expect(find.text('Streak warnings'), findsOneWidget);
    expect(find.text('Edit profile'), findsOneWidget);
    expect(find.text('Sign out'), findsOneWidget);
  });

  group('daily goal', () {
    testWidgets('the dialog lists every option', (tester) async {
      await open(tester);

      await tapText(tester, 'Daily study goal');

      expect(find.byType(SimpleDialog), findsOneWidget);
      for (final m in ['15', '30', '45', '60', '90']) {
        expect(
          find.descendant(
            of: find.byType(SimpleDialog),
            matching: find.text('$m min'),
          ),
          findsOneWidget,
        );
      }
    });

    testWidgets('choosing an option updates the goal', (tester) async {
      await open(tester);
      await tapText(tester, 'Daily study goal');

      await tester.tap(
        find.descendant(
          of: find.byType(SimpleDialog),
          matching: find.text('60 min'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(SimpleDialog), findsNothing);
      expect(inProfile(find.text('60 min')), findsOneWidget);
      expect(find.text('30 min'), findsNothing);
    });

    testWidgets('dismissing the dialog keeps the goal', (tester) async {
      await open(tester);
      await tapText(tester, 'Daily study goal');

      await tester.tapAt(const Offset(5, 5)); // barrier
      await tester.pumpAndSettle();

      expect(find.byType(SimpleDialog), findsNothing);
      expect(find.text('30 min'), findsOneWidget);
    });
  });

  group('exam target', () {
    testWidgets('opens a date picker that can be cancelled', (tester) async {
      await open(tester);

      await tapText(tester, 'Exam target');
      expect(find.byType(DatePickerDialog), findsOneWidget);

      await tapText(tester, 'Cancel');
      expect(find.byType(DatePickerDialog), findsNothing);
      expect(find.text('Dec 12'), findsOneWidget);
    });

    testWidgets('picking a date updates the target', (tester) async {
      await open(tester);
      await tapText(tester, 'Exam target');

      // Choose the last day of the visible month, then confirm.
      await tester.tap(find.text('28').last);
      await tester.pumpAndSettle();
      await tapText(tester, 'OK');

      expect(find.byType(DatePickerDialog), findsNothing);
      expect(find.text('Dec 12'), findsNothing);
      expect(find.textContaining(' 28'), findsOneWidget);
    });
  });

  testWidgets('notification switches toggle independently', (tester) async {
    await open(tester);
    expect(switchValue(tester, 0), isTrue);
    expect(switchValue(tester, 1), isTrue);

    await tester.tap(find.byType(Switch).at(0));
    await tester.pumpAndSettle();

    expect(switchValue(tester, 0), isFalse);
    expect(switchValue(tester, 1), isTrue);

    await tester.tap(find.byType(Switch).at(1));
    await tester.pumpAndSettle();
    expect(switchValue(tester, 1), isFalse);
  });

  testWidgets('theme selector switches the app theme', (tester) async {
    await open(tester);
    expect(themeMode(tester), ThemeMode.light);

    await tapText(tester, 'Dark');
    expect(themeMode(tester), ThemeMode.dark);

    await tapText(tester, 'Auto');
    expect(themeMode(tester), ThemeMode.system);

    await tapText(tester, 'Light');
    expect(themeMode(tester), ThemeMode.light);
  });

  group('edit profile', () {
    Future<void> openSheet(WidgetTester tester) async {
      await open(tester);
      await tapText(tester, 'Edit profile');
    }

    Finder sheetField(int i) => find.byType(TextField).at(i);

    testWidgets('opens prefilled with the current details', (tester) async {
      await openSheet(tester);

      expect(find.byType(BottomSheet), findsOneWidget);
      expect(find.widgetWithText(TextField, 'Alex Morgan'), findsOneWidget);
      expect(find.widgetWithText(TextField, 'alex@uni.edu'), findsOneWidget);
    });

    testWidgets('invalid details show errors and keep the sheet open', (
      tester,
    ) async {
      await openSheet(tester);
      await tester.enterText(sheetField(0), 'A');
      await tester.enterText(sheetField(1), 'nope');

      await tester.tap(zingButton('Save'));
      await tester.pumpAndSettle();

      expect(find.text('Enter your full name.'), findsOneWidget);
      expect(find.text('Enter a valid email address.'), findsOneWidget);
      expect(find.byType(BottomSheet), findsOneWidget);
    });

    testWidgets('saving updates the header and closes the sheet', (
      tester,
    ) async {
      await openSheet(tester);
      await tester.enterText(sheetField(0), 'Sam Rivera');
      await tester.enterText(sheetField(1), 'sam@uni.edu');

      await tester.tap(zingButton('Save'));
      await tester.pumpAndSettle();

      expect(find.byType(BottomSheet), findsNothing);
      expect(inProfile(find.text('Sam Rivera')), findsOneWidget);
      expect(inProfile(find.text('sam@uni.edu')), findsOneWidget);
      expect(find.text('S'), findsOneWidget);
    });
  });

  testWidgets('Sign out returns to the sign in screen', (tester) async {
    await open(tester);

    await tapText(tester, 'Sign out');

    expect(find.byType(SignInScreen), findsOneWidget);
  });
}
