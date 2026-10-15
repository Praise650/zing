import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_shadows.dart';
import '../../../core/extensions/build_context_extensions.dart';
import '../../../core/utilities/formatters.dart';
import '../../../core/widgets/zing_button.dart';
import '../../../core/widgets/zing_card.dart';
import '../../../core/widgets/zing_icon_button.dart';
import 'quiz_cubit.dart';

void _leave(BuildContext context) =>
    context.canPop() ? context.pop() : context.go('/home');

class QuizScreen extends StatelessWidget {
  const QuizScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<QuizCubit, QuizState>(
          builder: (context, state) =>
              state.finished ? const _QuizResult() : const _QuizQuestion(),
        ),
      ),
    );
  }
}

class _QuizQuestion extends StatelessWidget {
  const _QuizQuestion();

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final cubit = context.read<QuizCubit>();
    final s = context.watch<QuizCubit>().state;
    final q = s.current;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ZingIconButton(
                icon: Icons.close,
                tooltip: 'Close',
                onPressed: () => _leave(context),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  'Question ${s.index + 1} of ${s.questions.length}',
                  style: context.text.labelLarge,
                ),
              ),
              Row(
                spacing: 3,
                children: [
                  for (var i = 0; i < s.questions.length; i++)
                    Container(
                      width: 14,
                      height: 4,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                        color: i < s.answers.length
                            ? (s.answers[i] == s.questions[i].correctOptionIndex
                                  ? c.success
                                  : c.error)
                            : i == s.index
                            ? c.primary
                            : c.border,
                      ),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(q.question, style: context.text.displaySmall),
          const SizedBox(height: 18),
          for (var i = 0; i < q.options.length; i++) ...[
            _OptionTile(
              index: i,
              text: q.options[i],
              selected: s.selected == i,
              answered: s.answered,
              correct: i == q.correctOptionIndex,
              onTap: () => cubit.select(i),
            ),
            const SizedBox(height: 10),
          ],
          if (s.answered)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: s.currentCorrect ? c.successSurface : c.errorSurface,
                borderRadius: AppRadius.tileAll,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    s.currentCorrect
                        ? 'Correct'
                        : 'Not quite. The answer is ${q.options[q.correctOptionIndex]}.',
                    style: context.text.labelLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (q.explanation.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(q.explanation, style: context.text.bodySmall),
                  ],
                ],
              ),
            ),
          const Spacer(),
          ZingButton(
            label: s.answered
                ? (s.isLast ? 'See results' : 'Next question')
                : 'Check answer',
            onPressed: s.answered
                ? cubit.next
                : (s.selected == null ? null : cubit.check),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.index,
    required this.text,
    required this.selected,
    required this.answered,
    required this.correct,
    required this.onTap,
  });

  final int index;
  final String text;
  final bool selected;
  final bool answered;
  final bool correct;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    var bg = c.surface,
        border = c.border,
        badgeBg = c.background,
        badgeFg = c.textSecondary;
    var mark = 'ABCD'[index];
    if (answered && correct) {
      (bg, border, badgeBg, badgeFg, mark) = (
        c.successSurface,
        c.success,
        c.success,
        c.onPrimary,
        '✓',
      );
    } else if (answered && selected) {
      (bg, border, badgeBg, badgeFg, mark) = (
        c.errorSurface,
        c.error,
        c.error,
        c.onPrimary,
        '✕',
      );
    } else if (selected) {
      (bg, border, badgeBg, badgeFg) = (
        c.primarySurface,
        c.primary,
        c.primary,
        c.onPrimary,
      );
    }
    return Semantics(
      button: true,
      selected: selected,
      child: Material(
        color: bg,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.tileAll,
          side: BorderSide(color: border, width: 1.5),
        ),
        child: InkWell(
          borderRadius: AppRadius.tileAll,
          onTap: answered ? null : onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
            child: Row(
              children: [
                Container(
                  width: 26,
                  height: 26,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: badgeBg,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    mark,
                    style: context.text.labelSmall?.copyWith(
                      color: badgeFg,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    text,
                    style: context.text.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _QuizResult extends StatelessWidget {
  const _QuizResult();

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final cubit = context.read<QuizCubit>();
    final s = context.watch<QuizCubit>().state;
    final total = s.questions.length;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Column(
        children: [
          Row(
            children: [
              ZingIconButton(
                icon: Icons.close,
                tooltip: 'Close',
                onPressed: () => _leave(context),
              ),
              const SizedBox(width: 14),
              Text('Quiz complete', style: context.text.labelLarge),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
            decoration: BoxDecoration(
              color: c.surface,
              borderRadius: AppRadius.sheetAll,
              border: Border.all(color: c.border),
              boxShadow: AppShadows.level2(c.shadow),
            ),
            child: Column(
              children: [
                SizedBox(
                  width: 132,
                  height: 132,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox.expand(
                        child: CircularProgressIndicator(
                          value: s.scorePercent / 100,
                          strokeWidth: 14,
                          backgroundColor: c.primarySurface,
                          color: c.primary,
                          strokeCap: StrokeCap.butt,
                        ),
                      ),
                      Text(
                        '${s.correctCount}/$total',
                        style: context.text.displayLarge,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'Great work, Alex',
                  style: context.text.titleLarge?.copyWith(fontSize: 20),
                ),
                const SizedBox(height: 4),
                Text(
                  '${Formatters.percent(s.correctCount, total)}% correct',
                  style: context.text.bodyMedium?.copyWith(
                    color: c.textSecondary,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  spacing: 10,
                  children: [
                    _Stat(
                      '${s.correctCount}',
                      'Correct',
                      c.successSurface,
                      c.success,
                      c.successText,
                    ),
                    _Stat(
                      '${s.missedCount}',
                      'Missed',
                      c.errorSurface,
                      c.error,
                      c.errorText,
                    ),
                    _Stat(
                      '$total',
                      'Questions',
                      c.primarySurface,
                      c.primary,
                      c.primaryDark,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          ZingCard(
            radius: AppRadius.tileAll,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Review ${s.missedCount} missed questions',
                    style: context.text.bodyMedium,
                  ),
                ),
                Text(
                  'View',
                  style: context.text.labelMedium?.copyWith(color: c.primary),
                ),
              ],
            ),
          ),
          const Spacer(),
          ZingButton(label: 'Retake quiz', onPressed: cubit.retake),
          const SizedBox(height: 10),
          ZingButton(
            label: 'Back to material',
            variant: ZingButtonVariant.outlined,
            onPressed: () => _leave(context),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat(this.value, this.label, this.bg, this.fg, this.labelColor);

  final String value;
  final String label;
  final Color bg;
  final Color fg;
  final Color labelColor;

  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: bg, borderRadius: AppRadius.buttonAll),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: context.text.titleLarge?.copyWith(fontSize: 20, color: fg),
          ),
          Text(
            label,
            style: context.text.labelSmall?.copyWith(
              color: labelColor,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    ),
  );
}
