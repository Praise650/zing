import 'package:flutter/material.dart';

import '../../../app/theme/app_radius.dart';
import '../../../core/data/mock_data.dart';
import '../../../core/extensions/build_context_extensions.dart';
import '../../../core/utilities/formatters.dart';
import '../../../core/widgets/zing_card.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final t = context.text;
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: [
            Text('Progress', style: t.headlineLarge),
            const SizedBox(height: 14),
            IntrinsicHeight(
              child: Row(
                spacing: 12,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _Metric('Study time', Formatters.studyTime(760)),
                  _Metric('Avg quiz score', '82%', valueColor: c.success),
                ],
              ),
            ),
            const SizedBox(height: 12),
            IntrinsicHeight(
              child: Row(
                spacing: 12,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _Metric(
                    'Current streak',
                    '7 days',
                    bg: c.warningSurface,
                    labelColor: c.warningText,
                    valueColor: c.warningText,
                  ),
                  const _Metric('Longest streak', '21 days'),
                ],
              ),
            ),
            const SizedBox(height: 14),
            ZingCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text('This week', style: t.titleSmall.sized(15)),
                      ),
                      Text(
                        'minutes',
                        style: t.labelSmall?.copyWith(
                          color: c.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const _WeekChart(minutes: MockData.weeklyMinutes),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Text('Recent achievements', style: t.titleSmall),
            const SizedBox(height: 14),
            Row(
              spacing: 10,
              children: [
                _Badge(
                  Icons.local_fire_department,
                  '7 day streak',
                  c.warningSurface,
                  c.warning,
                ),
                _Badge(Icons.style, '100 cards', c.successSurface, c.success),
                _Badge(
                  Icons.emoji_events,
                  'Quiz 90%+',
                  c.primarySurface,
                  c.primary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

extension on TextStyle? {
  TextStyle? sized(double s) => this?.copyWith(fontSize: s);
}

class _Metric extends StatelessWidget {
  const _Metric(
    this.label,
    this.value, {
    this.bg,
    this.labelColor,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? bg;
  final Color? labelColor;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Expanded(
      child: ZingCard(
        color: bg,
        bordered: bg == null,
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: context.text.labelSmall?.copyWith(
                color: labelColor ?? c.textSecondary,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: context.text.headlineMedium?.copyWith(color: valueColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WeekChart extends StatelessWidget {
  const _WeekChart({required this.minutes});

  final List<int> minutes;
  static const _days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
  static const _maxBar = 96.0;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final peak = minutes.reduce((a, b) => a > b ? a : b);
    return SizedBox(
      height: 120,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        spacing: 10,
        children: [
          for (var i = 0; i < minutes.length; i++)
            Expanded(
              child: Semantics(
                label: '${_days[i]}: ${minutes[i]} minutes',
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      height: minutes[i] / peak * _maxBar,
                      decoration: BoxDecoration(
                        color: minutes[i] == peak
                            ? c.primary
                            : c.primary.withValues(alpha: .35),
                        borderRadius: AppRadius.chipAll,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _days[i],
                      style: context.text.labelSmall?.copyWith(
                        color: c.textSecondary,
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge(this.icon, this.label, this.bg, this.fg);

  final IconData icon;
  final String label;
  final Color bg;
  final Color fg;

  @override
  Widget build(BuildContext context) => Expanded(
    child: ZingCard(
      radius: AppRadius.tileAll,
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
            child: Icon(icon, size: 18, color: fg),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            style: context.text.labelSmall,
          ),
        ],
      ),
    ),
  );
}
