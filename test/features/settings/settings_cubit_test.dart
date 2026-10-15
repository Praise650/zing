import 'package:flutter_test/flutter_test.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:zing/features/settings/presentation/settings_cubit.dart';

import '../../helpers/in_memory_storage.dart';

void main() {
  setUp(() => HydratedBloc.storage = InMemoryStorage());

  test('defaults', () {
    final s = SettingsCubit().state;
    expect(s.dailyReminder, isTrue);
    expect(s.streakWarnings, isTrue);
    expect(s.dailyGoalMinutes, 30);
    expect(s.examTarget, isNotNull);
  });

  test('each setter changes only its own field', () {
    final c = SettingsCubit();
    final exam = c.state.examTarget;
    c.setDailyReminder(false);
    expect(c.state.dailyReminder, isFalse);
    expect(c.state.streakWarnings, isTrue);
    expect(c.state.examTarget, exam);

    c.setDailyGoal(60);
    expect(c.state.dailyGoalMinutes, 60);
    expect(c.state.dailyReminder, isFalse);

    c.setExamTarget(DateTime(2027, 1, 2));
    expect(c.state.examTarget, DateTime(2027, 1, 2));
  });

  test('goalOptions contains the default goal', () {
    expect(SettingsCubit.goalOptions, contains(30));
  });

  test('persists and restores all fields', () async {
    final c = SettingsCubit()
      ..setStreakWarnings(false)
      ..setDailyGoal(90)
      ..setExamTarget(DateTime(2027, 5, 6));
    await c.close();
    expect(SettingsCubit().state, c.state);
  });

  test('fromJson falls back to defaults for missing keys', () {
    final s = SettingsCubit().fromJson({});
    expect(s, const SettingsState());
  });

  test('fromJson ignores an unparseable exam date', () {
    expect(
      SettingsCubit().fromJson({'examTarget': 'nope'})?.examTarget,
      isNull,
    );
  });
}
