import 'package:flutter_test/flutter_test.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:zing/core/data/mock_data.dart';
import 'package:zing/features/materials/domain/study_material.dart';
import 'package:zing/features/materials/presentation/materials_cubit.dart';

import '../../helpers/in_memory_storage.dart';

void main() {
  late InMemoryStorage storage;

  setUp(() {
    storage = InMemoryStorage();
    HydratedBloc.storage = storage;
  });

  final newOne = StudyMaterial(
    id: 'new',
    title: 'New',
    type: StudyMaterialType.note,
    createdAt: DateTime(2026),
    lastAccessed: DateTime(2026),
  );

  test('add puts the newest material first', () {
    final c = MaterialsCubit(seed: MockData.materials)..add(newOne);
    expect(c.state.materials.first, newOne);
    expect(c.state.materials.length, MockData.materials.length + 1);
  });

  test('find returns a material by id, or null', () {
    final c = MaterialsCubit(seed: MockData.materials)..add(newOne);
    expect(c.find('new'), newOne);
    expect(c.find('missing'), isNull);
  });

  test('state survives a restart through hydrated storage', () async {
    final c = MaterialsCubit()..add(newOne);
    await c.close();

    final restored = MaterialsCubit();
    expect(restored.state.materials, [newOne]);
  });

  test('seed is only used when nothing is stored', () async {
    final c = MaterialsCubit(seed: MockData.materials)..add(newOne);
    await c.close();

    final restored = MaterialsCubit(seed: MockData.materials);
    expect(restored.state.materials.first, newOne);
  });
}
