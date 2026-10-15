import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zing/features/home/presentation/home_screen.dart';
import 'package:zing/features/summaries/presentation/material_detail_screen.dart';

import '../../helpers/pump_app.dart';

void main() {
  Future<void> open(WidgetTester tester) =>
      pumpZing(tester, location: '/add-material');

  /// The import pipeline is timer driven (upload 1.5s, processing 3s), so the
  /// clock is advanced explicitly. `pumpAndSettle` cannot be used while the
  /// processing spinner animates.
  Future<void> elapse(WidgetTester tester, Duration d) async {
    await tester.pump(d);
    await tester.pump();
  }

  const upload = Duration(milliseconds: 1500);
  const processing = Duration(seconds: 3);

  testWidgets('shows every way to add material', (tester) async {
    await open(tester);

    expect(find.text('Add material'), findsOneWidget);
    expect(find.text('Upload PDF or document'), findsOneWidget);
    expect(find.text('PDF, DOCX, TXT · up to 50 MB'), findsOneWidget);
    expect(zingButton('Choose file'), findsOneWidget);
    expect(find.text('Paste text'), findsOneWidget);
    expect(find.text('Import file'), findsOneWidget);
    expect(find.text('Scan with camera'), findsOneWidget);
  });

  testWidgets('Scan with camera says it is coming soon', (tester) async {
    await open(tester);

    await tapText(tester, 'Scan with camera');

    expect(find.text('Camera scanning is coming soon.'), findsOneWidget);
  });

  testWidgets('Back leaves the screen', (tester) async {
    await open(tester);

    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();

    expect(find.byType(HomeScreen), findsOneWidget);
  });

  testWidgets('Choose file starts uploading with progress', (tester) async {
    await open(tester);

    await tester.tap(zingButton('Choose file'));
    await tester.pump();

    expect(find.text('Biology_Ch4.pdf'), findsOneWidget);
    expect(find.text('Uploading'), findsOneWidget);
    expect(find.text('0%'), findsOneWidget);
    expect(find.text('Upload PDF or document'), findsNothing);

    await elapse(tester, const Duration(milliseconds: 750));
    expect(find.text('50%'), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await tester.pump();
  });

  testWidgets('Cancel returns to the drop zone', (tester) async {
    await open(tester);
    await tester.tap(zingButton('Choose file'));
    await tester.pump();

    await tester.tap(find.text('Cancel'));
    await tester.pump();

    expect(find.text('Upload PDF or document'), findsOneWidget);
    expect(find.text('Uploading'), findsNothing);
    // Nothing keeps running after a cancel.
    await tester.pump(upload + processing);
    expect(find.text('Your material is ready'), findsNothing);
  });

  testWidgets('upload then AI processing steps', (tester) async {
    await open(tester);
    await tester.tap(zingButton('Choose file'));
    await tester.pump();

    await elapse(tester, upload);

    expect(find.text('AI is processing'), findsOneWidget);
    expect(find.text('~30 sec'), findsOneWidget);
    expect(find.text('Reading document'), findsOneWidget);
    expect(find.text('Writing summary'), findsOneWidget);
    expect(find.text('Creating flashcards and quiz'), findsOneWidget);
    expect(find.text('Uploading'), findsNothing);

    await elapse(tester, processing);
  });

  testWidgets('a finished import is ready and opens the new material', (
    tester,
  ) async {
    await open(tester);
    await tester.tap(zingButton('Choose file'));
    await tester.pump();
    await elapse(tester, upload);
    await elapse(tester, processing);

    expect(find.text('Your material is ready'), findsOneWidget);
    expect(
      find.text('Summary, 4 flashcards and 3 quiz questions.'),
      findsOneWidget,
    );

    await tester.tap(zingButton('Open material'));
    await tester.pumpAndSettle();

    expect(find.byType(MaterialDetailScreen), findsOneWidget);
    expect(find.text('Biology Ch4'), findsOneWidget);
    expect(find.text('PDF · Added today'), findsOneWidget);
  });

  testWidgets('Import file imports a named document', (tester) async {
    await open(tester);

    await tapText(tester, 'Import file');
    expect(find.text('Imported_notes.pdf'), findsOneWidget);
    expect(find.text('Uploading'), findsOneWidget);

    await elapse(tester, upload);
    await elapse(tester, processing);
    expect(find.text('Your material is ready'), findsOneWidget);
  });

  testWidgets('the imported material is added to the library', (tester) async {
    await open(tester);
    await tester.tap(zingButton('Choose file'));
    await tester.pump();
    await elapse(tester, upload);
    await elapse(tester, processing);
    await tester.tap(zingButton('Open material'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();

    // Back on home, the newest material leads the recent list.
    expect(find.text('Biology Ch4'), findsWidgets);
  });

  group('paste text', () {
    Future<void> openSheet(WidgetTester tester) async {
      await open(tester);
      await tapText(tester, 'Paste text');
    }

    testWidgets('opens a sheet with a disabled Create button', (tester) async {
      await openSheet(tester);

      expect(find.text('Paste your text'), findsOneWidget);
      expect(find.text('Paste notes or an article here'), findsOneWidget);
      expect(isEnabled(tester, 'Create study set'), isFalse);
    });

    testWidgets('whitespace alone keeps Create disabled', (tester) async {
      await openSheet(tester);

      await tester.enterText(find.byType(TextField), '   \n  ');
      await tester.pump();

      expect(isEnabled(tester, 'Create study set'), isFalse);
    });

    testWidgets('typing enables Create', (tester) async {
      await openSheet(tester);

      await tester.enterText(find.byType(TextField), 'Photosynthesis notes');
      await tester.pump();

      expect(isEnabled(tester, 'Create study set'), isTrue);
    });

    testWidgets('creating closes the sheet and processes the text', (
      tester,
    ) async {
      await openSheet(tester);
      await tester.enterText(
        find.byType(TextField),
        'Photosynthesis notes\nLight reactions happen in the thylakoid.',
      );
      await tester.pump();

      await tester.tap(zingButton('Create study set'));
      // Let the sheet finish closing, frame by frame.
      for (var i = 0; i < 20; i++) {
        await tester.pump(const Duration(milliseconds: 25));
      }

      expect(find.text('Paste your text'), findsNothing);
      expect(find.text('Pasted text'), findsOneWidget);
      expect(find.text('Uploading'), findsOneWidget);

      await elapse(tester, upload);
      await elapse(tester, processing);
      expect(find.text('Your material is ready'), findsOneWidget);

      await tester.tap(zingButton('Open material'));
      await tester.pumpAndSettle();
      // Titled after the first line of the pasted text.
      expect(find.text('Photosynthesis notes'), findsOneWidget);
      expect(find.text('Pasted text · Added today'), findsOneWidget);
    });
  });
}
