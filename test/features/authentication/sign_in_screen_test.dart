import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zing/features/authentication/presentation/forgot_password_screen.dart';
import 'package:zing/features/authentication/presentation/sign_up_screen.dart';
import 'package:zing/features/home/presentation/home_screen.dart';

import '../../helpers/pump_app.dart';

void main() {
  Future<void> open(WidgetTester tester) =>
      pumpZing(tester, location: '/sign-in');

  Finder field(int i) => find.byType(TextField).at(i);

  testWidgets('shows the form and social buttons', (tester) async {
    await open(tester);

    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Forgot password?'), findsOneWidget);
    expect(zingButton('Sign in'), findsOneWidget);
    expect(zingButton('Google'), findsOneWidget);
    expect(zingButton('Apple'), findsOneWidget);
  });

  testWidgets('no errors are shown before the first submit', (tester) async {
    await open(tester);

    await tester.enterText(field(0), 'not-an-email');
    await tester.pump();

    expect(find.text('Enter a valid email address.'), findsNothing);
  });

  testWidgets('empty submit shows both field errors and stays put', (
    tester,
  ) async {
    await open(tester);

    await tapText(tester, 'Sign in');

    expect(find.text('Enter a valid email address.'), findsOneWidget);
    expect(find.text('Enter your password.'), findsOneWidget);
    expect(find.text('Welcome back'), findsOneWidget);
  });

  testWidgets('invalid email is rejected even with a password', (tester) async {
    await open(tester);
    await tester.enterText(field(0), 'nope');
    await tester.enterText(field(1), 'secret');

    await tapText(tester, 'Sign in');

    expect(find.text('Enter a valid email address.'), findsOneWidget);
    expect(find.text('Enter your password.'), findsNothing);
  });

  testWidgets('errors clear once the input becomes valid', (tester) async {
    await open(tester);
    await tapText(tester, 'Sign in');

    await tester.enterText(field(0), 'jane@uni.edu');
    await tester.enterText(field(1), 'secret');
    await tester.pump();

    expect(find.text('Enter a valid email address.'), findsNothing);
    expect(find.text('Enter your password.'), findsNothing);
  });

  testWidgets('valid credentials open home with a name from the email', (
    tester,
  ) async {
    await open(tester);
    await tester.enterText(field(0), 'jane.doe@uni.edu');
    await tester.enterText(field(1), 'secret');

    await tapText(tester, 'Sign in');

    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.text('Jane'), findsOneWidget);
  });

  testWidgets('submitting from the keyboard signs in', (tester) async {
    await open(tester);
    await tester.enterText(field(0), 'jane@uni.edu');
    await tester.enterText(field(1), 'secret');

    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    expect(find.byType(HomeScreen), findsOneWidget);
  });

  testWidgets('password can be revealed and hidden', (tester) async {
    await open(tester);
    bool obscured() => tester.widget<TextField>(field(1)).obscureText;

    expect(obscured(), isTrue);
    await tapText(tester, 'Show');
    expect(obscured(), isFalse);
    await tapText(tester, 'Hide');
    expect(obscured(), isTrue);
  });

  testWidgets('Forgot password carries the typed email over', (tester) async {
    await open(tester);
    await tester.enterText(field(0), 'jane@uni.edu');

    await tapText(tester, 'Forgot password?');

    expect(find.byType(ForgotPasswordScreen), findsOneWidget);
    expect(find.text('jane@uni.edu'), findsOneWidget);
  });

  testWidgets('footer link goes to sign up', (tester) async {
    await open(tester);

    await tester.tap(find.textContaining('Create account', findRichText: true));
    await tester.pumpAndSettle();

    expect(find.byType(SignUpScreen), findsOneWidget);
  });

  testWidgets('social buttons explain they are unavailable', (tester) async {
    await open(tester);

    await tapText(tester, 'Google');

    expect(find.text('Social sign-in is not available yet.'), findsOneWidget);
  });
}
