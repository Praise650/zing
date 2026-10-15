import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_radius.dart';
import '../../../core/extensions/build_context_extensions.dart';
import '../../../core/widgets/zing_badge.dart';
import '../../../core/widgets/zing_button.dart';
import '../../../core/widgets/zing_card.dart';
import '../../../core/widgets/zing_icon_button.dart';
import '../../../core/widgets/zing_section_label.dart';
import '../../../core/widgets/zing_segmented.dart';
import '../../materials/domain/study_material.dart';

enum _DetailTab { preview, summary }

class MaterialDetailScreen extends StatefulWidget {
  const MaterialDetailScreen({super.key, required this.material});

  final StudyMaterial material;

  @override
  State<MaterialDetailScreen> createState() => _MaterialDetailScreenState();
}

class _MaterialDetailScreenState extends State<MaterialDetailScreen> {
  _DetailTab _tab = _DetailTab.summary;

  StudyMaterial get m => widget.material;

  void _toast(String message) => ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(message)));

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final t = context.text;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  ZingIconButton(
                    icon: Icons.arrow_back,
                    tooltip: 'Back',
                    onPressed: () =>
                        context.canPop() ? context.pop() : context.go('/home'),
                  ),
                  const Spacer(),
                  Icon(Icons.more_horiz, color: c.textSecondary),
                ],
              ),
              const SizedBox(height: 14),
              Text(m.title, style: t.titleLarge?.copyWith(letterSpacing: -.3)),
              const SizedBox(height: 4),
              Text(
                m.meta,
                style: t.bodySmall?.copyWith(color: c.textSecondary),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (m.hasSummary) const ZingBadge('Summary ready'),
                  if (m.flashcards.isNotEmpty)
                    ZingBadge('${m.flashcards.length} cards'),
                  if (m.questions.isNotEmpty)
                    const ZingBadge('Quiz new', tone: ZingTone.warning),
                ],
              ),
              const SizedBox(height: 14),
              ZingSegmented<_DetailTab>(
                expand: true,
                options: const {
                  _DetailTab.preview: 'Preview',
                  _DetailTab.summary: 'AI Summary',
                },
                value: _tab,
                onChanged: (v) => setState(() => _tab = v),
              ),
              const SizedBox(height: 14),
              Expanded(
                child: ZingCard(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  child: SingleChildScrollView(
                    child: _tab == _DetailTab.summary
                        ? _SummaryBody(material: m)
                        : Text(
                            'Original document preview is not available in this prototype.',
                            style: t.bodyLarge?.copyWith(
                              color: c.textSecondary,
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                spacing: 8,
                children: [
                  Expanded(
                    child: ZingButton(
                      label: 'Copy',
                      variant: ZingButtonVariant.outlined,
                      compact: true,
                      onPressed: () {
                        Clipboard.setData(
                          ClipboardData(text: m.summaryText ?? ''),
                        );
                        _toast('Summary copied');
                      },
                    ),
                  ),
                  Expanded(
                    child: ZingButton(
                      label: 'Save',
                      variant: ZingButtonVariant.outlined,
                      compact: true,
                      onPressed: () => _toast('Saved to library'),
                    ),
                  ),
                  Expanded(
                    flex: 13,
                    child: ZingButton(
                      label: 'Regenerate',
                      variant: ZingButtonVariant.tonal,
                      compact: true,
                      onPressed: () => _toast('Regenerating summary…'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                spacing: 10,
                children: [
                  Expanded(
                    child: ZingButton(
                      label: 'Flashcards',
                      icon: Icons.style_outlined,
                      onPressed: m.flashcards.isEmpty
                          ? null
                          : () => context.push('/flashcards/${m.id}'),
                    ),
                  ),
                  Expanded(
                    child: ZingButton(
                      label: 'Quiz',
                      icon: Icons.quiz_outlined,
                      onPressed: m.questions.isEmpty
                          ? null
                          : () => context.push('/quiz/${m.id}'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryBody extends StatelessWidget {
  const _SummaryBody({required this.material});
  final StudyMaterial material;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ZingSectionLabel('Overview', color: c.primary),
        const SizedBox(height: 10),
        Text(
          material.summaryText ?? 'No summary yet.',
          style: context.text.bodyLarge?.copyWith(height: 1.65),
        ),
        if (material.keyConcepts.isNotEmpty) ...[
          const SizedBox(height: 14),
          ZingSectionLabel('Key concepts', color: c.primary),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final k in material.keyConcepts)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: c.primarySurface,
                    borderRadius: AppRadius.chipAll,
                  ),
                  child: Text(
                    k,
                    style: context.text.labelMedium?.copyWith(
                      color: c.primaryDark,
                    ),
                  ),
                ),
            ],
          ),
        ],
        if (material.takeaways.isNotEmpty) ...[
          const SizedBox(height: 14),
          ZingSectionLabel('Takeaways', color: c.primary),
          const SizedBox(height: 10),
          for (final t in material.takeaways)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '•',
                    style: context.text.bodyMedium?.copyWith(color: c.primary),
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: Text(t, style: context.text.bodyMedium)),
                ],
              ),
            ),
        ],
      ],
    );
  }
}
