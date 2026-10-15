import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:zing/app/router.dart';
import 'package:zing/features/authentication/presentation/forgot_password_screen.dart';
import 'package:zing/features/authentication/presentation/sign_in_screen.dart';

import '../../helpers/pump_app.dart';

void main() {
  Future<void> open(WidgetTester tester, {String? email}) async {
    final router = createRouter(initialLocation: '/sign-in');
    await pumpZing(tester, router: router);
    router.push('/forgot-password', extra: email);
    await tester.pumpAndSettle();
  }

  testWidgets('asks for an email', (tester) async {
    await open(tester);

    expect(find.text('Reset password'), findsOneWidget);
    expect(
      find.text('Enter your email and we will send you a reset link.'),
      findsOneWidget,
    );
    expect(zingButton('Send reset link'), findsOneWidget);
  });

  testWidgets('prefills the email passed from sign in', (tester) async {
    await open(tester, email: 'jane@uni.edu');

    expect(find.text('jane@uni.edu'), findsOneWidget);
  });

  testWidgets('an invalid email shows an error and does not send', (
    tester,
  ) async {
    await open(tester);
    await tester.enterText(find.byType(TextField), 'nope');

    await tapText(tester, 'Send reset link');

    expect(find.text('Enter a valid email address.'), findsOneWidget);
    expect(find.text('Check your email'), findsNothing);
  });

  testWidgets('a valid email shows the confirmation', (tester) async {
    await open(tester);
    await tester.enterText(find.byType(TextField), '  jane@uni.edu ');

    await tapText(tester, 'Send reset link');

    expect(find.text('Check your email'), findsOneWidget);
    expect(
      find.text(
        'If an account exists for jane@uni.edu, we sent a link to reset your password.',
      ),
      findsOneWidget,
    );
    expect(find.byType(TextField), findsNothing);
  });

  testWidgets('submitting from the keyboard sends the link', (tester) async {
    await open(tester, email: 'jane@uni.edu');
    await tester.tap(find.byType(TextField));
    await tester.pump();

    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    expect(find.text('Check your email'), findsOneWidget);
  });

  testWidgets('"Use a different email" returns to the form', (tester) async {
    await open(tester, email: 'jane@uni.edu');
    await tapText(tester, 'Send reset link');

    await tapText(tester, 'Use a different email');

    expect(find.text('Reset password'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
  });

  testWidgets('"Back to sign in" pops back to sign in', (tester) async {
    await open(tester, email: 'jane@uni.edu');
    await tapText(tester, 'Send reset link');

    await tapText(tester, 'Back to sign in');

    expect(find.byType(ForgotPasswordScreen), findsNothing);
    expect(find.byType(SignInScreen), findsOneWidget);
  });

  testWidgets('back arrow pops when there is history', (tester) async {
    await open(tester);

    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();

    expect(find.byType(SignInScreen), findsOneWidget);
  });

  testWidgets('back arrow falls back to sign in with no history', (
    tester,
  ) async {
    await pumpZing(tester, location: '/forgot-password');
    expect(tester.element(find.byType(ForgotPasswordScreen)).canPop(), isFalse);

    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();

    expect(find.byType(SignInScreen), findsOneWidget);
  });
}
