import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zing/core/data/mock_data.dart';
import 'package:zing/features/library/presentation/library_cubit.dart';
import 'package:zing/features/materials/domain/study_material.dart';

StudyMaterial _m(
  String id,
  String title,
  StudyMaterialType type, {
  String? summary,
}) => StudyMaterial(
  id: id,
  title: title,
  type: type,
  createdAt: DateTime(2026),
  lastAccessed: DateTime(2026),
  summaryText: summary,
);

void main() {
  final materials = [
    _m('1', 'Cell Biology', StudyMaterialType.pdf, summary: 'Mitochondria'),
    _m('2', 'History Notes', StudyMaterialType.note),
    _m('3', 'Pasted essay', StudyMaterialType.pastedText),
  ];

  LibraryCubit build() => LibraryCubit(materials);

  test('shows everything by default', () {
    expect(build().state.visible, materials);
  });

  test('search matches title case-insensitively and trims', () {
    final c = build()..search('  HISTORY ');
    expect(c.state.visible.map((m) => m.id), ['2']);
  });

  test('search also matches summary text', () {
    final c = build()..search('mitochon');
    expect(c.state.visible.map((m) => m.id), ['1']);
  });

  test('notes filter includes pasted text', () {
    final c = build()..setFilter(LibraryFilter.notes);
    expect(c.state.visible.map((m) => m.id), ['2', '3']);
  });

  test('pdfs, summaries and cards filters', () {
    final c = build()..setFilter(LibraryFilter.pdfs);
    expect(c.state.visible.map((m) => m.id), ['1']);
    c.setFilter(LibraryFilter.summaries);
    expect(c.state.visible.map((m) => m.id), ['1']);
    c.setFilter(LibraryFilter.flashcards);
    expect(c.state.visible, isEmpty);
  });

  test('filter and query combine', () {
    final c = build()
      ..setFilter(LibraryFilter.notes)
      ..search('essay');
    expect(c.state.visible.map((m) => m.id), ['3']);
  });

  blocTest<LibraryCubit, LibraryState>(
    'setGrid toggles layout',
    build: build,
    act: (c) => c.setGrid(false),
    verify: (c) => expect(c.state.grid, isFalse),
  );

  blocTest<LibraryCubit, LibraryState>(
    'setMaterials replaces the list but keeps query and filter',
    build: build,
    seed: () => LibraryState(materials: materials, query: 'x'),
    act: (c) => c.setMaterials(MockData.materials),
    verify: (c) {
      expect(c.state.materials, MockData.materials);
      expect(c.state.query, 'x');
    },
  );
}
