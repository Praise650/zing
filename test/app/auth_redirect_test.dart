import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:zing/app/app.dart';
import 'package:zing/features/authentication/presentation/sign_in_screen.dart';
import 'package:zing/features/home/presentation/home_screen.dart';
import 'package:zing/features/onboarding/presentation/onboarding_screen.dart';

import '../helpers/in_memory_storage.dart';
import '../helpers/pump_app.dart';

/// Exercises the real [ZingApp] router, including its session redirects.
void main() {
  Future<void> launch(
    WidgetTester tester, {
    Map<String, dynamic>? session,
  }) async {
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    final storage = InMemoryStorage();
    if (session != null) storage.write('SessionCubit', session);
    HydratedBloc.storage = storage;
    await tester.pumpWidget(const ZingApp());
    await tester.pumpAndSettle();
  }

  const signedIn = {
    'onboardingSeen': true,
    'signedIn': true,
    'name': 'Alex Morgan',
    'email': 'alex@uni.edu',
  };

  testWidgets('a first launch starts on onboarding', (tester) async {
    await launch(tester);

    expect(find.byType(OnboardingScreen), findsOneWidget);
  });

  testWidgets('a returning signed-out user skips onboarding', (tester) async {
    await launch(tester, session: {'onboardingSeen': true, 'signedIn': false});

    expect(find.byType(SignInScreen), findsOneWidget);
  });

  testWidgets('a signed-in user lands on home', (tester) async {
    await launch(tester, session: signedIn);

    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.text('Alex'), findsOneWidget);
  });

  testWidgets('signing in from onboarding reaches home', (tester) async {
    await launch(tester);
    await tapText(tester, 'Skip');
    await tester.enterText(find.byType(TextField).at(0), 'jane@uni.edu');
    await tester.enterText(find.byType(TextField).at(1), 'secret');

    await tapText(tester, 'Sign in');

    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.text('Jane'), findsOneWidget);
  });

  testWidgets('signing out returns to sign in and locks the app', (
    tester,
  ) async {
    await launch(tester, session: signedIn);
    await tester.tap(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text('Profile'),
      ),
    );
    await tester.pumpAndSettle();

    await tapText(tester, 'Sign out');

    expect(find.byType(SignInScreen), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
  });

  testWidgets('sign up then home shows the new account on the profile', (
    tester,
  ) async {
    await launch(tester);
    await tapText(tester, 'Skip');
    await tester.tap(find.textContaining('Create account', findRichText: true));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).at(0), 'Sam Rivera');
    await tester.enterText(find.byType(TextField).at(1), 'sam@uni.edu');
    await tester.enterText(find.byType(TextField).at(2), 'Passw0rd!');
    await tapText(tester, 'I agree to the Terms and Privacy Policy');
    await tester.tap(zingButton('Create account'));
    await tester.pumpAndSettle();
    expect(find.text('Sam'), findsOneWidget);

    await tester.tap(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text('Profile'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Sam Rivera'), findsOneWidget);
    expect(find.text('sam@uni.edu'), findsOneWidget);
  });
}
