import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zing/features/authentication/presentation/sign_in_screen.dart';
import 'package:zing/features/authentication/presentation/sign_up_screen.dart';

import '../../helpers/pump_app.dart';

void main() {
  Future<void> open(WidgetTester tester) =>
      pumpZing(tester, location: '/onboarding');

  testWidgets('first page shows headline, Skip and Continue', (tester) async {
    await open(tester);

    expect(find.text('Turn your notes into study materials'), findsOneWidget);
    expect(find.text('Skip'), findsOneWidget);
    expect(zingButton('Continue'), findsOneWidget);
    expect(find.text('I already have an account'), findsNothing);
  });

  testWidgets('Continue advances through pages to Get started', (tester) async {
    await open(tester);

    await tapText(tester, 'Continue');
    expect(find.text('Remember more with active recall'), findsOneWidget);

    await tapText(tester, 'Continue');
    expect(find.text('Track progress and keep your streak'), findsOneWidget);
    expect(zingButton('Get started'), findsOneWidget);
    expect(find.text('I already have an account'), findsOneWidget);
  });

  testWidgets('swiping moves to the next page', (tester) async {
    await open(tester);

    await tester.drag(find.byType(PageView), const Offset(-300, 0));
    await tester.pumpAndSettle();

    expect(find.text('Remember more with active recall'), findsOneWidget);
  });

  testWidgets('Skip goes to sign in', (tester) async {
    await open(tester);

    await tapText(tester, 'Skip');

    expect(find.byType(SignInScreen), findsOneWidget);
  });

  testWidgets('Get started goes to sign up', (tester) async {
    await open(tester);
    await tapText(tester, 'Continue');
    await tapText(tester, 'Continue');

    await tapText(tester, 'Get started');

    expect(find.byType(SignUpScreen), findsOneWidget);
  });

  testWidgets('"I already have an account" goes to sign in', (tester) async {
    await open(tester);
    await tapText(tester, 'Continue');
    await tapText(tester, 'Continue');

    await tapText(tester, 'I already have an account');

    expect(find.byType(SignInScreen), findsOneWidget);
  });
}
