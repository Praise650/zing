import 'package:flutter_test/flutter_test.dart';
import 'package:zing/core/data/mock_data.dart';
import 'package:zing/features/materials/domain/study_material.dart';

void main() {
  test('every mock material survives a JSON round trip', () {
    for (final m in MockData.materials) {
      final back = StudyMaterial.fromJson(m.toJson());
      expect(back, m, reason: m.title);
      expect(back.flashcards, m.flashcards);
      expect(back.questions, m.questions);
      expect(back.keyConcepts, m.keyConcepts);
    }
  });

  test('fromJson tolerates missing optional fields', () {
    final m = StudyMaterial.fromJson({
      'id': '1',
      'title': 't',
      'type': 'pdf',
      'createdAt': '2026-01-01T00:00:00.000',
      'lastAccessed': '2026-01-01T00:00:00.000',
      'status': 'ready',
    });
    expect(m.meta, '');
    expect(m.summaryText, isNull);
    expect(m.flashcards, isEmpty);
    expect(m.hasSummary, isFalse);
  });

  test('hasSummary is false for an empty summary', () {
    final m = StudyMaterial(
      id: '1',
      title: 't',
      type: StudyMaterialType.note,
      createdAt: DateTime(2026),
      lastAccessed: DateTime(2026),
      summaryText: '',
    );
    expect(m.hasSummary, isFalse);
  });
}
