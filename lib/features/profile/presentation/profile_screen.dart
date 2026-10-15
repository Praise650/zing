import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/data/mock_data.dart';
import '../../../core/extensions/build_context_extensions.dart';
import '../../../core/utilities/validators.dart';
import '../../../core/widgets/zing_button.dart';
import '../../../core/widgets/zing_text_field.dart';
import '../../authentication/presentation/session_cubit.dart';
import '../../settings/presentation/settings_cubit.dart';
import '../../../core/widgets/zing_card.dart';
import '../../../core/widgets/zing_progress_bar.dart';
import '../../../core/widgets/zing_section_label.dart';
import '../../../core/widgets/zing_segmented.dart';
import 'theme_cubit.dart';

const _months = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _pickGoal(BuildContext context) async {
    final cubit = context.read<SettingsCubit>();
    final picked = await showDialog<int>(
      context: context,
      builder: (dialog) => SimpleDialog(
        title: const Text('Daily study goal'),
        children: [
          for (final m in SettingsCubit.goalOptions)
            SimpleDialogOption(
              onPressed: () => Navigator.of(dialog).pop(m),
              child: Text('$m min'),
            ),
        ],
      ),
    );
    if (picked != null) cubit.setDailyGoal(picked);
  }

  Future<void> _pickExam(BuildContext context, DateTime? current) async {
    final cubit = context.read<SettingsCubit>();
    final today = DateUtils.dateOnly(DateTime.now());
    final picked = await showDatePicker(
      context: context,
      initialDate: current != null && !current.isBefore(today)
          ? current
          : today,
      firstDate: today,
      lastDate: today.add(const Duration(days: 365 * 3)),
    );
    if (picked != null) cubit.setExamTarget(picked);
  }

  void _editProfile(BuildContext context) {
    final session = context.read<SessionCubit>();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheet) => _EditProfileSheet(
        initialName: session.state.name,
        initialEmail: session.state.email,
        onSave: (name, email) {
          session.updateProfile(name: name, email: email);
          Navigator.of(sheet).pop();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final t = context.text;
    final session = context.watch<SessionCubit>().state;
    final settings = context.watch<SettingsCubit>().state;
    final todayMinutes = MockData.weeklyMinutes[DateTime.now().weekday - 1];
    final goalProgress = (todayMinutes / settings.dailyGoalMinutes).clamp(
      0.0,
      1.0,
    );
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: c.primarySurface,
                  child: Text(
                    session.initial,
                    style: t.titleLarge?.copyWith(color: c.primaryDark),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        session.name,
                        style: t.titleLarge?.copyWith(fontSize: 20),
                      ),
                      Text(
                        session.email,
                        style: t.bodySmall?.copyWith(color: c.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            const ZingSectionLabel('Learning goals'),
            const SizedBox(height: 10),
            ZingCard(
              child: Column(
                spacing: 12,
                children: [
                  InkWell(
                    onTap: () => _pickGoal(context),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text('Daily study goal', style: t.bodyMedium),
                        ),
                        Text(
                          '${settings.dailyGoalMinutes} min',
                          style: t.bodyMedium?.copyWith(
                            color: c.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ZingProgressBar(value: goalProgress, height: 6),
                  InkWell(
                    onTap: () => _pickExam(context, settings.examTarget),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text('Exam target', style: t.bodyMedium),
                        ),
                        Text(
                          settings.examTarget == null
                              ? 'Set date'
                              : '${_months[settings.examTarget!.month - 1]} ${settings.examTarget!.day}',
                          style: t.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            const ZingSectionLabel('Notifications'),
            const SizedBox(height: 10),
            ZingCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Column(
                children: [
                  _SwitchRow(
                    'Daily reminder',
                    settings.dailyReminder,
                    context.read<SettingsCubit>().setDailyReminder,
                  ),
                  const Divider(),
                  _SwitchRow(
                    'Streak warnings',
                    settings.streakWarnings,
                    context.read<SettingsCubit>().setStreakWarnings,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            const ZingSectionLabel('Appearance'),
            const SizedBox(height: 10),
            ZingCard(
              child: Row(
                children: [
                  Expanded(child: Text('Theme', style: t.bodyMedium)),
                  BlocBuilder<ThemeCubit, ThemeMode>(
                    builder: (context, mode) => Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: ZingSegmented<ThemeMode>(
                          options: const {
                            ThemeMode.light: 'Light',
                            ThemeMode.dark: 'Dark',
                            ThemeMode.system: 'Auto',
                          },
                          value: mode,
                          onChanged: context.read<ThemeCubit>().setMode,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            const ZingSectionLabel('Account'),
            const SizedBox(height: 10),
            ZingCard(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _Row('Edit profile', onTap: () => _editProfile(context)),
                  const Divider(),
                  _Row(
                    'Sign out',
                    color: c.error,
                    onTap: () {
                      context.read<SessionCubit>().signOut();
                      context.go('/sign-in');
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow(this.label, this.value, this.onChanged);

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(child: Text(label, style: context.text.bodyMedium)),
      Switch(value: value, onChanged: onChanged),
    ],
  );
}

class _Row extends StatelessWidget {
  const _Row(this.label, {this.color, required this.onTap});

  final String label;
  final Color? color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: context.text.bodyMedium?.copyWith(
                color: color,
                fontWeight: color == null ? FontWeight.w400 : FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class _EditProfileSheet extends StatefulWidget {
  const _EditProfileSheet({
    required this.initialName,
    required this.initialEmail,
    required this.onSave,
  });

  final String initialName;
  final String initialEmail;
  final void Function(String name, String email) onSave;

  @override
  State<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<_EditProfileSheet> {
  late final _name = TextEditingController(text: widget.initialName);
  late final _email = TextEditingController(text: widget.initialEmail);
  bool _submitted = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    super.dispose();
  }

  String? get _nameError => _submitted ? Validators.name(_name.text) : null;
  String? get _emailError => _submitted ? Validators.email(_email.text) : null;

  void _save() {
    setState(() => _submitted = true);
    if (_nameError == null && _emailError == null) {
      widget.onSave(_name.text, _email.text);
    }
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.fromLTRB(
      20,
      24,
      20,
      20 + MediaQuery.viewInsetsOf(context).bottom,
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 16,
      children: [
        ZingTextField(
          label: 'Full name',
          controller: _name,
          textInputAction: TextInputAction.next,
          errorText: _nameError,
          onChanged: (_) => setState(() {}),
        ),
        ZingTextField(
          label: 'Email',
          controller: _email,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.done,
          errorText: _emailError,
          onChanged: (_) => setState(() {}),
          onSubmitted: (_) => _save(),
        ),
        ZingButton(label: 'Save', onPressed: _save),
      ],
    ),
  );
}
