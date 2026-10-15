import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_shadows.dart';
import '../../../core/extensions/build_context_extensions.dart';
import '../../../core/widgets/zing_button.dart';
import '../../../core/widgets/zing_icon_button.dart';
import '../../../core/widgets/zing_progress_bar.dart';
import '../../../core/widgets/zing_section_label.dart';
import '../domain/flashcard.dart';
import 'flashcard_cubit.dart';

/// Focus mode: no bottom navigation, close control and progress meter.
class FlashcardScreen extends StatelessWidget {
  const FlashcardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<FlashcardCubit, FlashcardState>(
          builder: (context, state) {
            if (state.isFinished) return const _Finished();
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Column(
                children: [
                  Row(
                    children: [
                      ZingIconButton(
                        icon: Icons.close,
                        tooltip: 'Close',
                        onPressed: () => context.canPop()
                            ? context.pop()
                            : context.go('/home'),
                      ),
                      const SizedBox(width: 14),
                      Expanded(child: ZingProgressBar(value: state.progress)),
                      const SizedBox(width: 14),
                      Text(
                        '${state.index + 1}/${state.total}',
                        style: context.text.labelMedium?.copyWith(
                          color: context.colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Expanded(
                    // Keyed so the flip state resets for every new card.
                    child: FlipCard(
                      key: ValueKey(state.current!.id),
                      card: state.current!,
                    ),
                  ),
                  const SizedBox(height: 18),
                  const _RatingBar(),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Flip animation lives in local state so only this card rebuilds.
class FlipCard extends StatefulWidget {
  const FlipCard({super.key, required this.card});

  final Flashcard card;

  @override
  State<FlipCard> createState() => _FlipCardState();
}

class _FlipCardState extends State<FlipCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 500),
  );

  void _flip() => _ctrl.isCompleted || _ctrl.velocity > 0
      ? _ctrl.reverse()
      : _ctrl.forward();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Flashcard. Tap to flip.',
      child: GestureDetector(
        onTap: _flip,
        child: AnimatedBuilder(
          animation: _ctrl,
          builder: (context, _) {
            final angle = Curves.easeInOut.transform(_ctrl.value) * math.pi;
            final showBack = angle > math.pi / 2;
            return Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateY(angle),
              child: showBack
                  ? Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.rotationY(math.pi),
                      child: _Face(card: widget.card, back: true),
                    )
                  : _Face(card: widget.card, back: false),
            );
          },
        ),
      ),
    );
  }
}

class _Face extends StatelessWidget {
  const _Face({required this.card, required this.back});

  final Flashcard card;
  final bool back;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final t = context.text;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: back ? c.primarySurface : c.surface,
        borderRadius: AppRadius.sheetAll,
        border: Border.all(
          color: back ? c.secondary.withValues(alpha: .4) : c.border,
        ),
        boxShadow: AppShadows.level2(c.shadow),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ZingSectionLabel(
            back ? 'Answer' : 'Question',
            color: back ? c.primaryDark : c.primary,
          ),
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: back
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          card.answer,
                          style: t.displayMedium?.copyWith(
                            color: c.primaryDark,
                          ),
                        ),
                        if (card.explanation != null) ...[
                          const SizedBox(height: 12),
                          Text(card.explanation!, style: t.bodyLarge),
                        ],
                      ],
                    )
                  : Text(
                      card.question,
                      style: t.headlineMedium?.copyWith(height: 1.3),
                    ),
            ),
          ),
          Center(
            child: Text(
              back ? 'Tap to flip back' : 'Tap to flip',
              style: t.bodySmall?.copyWith(
                color: back ? c.primaryDark : c.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RatingBar extends StatelessWidget {
  const _RatingBar();

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final items = [
      (ConfidenceRating.again, 'Again', '1 min', c.errorSurface, c.errorText),
      (ConfidenceRating.hard, 'Hard', '1 day', c.warningSurface, c.warningText),
      (ConfidenceRating.good, 'Good', '3 days', c.infoSurface, c.infoText),
      (
        ConfidenceRating.easy,
        'Easy',
        '7 days',
        c.successSurface,
        c.successText,
      ),
    ];
    return Row(
      spacing: 8,
      children: [
        for (final (rating, label, interval, bg, fg) in items)
          Expanded(
            child: Material(
              color: bg,
              borderRadius: AppRadius.buttonAll,
              child: InkWell(
                borderRadius: AppRadius.buttonAll,
                onTap: () => context.read<FlashcardCubit>().rate(rating),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Column(
                    children: [
                      Text(
                        label,
                        style: context.text.labelMedium?.copyWith(color: fg),
                      ),
                      Text(
                        interval,
                        style: context.text.labelSmall?.copyWith(
                          color: fg,
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _Finished extends StatelessWidget {
  const _Finished();

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final state = context.watch<FlashcardCubit>().state;
    final easy = state.cards
        .where(
          (x) =>
              x.lastRating == ConfidenceRating.good ||
              x.lastRating == ConfidenceRating.easy,
        )
        .length;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: c.successSurface,
              borderRadius: BorderRadius.circular(28),
            ),
            child: Icon(Icons.check_rounded, size: 44, color: c.success),
          ),
          const SizedBox(height: 20),
          Text('Deck complete', style: context.text.headlineMedium),
          const SizedBox(height: 8),
          Text(
            'You knew $easy of ${state.total} cards well.',
            style: context.text.bodyLarge?.copyWith(color: c.textSecondary),
          ),
          const SizedBox(height: 28),
          ZingButton(
            label: 'Review again',
            onPressed: context.read<FlashcardCubit>().restart,
          ),
          const SizedBox(height: 10),
          ZingButton(
            label: 'Done',
            variant: ZingButtonVariant.outlined,
            onPressed: () =>
                context.canPop() ? context.pop() : context.go('/home'),
          ),
        ],
      ),
    );
  }
}
