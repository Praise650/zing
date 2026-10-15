import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zing/features/materials/domain/study_material.dart';
import 'package:zing/features/materials/presentation/import_cubit.dart';

void main() {
  const upload = Duration(milliseconds: 100);
  const processing = Duration(milliseconds: 200);
  const tick = Duration(milliseconds: 50);

  ImportCubit build({void Function(StudyMaterial)? onImported}) => ImportCubit(
    uploadDuration: upload,
    processingDuration: processing,
    tick: tick,
    onImported: onImported,
    now: () => DateTime(2026, 10, 15),
  );

  test('starts idle', () {
    expect(build().state.status, ProcessingStatus.idle);
  });

  test('walks uploading -> processing -> ready and reports the material', () {
    fakeAsync((async) {
      StudyMaterial? imported;
      final c = build(onImported: (m) => imported = m);
      final statuses = <ProcessingStatus>[];
      c.stream.listen((s) => statuses.add(s.status));

      c.start('cell_biology-notes.pdf');
      expect(c.state.status, ProcessingStatus.uploading);
      expect(c.state.progress, 0);

      async.elapse(tick);
      expect(c.state.progress, 0.5);

      async.elapse(tick);
      expect(c.state.status, ProcessingStatus.processing);
      expect(c.state.progress, 1);

      async.elapse(processing);
      expect(c.state.status, ProcessingStatus.ready);
      expect(c.state.material?.title, 'cell biology notes');
      expect(imported, c.state.material);
      expect(statuses.last, ProcessingStatus.ready);
      c.close();
    });
  });

  test('pasted text uses its first line as the title', () {
    fakeAsync((async) {
      final c = build();
      c.start(
        'Pasted text',
        type: StudyMaterialType.pastedText,
        text: 'Photosynthesis basics\nmore body text',
      );
      async.elapse(upload + processing);
      expect(c.state.material?.title, 'Photosynthesis basics');
      expect(c.state.material?.type, StudyMaterialType.pastedText);
      c.close();
    });
  });

  test('long pasted titles are truncated', () {
    fakeAsync((async) {
      final c = build();
      c.start('x', type: StudyMaterialType.pastedText, text: 'a' * 100);
      async.elapse(upload + processing);
      expect(c.state.material!.title.length, 41); // 40 chars + ellipsis
      expect(c.state.material!.title, endsWith('…'));
      c.close();
    });
  });

  test('failNextRun fails once, then retry succeeds', () {
    fakeAsync((async) {
      var imports = 0;
      final c = build(onImported: (_) => imports++);
      c.failNextRun();
      c.start('doc.pdf');
      async.elapse(upload + processing);
      expect(c.state.status, ProcessingStatus.failed);
      expect(c.state.errorMessage, isNotNull);
      expect(imports, 0);

      c.retry();
      async.elapse(upload + processing);
      expect(c.state.status, ProcessingStatus.ready);
      expect(imports, 1);
      c.close();
    });
  });

  test('cancel stops the run and returns to idle', () {
    fakeAsync((async) {
      var imports = 0;
      final c = build(onImported: (_) => imports++);
      c.start('doc.pdf');
      async.elapse(tick);
      c.cancel();
      async.elapse(upload + processing);
      expect(c.state.status, ProcessingStatus.idle);
      expect(imports, 0);
      c.close();
    });
  });
}
