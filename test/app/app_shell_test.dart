import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zing/features/home/presentation/home_screen.dart';
import 'package:zing/features/library/presentation/library_screen.dart';
import 'package:zing/features/profile/presentation/profile_screen.dart';
import 'package:zing/features/progress/presentation/progress_screen.dart';

import '../helpers/pump_app.dart';

void main() {
  Finder tab(String label) => find.descendant(
    of: find.byType(NavigationBar),
    matching: find.text(label),
  );

  testWidgets('shows the four tabs with Home selected', (tester) async {
    await pumpZing(tester);

    for (final l in ['Home', 'Library', 'Progress', 'Profile']) {
      expect(tab(l), findsOneWidget);
    }
    expect(
      tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex,
      0,
    );
    expect(find.byType(HomeScreen), findsOneWidget);
  });

  testWidgets('each tab opens its screen and updates the selection', (
    tester,
  ) async {
    await pumpZing(tester);
    int selected() =>
        tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex;

    await tester.tap(tab('Library'));
    await tester.pumpAndSettle();
    expect(find.byType(LibraryScreen), findsOneWidget);
    expect(selected(), 1);

    await tester.tap(tab('Progress'));
    await tester.pumpAndSettle();
    expect(find.byType(ProgressScreen), findsOneWidget);
    expect(selected(), 2);

    await tester.tap(tab('Profile'));
    await tester.pumpAndSettle();
    expect(find.byType(ProfileScreen), findsOneWidget);
    expect(selected(), 3);

    await tester.tap(tab('Home'));
    await tester.pumpAndSettle();
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(selected(), 0);
  });

  testWidgets('tabs keep their state when switching away and back', (
    tester,
  ) async {
    await pumpZing(tester, location: '/library');
    await tester.enterText(find.byType(TextField), 'python');
    await tester.pumpAndSettle();

    await tester.tap(tab('Progress'));
    await tester.pumpAndSettle();
    await tester.tap(tab('Library'));
    await tester.pumpAndSettle();

    expect(find.text('python'), findsOneWidget);
    expect(find.text('Roman History'), findsNothing);
  });

  testWidgets('full-screen routes hide the bottom navigation', (tester) async {
    for (final route in [
      '/add-material',
      '/material/cell-biology',
      '/flashcards/cell-biology',
      '/quiz/cell-biology',
    ]) {
      await pumpZing(tester, location: route);
      expect(find.byType(NavigationBar), findsNothing, reason: route);
    }
  });

  testWidgets('auth routes hide the bottom navigation', (tester) async {
    for (final route in ['/onboarding', '/sign-in', '/sign-up']) {
      await pumpZing(tester, location: route);
      expect(find.byType(NavigationBar), findsNothing, reason: route);
    }
  });
}
