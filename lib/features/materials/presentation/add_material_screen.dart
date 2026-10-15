import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_radius.dart';
import '../../../core/extensions/build_context_extensions.dart';
import '../../../core/widgets/zing_badge.dart';
import '../../../core/widgets/zing_button.dart';
import '../../../core/widgets/zing_card.dart';
import '../../../core/widgets/zing_icon_button.dart';
import '../../../core/widgets/zing_progress_bar.dart';
import '../../../core/widgets/zing_text_field.dart';
import '../domain/study_material.dart';
import 'import_cubit.dart';

class AddMaterialScreen extends StatelessWidget {
  const AddMaterialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final cubit = context.read<ImportCubit>();
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          children: [
            Row(
              children: [
                ZingIconButton(
                  icon: Icons.arrow_back,
                  tooltip: 'Back',
                  onPressed: () =>
                      context.canPop() ? context.pop() : context.go('/home'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text('Add material', style: context.text.titleLarge),
                ),
              ],
            ),
            const SizedBox(height: 16),
            BlocBuilder<ImportCubit, ImportState>(
              builder: (context, state) {
                if (state.status != ProcessingStatus.idle) {
                  return _ImportStatus(state: state);
                }
                return _DropZone(
                  onChoose: () => cubit.start('Biology_Ch4.pdf'),
                );
              },
            ),
            const SizedBox(height: 16),
            IntrinsicHeight(
              child: Row(
                spacing: 12,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _SourceCard(
                    icon: Icons.content_paste,
                    bg: c.infoSurface,
                    fg: c.info,
                    title: 'Paste text',
                    subtitle: 'Notes or articles',
                    onTap: () => _showPasteSheet(context, cubit),
                  ),
                  _SourceCard(
                    icon: Icons.cloud_download_outlined,
                    bg: c.successSurface,
                    fg: c.success,
                    title: 'Import file',
                    subtitle: 'Drive, iCloud',
                    onTap: () => cubit.start('Imported_notes.pdf'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            ZingCard(
              onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Camera scanning is coming soon.'),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: c.warningSurface,
                      borderRadius: AppRadius.smallAll,
                    ),
                    child: Icon(
                      Icons.photo_camera_outlined,
                      size: 20,
                      color: c.warningText,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Scan with camera',
                          style: context.text.titleSmall.withSize(15),
                        ),
                        Text(
                          'Handwritten notes and textbook pages',
                          style: context.text.labelSmall?.copyWith(
                            color: c.textSecondary,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Files are processed to create a summary, flashcards and a quiz. You can edit anything afterwards.',
              style: context.text.bodySmall?.copyWith(
                color: c.textSecondary,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPasteSheet(BuildContext context, ImportCubit cubit) {
    final controller = TextEditingController();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheet) => Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          24,
          20,
          20 + MediaQuery.viewInsetsOf(sheet).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ZingTextField(
              label: 'Paste your text',
              hint: 'Paste notes or an article here',
              controller: controller,
              maxLines: 6,
            ),
            const SizedBox(height: 16),
            ValueListenableBuilder(
              valueListenable: controller,
              builder: (_, value, _) => ZingButton(
                label: 'Create study set',
                onPressed: value.text.trim().isEmpty
                    ? null
                    : () {
                        Navigator.of(sheet).pop();
                        cubit.start(
                          'Pasted text',
                          type: StudyMaterialType.pastedText,
                          text: value.text,
                        );
                      },
              ),
            ),
          ],
        ),
      ),
    ).whenComplete(controller.dispose);
  }
}

extension on TextStyle? {
  TextStyle? withSize(double size) => this?.copyWith(fontSize: size);
}

class _DropZone extends StatelessWidget {
  const _DropZone({required this.onChoose});
  final VoidCallback onChoose;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      decoration: BoxDecoration(
        color: c.primarySurface,
        borderRadius: AppRadius.cardAll,
        border: Border.all(color: c.secondary, width: 2),
      ),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: c.primary,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(Icons.upload, color: c.onPrimary),
          ),
          const SizedBox(height: 12),
          Text('Upload PDF or document', style: context.text.titleSmall),
          const SizedBox(height: 4),
          Text(
            'PDF, DOCX, TXT · up to 50 MB',
            style: context.text.bodySmall?.copyWith(color: c.textSecondary),
          ),
          const SizedBox(height: 16),
          ZingButton(
            label: 'Choose file',
            expand: false,
            compact: true,
            onPressed: onChoose,
          ),
        ],
      ),
    );
  }
}

class _SourceCard extends StatelessWidget {
  const _SourceCard({
    required this.icon,
    required this.bg,
    required this.fg,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color bg;
  final Color fg;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Expanded(
    child: ZingCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: AppRadius.smallAll,
            ),
            child: Icon(icon, size: 20, color: fg),
          ),
          const SizedBox(height: 12),
          Text(title, style: context.text.titleSmall?.copyWith(fontSize: 15)),
          Text(
            subtitle,
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

/// Uploading -> processing -> ready / failed cards.
class _ImportStatus extends StatelessWidget {
  const _ImportStatus({required this.state});
  final ImportState state;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final cubit = context.read<ImportCubit>();
    final t = context.text;
    final file = Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: c.errorSurface,
            borderRadius: AppRadius.smallAll,
          ),
          child: Icon(Icons.picture_as_pdf_outlined, size: 20, color: c.error),
        ),
        const SizedBox(width: 12),
        Expanded(child: Text(state.fileName ?? '', style: t.labelLarge)),
      ],
    );

    switch (state.status) {
      case ProcessingStatus.uploading:
        final pct = (state.progress * 100).round();
        return ZingCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              file,
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: Text('Uploading', style: t.labelLarge)),
                  Text(
                    '$pct%',
                    style: t.labelLarge?.copyWith(color: c.primary),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ZingProgressBar(value: state.progress),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: cubit.cancel,
                child: Text(
                  'Cancel',
                  style: t.labelSmall?.copyWith(color: c.textSecondary),
                ),
              ),
            ],
          ),
        );
      case ProcessingStatus.processing:
        return ZingCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 12,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text('AI is processing', style: t.labelLarge),
                  ),
                  const ZingBadge('~30 sec', tone: ZingTone.info, small: true),
                ],
              ),
              const _Step(label: 'Reading document', done: true),
              const _Step(label: 'Writing summary', active: true),
              const _Step(label: 'Creating flashcards and quiz'),
            ],
          ),
        );
      case ProcessingStatus.ready:
        return ZingCard(
          color: c.successSurface,
          bordered: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 12,
            children: [
              Text(
                'Your material is ready',
                style: t.titleSmall?.copyWith(
                  color: c.successText,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                'Summary, ${state.material!.flashcards.length} flashcards and ${state.material!.questions.length} quiz questions.',
                style: t.bodySmall?.copyWith(color: c.successText),
              ),
              ZingButton(
                label: 'Open material',
                compact: true,
                onPressed: () =>
                    context.pushReplacement('/material/${state.material!.id}'),
              ),
            ],
          ),
        );
      case ProcessingStatus.failed:
        return ZingCard(
          color: c.errorSurface,
          bordered: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 12,
            children: [
              Text(
                'Could not read this file',
                style: t.titleSmall?.copyWith(
                  color: c.errorText,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                state.errorMessage ?? 'Something went wrong. Try again.',
                style: t.bodySmall?.copyWith(color: c.errorText),
              ),
              Row(
                spacing: 10,
                children: [
                  Expanded(
                    child: ZingButton(
                      label: 'Try again',
                      variant: ZingButtonVariant.danger,
                      compact: true,
                      onPressed: cubit.retry,
                    ),
                  ),
                  Expanded(
                    child: ZingButton(
                      label: 'Choose another',
                      variant: ZingButtonVariant.outlined,
                      compact: true,
                      onPressed: cubit.cancel,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      case ProcessingStatus.idle:
        return const SizedBox.shrink();
    }
  }
}

class _Step extends StatelessWidget {
  const _Step({required this.label, this.done = false, this.active = false});
  final String label;
  final bool done;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Row(
      children: [
        SizedBox(
          width: 18,
          height: 18,
          child: done
              ? DecoratedBox(
                  decoration: BoxDecoration(
                    color: c.success,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.check, size: 12, color: c.onPrimary),
                )
              : active
              ? CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: c.primary,
                  backgroundColor: c.border,
                )
              : DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: c.border, width: 2),
                  ),
                ),
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: context.text.bodySmall?.copyWith(
            color: done || active ? c.textPrimary : c.textSecondary,
            fontWeight: active ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ],
    );
  }
}
