import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zing/features/authentication/presentation/sign_in_screen.dart';
import 'package:zing/features/home/presentation/home_screen.dart';

import '../../helpers/pump_app.dart';

void main() {
  Future<void> open(WidgetTester tester) =>
      pumpZing(tester, location: '/sign-up');

  Finder field(int i) => find.byType(TextField).at(i);

  Future<void> fill(
    WidgetTester tester, {
    String name = 'Alex Morgan',
    String email = 'alex@uni.edu',
    String password = 'Passw0rd!',
  }) async {
    await tester.enterText(field(0), name);
    await tester.enterText(field(1), email);
    await tester.enterText(field(2), password);
    await tester.pump();
  }

  Future<void> agree(WidgetTester tester) =>
      tapText(tester, 'I agree to the Terms and Privacy Policy');

  testWidgets('shows the empty form with a disabled button', (tester) async {
    await open(tester);

    expect(find.text('Create account'), findsNWidgets(2)); // title + button
    expect(find.text('Full name'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(isEnabled(tester, 'Create account'), isFalse);
  });

  testWidgets('button stays disabled until the terms are accepted', (
    tester,
  ) async {
    await open(tester);

    await fill(tester);
    expect(isEnabled(tester, 'Create account'), isFalse);

    await agree(tester);
    expect(isEnabled(tester, 'Create account'), isTrue);
  });

  testWidgets('accepting the terms can be undone', (tester) async {
    await open(tester);
    await fill(tester);
    await agree(tester);

    await agree(tester);

    expect(isEnabled(tester, 'Create account'), isFalse);
  });

  for (final c in [
    ('a one-character name', 'A', 'alex@uni.edu', 'Passw0rd!'),
    ('an invalid email', 'Alex Morgan', 'alex@', 'Passw0rd!'),
    ('a short password', 'Alex Morgan', 'alex@uni.edu', 'short'),
  ]) {
    testWidgets('stays disabled with ${c.$1}', (tester) async {
      await open(tester);

      await fill(tester, name: c.$2, email: c.$3, password: c.$4);
      await agree(tester);

      expect(isEnabled(tester, 'Create account'), isFalse);
    });
  }

  testWidgets('shows an inline error for a malformed email', (tester) async {
    await open(tester);

    await tester.enterText(field(1), 'bad');
    await tester.pump();

    expect(find.text('Enter a valid email address.'), findsOneWidget);
  });

  testWidgets('password strength message follows the input', (tester) async {
    await open(tester);

    expect(find.textContaining('password'), findsNothing);

    await tester.enterText(field(2), 'abc');
    await tester.pump();
    expect(find.text('Weak. Use 8+ characters with a number.'), findsOneWidget);

    await tester.enterText(field(2), 'Passw0rd');
    await tester.pump();
    expect(
      find.text('Good. Add a symbol to make it stronger.'),
      findsOneWidget,
    );

    await tester.enterText(field(2), 'Passw0rd!');
    await tester.pump();
    expect(find.text('Strong password.'), findsOneWidget);
  });

  testWidgets('creating an account opens home greeting the new user', (
    tester,
  ) async {
    await open(tester);
    await fill(tester);
    await agree(tester);

    await tester.tap(zingButton('Create account'));
    await tester.pumpAndSettle();

    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.text('Alex'), findsOneWidget);
  });

  testWidgets('footer link goes to sign in', (tester) async {
    await open(tester);

    await tester.tap(find.textContaining('Sign in', findRichText: true));
    await tester.pumpAndSettle();

    expect(find.byType(SignInScreen), findsOneWidget);
  });
}
