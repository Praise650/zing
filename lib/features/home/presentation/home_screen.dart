import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_shadows.dart';
import '../../../core/extensions/build_context_extensions.dart';
import '../../../core/utilities/formatters.dart';
import '../../../core/widgets/zing_badge.dart';
import '../../../core/widgets/zing_button.dart';
import '../../../core/widgets/zing_card.dart';
import '../../../core/widgets/zing_progress_bar.dart';
import '../../authentication/presentation/session_cubit.dart';
import '../../materials/domain/study_material.dart';
import '../../materials/presentation/materials_cubit.dart';
import '../../materials/presentation/material_type_style.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, this.userName, DateTime? now}) : _now = now;

  /// Overrides the signed-in user's first name.
  final String? userName;
  final DateTime? _now;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final materials = context.watch<MaterialsCubit>().state.materials;
    final session = context.watch<SessionCubit>().state;
    final name =
        userName ?? (session.name.isEmpty ? 'there' : session.firstName);
    final initial = userName?.substring(0, 1) ?? session.initial;
    final recent = materials.take(3).toList();
    final continueMaterial = materials.firstWhere(
      (m) => m.flashcards.isNotEmpty,
      orElse: () => materials.first,
    );
    final studyId = continueMaterial.id;
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/add-material'),
        backgroundColor: c.primary,
        foregroundColor: c.onPrimary,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        icon: const Icon(Icons.add),
        label: Text(
          'Add material',
          style: context.text.labelLarge?.copyWith(color: c.onPrimary),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 96),
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        Formatters.greeting(_now ?? DateTime.now()),
                        style: context.text.bodySmall?.copyWith(
                          color: c.textSecondary,
                        ),
                      ),
                      Text(name, style: context.text.headlineMedium),
                    ],
                  ),
                ),
                const _StreakPill(days: 7),
                const SizedBox(width: 10),
                Semantics(
                  label: 'Open profile',
                  button: true,
                  child: GestureDetector(
                    onTap: () => context.go('/profile'),
                    child: CircleAvatar(
                      radius: 20,
                      backgroundColor: c.primarySurface,
                      child: Text(
                        initial,
                        style: context.text.titleSmall?.copyWith(
                          color: c.primaryDark,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            const Row(
              spacing: 10,
              children: [
                _StatTile(value: '12h', label: 'This month'),
                _StatTile(value: '82%', label: 'Quiz avg'),
                _StatTile(value: '3', label: 'Due today'),
              ],
            ),
            const SizedBox(height: 18),
            _ContinueCard(material: continueMaterial),
            const SizedBox(height: 18),
            Row(
              spacing: 10,
              children: [
                _QuickAction(
                  label: 'Summarize',
                  icon: Icons.auto_awesome,
                  bg: c.primarySurface,
                  fg: c.primary,
                  onTap: () => context.push('/material/$studyId'),
                ),
                _QuickAction(
                  label: 'Flashcards',
                  icon: Icons.style_outlined,
                  bg: c.successSurface,
                  fg: c.success,
                  onTap: () => context.push('/flashcards/$studyId'),
                ),
                _QuickAction(
                  label: 'Quiz',
                  icon: Icons.quiz_outlined,
                  bg: c.warningSurface,
                  fg: c.warningText,
                  onTap: () => context.push('/quiz/$studyId'),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Expanded(
                  child: Text('Recent', style: context.text.titleMedium),
                ),
                GestureDetector(
                  onTap: () => context.go('/library'),
                  child: Text(
                    'See all',
                    style: context.text.labelMedium?.copyWith(color: c.primary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            for (final m in recent) ...[
              _RecentTile(material: m),
              const SizedBox(height: 10),
            ],
          ],
        ),
      ),
    );
  }
}

class _StreakPill extends StatelessWidget {
  const _StreakPill({required this.days});
  final int days;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: c.warningSurface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: c.warning, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            '$days days',
            style: context.text.labelMedium?.copyWith(
              color: c.warningText,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) => Expanded(
    child: ZingCard(
      radius: AppRadius.tileAll,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: context.text.titleLarge?.copyWith(fontSize: 20)),
          Text(
            label,
            style: context.text.labelSmall?.copyWith(
              color: context.colors.textSecondary,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    ),
  );
}

class _ContinueCard extends StatelessWidget {
  const _ContinueCard({required this.material});
  final StudyMaterial material;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    // Light tint of the on-primary color keeps the text legible in both themes.
    final soft = c.onPrimary.withValues(alpha: .8);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: c.primary,
        borderRadius: AppRadius.cardAll,
        boxShadow: AppShadows.glow(c.primary),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'CONTINUE STUDYING',
            style: context.text.labelSmall?.copyWith(color: soft),
          ),
          const SizedBox(height: 6),
          Text(
            material.title,
            style: context.text.titleMedium?.copyWith(
              color: c.onPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Flashcards · 14 of 24 done',
            style: context.text.bodySmall?.copyWith(color: soft),
          ),
          const SizedBox(height: 14),
          ZingProgressBar(
            value: 14 / 24,
            height: 6,
            track: c.onPrimary.withValues(alpha: .25),
            fill: c.onPrimary,
          ),
          const SizedBox(height: 14),
          ZingButton(
            label: 'Resume',
            variant: ZingButtonVariant.tonal,
            compact: true,
            onPressed: () => context.push('/flashcards/${material.id}'),
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.label,
    required this.icon,
    required this.bg,
    required this.fg,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color bg;
  final Color fg;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Expanded(
    child: ZingCard(
      radius: AppRadius.tileAll,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: fg),
          ),
          const SizedBox(height: 8),
          Text(label, style: context.text.labelMedium),
        ],
      ),
    ),
  );
}

class _RecentTile extends StatelessWidget {
  const _RecentTile({required this.material});
  final StudyMaterial material;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final style = MaterialTypeStyle.of(material.type, c);
    return ZingCard(
      radius: AppRadius.tileAll,
      padding: const EdgeInsets.all(12),
      onTap: () => context.push('/material/${material.id}'),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: style.bg,
              borderRadius: AppRadius.smallAll,
            ),
            child: Icon(style.icon, size: 20, color: style.fg),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(material.title, style: context.text.labelLarge),
                Text(
                  material.meta,
                  style: context.text.labelSmall?.copyWith(
                    color: c.textSecondary,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          const ZingBadge('Ready', small: true),
        ],
      ),
    );
  }
}
