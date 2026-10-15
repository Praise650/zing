import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

class SettingsState extends Equatable {
  const SettingsState({
    this.dailyReminder = true,
    this.streakWarnings = true,
    this.dailyGoalMinutes = 30,
    this.examTarget,
  });

  final bool dailyReminder;
  final bool streakWarnings;
  final int dailyGoalMinutes;
  final DateTime? examTarget;

  @override
  List<Object?> get props => [
    dailyReminder,
    streakWarnings,
    dailyGoalMinutes,
    examTarget,
  ];
}

class SettingsCubit extends HydratedCubit<SettingsState> {
  SettingsCubit()
    : super(SettingsState(examTarget: DateTime(DateTime.now().year, 12, 12)));

  static const goalOptions = [15, 30, 45, 60, 90];

  SettingsState _with({
    bool? dailyReminder,
    bool? streakWarnings,
    int? dailyGoalMinutes,
    DateTime? examTarget,
  }) => SettingsState(
    dailyReminder: dailyReminder ?? state.dailyReminder,
    streakWarnings: streakWarnings ?? state.streakWarnings,
    dailyGoalMinutes: dailyGoalMinutes ?? state.dailyGoalMinutes,
    examTarget: examTarget ?? state.examTarget,
  );

  void setDailyReminder(bool v) => emit(_with(dailyReminder: v));
  void setStreakWarnings(bool v) => emit(_with(streakWarnings: v));
  void setDailyGoal(int minutes) => emit(_with(dailyGoalMinutes: minutes));
  void setExamTarget(DateTime date) => emit(_with(examTarget: date));

  @override
  SettingsState? fromJson(Map<String, dynamic> json) {
    final exam = json['examTarget'] as String?;
    return SettingsState(
      dailyReminder: json['dailyReminder'] as bool? ?? true,
      streakWarnings: json['streakWarnings'] as bool? ?? true,
      dailyGoalMinutes: json['dailyGoalMinutes'] as int? ?? 30,
      examTarget: exam == null ? null : DateTime.tryParse(exam),
    );
  }

  @override
  Map<String, dynamic> toJson(SettingsState state) => {
    'dailyReminder': state.dailyReminder,
    'streakWarnings': state.streakWarnings,
    'dailyGoalMinutes': state.dailyGoalMinutes,
    'examTarget': state.examTarget?.toIso8601String(),
  };
}
