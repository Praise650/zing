import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:zing/features/profile/presentation/theme_cubit.dart';

import '../../helpers/in_memory_storage.dart';

void main() {
  setUp(() => HydratedBloc.storage = InMemoryStorage());

  blocTest<ThemeCubit, ThemeMode>(
    'starts light and switches mode',
    build: () => ThemeCubit(),
    act: (c) => c.setMode(ThemeMode.dark),
    expect: () => [ThemeMode.dark],
  );

  test('restores the saved mode', () async {
    final c = ThemeCubit()..setMode(ThemeMode.system);
    await c.close();
    expect(ThemeCubit().state, ThemeMode.system);
  });

  test('unknown stored value is ignored', () {
    expect(ThemeCubit().fromJson({'mode': 'neon'}), isNull);
  });
}
