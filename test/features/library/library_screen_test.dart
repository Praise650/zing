import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zing/core/widgets/zing_filter_chip.dart';
import 'package:zing/features/library/presentation/library_screen.dart';
import 'package:zing/features/materials/presentation/add_material_screen.dart';
import 'package:zing/features/summaries/presentation/material_detail_screen.dart';

import '../../helpers/pump_app.dart';

void main() {
  Future<void> open(WidgetTester tester) =>
      pumpZing(tester, location: '/library');

  Finder inLib(Finder f) => inScreen<LibraryScreen>(f);

  Finder chip(String label) => find.widgetWithText(ZingFilterChip, label);

  Future<void> filterBy(WidgetTester tester, String label) async {
    await tester.ensureVisible(chip(label));
    await tester.pumpAndSettle();
    await tester.tap(chip(label));
    await tester.pumpAndSettle();
  }

  const all = [
    'Cell Biology · Chapter 4',
    'Organic Chemistry Notes',
    'Python Basics',
    'Calculus Limits',
    'AWS Cert Guide',
    'Roman History',
  ];

  testWidgets('shows title, search, filters and the grid by default', (
    tester,
  ) async {
    await open(tester);

    expect(inLib(find.text('Library')), findsOneWidget);
    expect(find.text('Search materials'), findsOneWidget);
    for (final f in ['All', 'Notes', 'PDFs', 'Summaries', 'Cards']) {
      expect(chip(f), findsOneWidget);
    }
    expect(find.byType(GridView), findsOneWidget);
    for (final t in all) {
      expect(find.text(t), findsOneWidget);
    }
  });

  testWidgets('List toggle swaps the grid for a list', (tester) async {
    await open(tester);

    await tapText(tester, 'List');

    expect(find.byType(GridView), findsNothing);
    expect(find.byType(ListView), findsOneWidget);
    expect(find.text('Python Basics'), findsOneWidget);

    await tapText(tester, 'Grid');
    expect(find.byType(GridView), findsOneWidget);
  });

  testWidgets('search matches titles case-insensitively', (tester) async {
    await open(tester);

    await tester.enterText(find.byType(TextField), 'PYTHON');
    await tester.pumpAndSettle();

    expect(find.text('Python Basics'), findsOneWidget);
    expect(find.text('Roman History'), findsNothing);
  });

  testWidgets('search also matches summary text', (tester) async {
    await open(tester);

    await tester.enterText(find.byType(TextField), 'republic');
    await tester.pumpAndSettle();

    expect(find.text('Roman History'), findsOneWidget);
    expect(find.text('Python Basics'), findsNothing);
  });

  testWidgets('no matches shows the empty state with an Add action', (
    tester,
  ) async {
    await open(tester);

    await tester.enterText(find.byType(TextField), 'zzzz');
    await tester.pumpAndSettle();

    expect(find.text('No results'), findsOneWidget);
    expect(find.textContaining('Nothing matches'), findsOneWidget);
    expect(find.text('Python Basics'), findsNothing);

    await tester.tap(zingButton('Add material'));
    await tester.pumpAndSettle();
    expect(find.byType(AddMaterialScreen), findsOneWidget);
  });

  testWidgets('clearing the search restores everything', (tester) async {
    await open(tester);
    await tester.enterText(find.byType(TextField), 'zzzz');
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), '');
    await tester.pumpAndSettle();

    expect(find.text('No results'), findsNothing);
    expect(find.text('Python Basics'), findsOneWidget);
  });

  testWidgets('PDFs filter keeps only PDFs', (tester) async {
    await open(tester);

    await filterBy(tester, 'PDFs');

    expect(find.text('Cell Biology · Chapter 4'), findsOneWidget);
    expect(find.text('AWS Cert Guide'), findsOneWidget);
    expect(find.text('Python Basics'), findsNothing);
    expect(find.text('Roman History'), findsNothing);
  });

  testWidgets('Notes filter includes notes and pasted text', (tester) async {
    await open(tester);

    await filterBy(tester, 'Notes');

    expect(find.text('Python Basics'), findsOneWidget);
    expect(find.text('Calculus Limits'), findsOneWidget);
    expect(find.text('Roman History'), findsOneWidget);
    expect(find.text('Organic Chemistry Notes'), findsNothing);
  });

  testWidgets('Cards filter hides materials without flashcards', (
    tester,
  ) async {
    await open(tester);

    await filterBy(tester, 'Cards');

    expect(find.text('Calculus Limits'), findsOneWidget);
    expect(find.text('AWS Cert Guide'), findsNothing);
    expect(find.text('Roman History'), findsNothing);
  });

  testWidgets('filter and search combine', (tester) async {
    await open(tester);
    await filterBy(tester, 'PDFs');

    await tester.enterText(find.byType(TextField), 'aws');
    await tester.pumpAndSettle();

    expect(find.text('AWS Cert Guide'), findsOneWidget);
    expect(find.text('Cell Biology · Chapter 4'), findsNothing);
  });

  testWidgets('All filter resets a previous filter', (tester) async {
    await open(tester);
    await filterBy(tester, 'PDFs');

    await filterBy(tester, 'All');

    expect(find.text('Python Basics'), findsOneWidget);
  });

  testWidgets('tapping a grid card opens the material', (tester) async {
    await open(tester);

    await tapText(tester, 'AWS Cert Guide');

    expect(find.byType(MaterialDetailScreen), findsOneWidget);
    expect(find.text('86 pages · Oct 3'), findsOneWidget);
  });

  testWidgets('tapping a list row opens the material', (tester) async {
    await open(tester);
    await tapText(tester, 'List');

    await tapText(tester, 'Roman History');

    expect(find.byType(MaterialDetailScreen), findsOneWidget);
  });
}
