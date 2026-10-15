import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../domain/study_material.dart';

/// Label, icon and colors used to represent a [StudyMaterialType] in lists.
class MaterialTypeStyle {
  const MaterialTypeStyle(this.label, this.icon, this.bg, this.fg);

  final String label;
  final IconData icon;
  final Color bg;
  final Color fg;

  factory MaterialTypeStyle.of(StudyMaterialType type, AppColors c) =>
      switch (type) {
        StudyMaterialType.pdf => MaterialTypeStyle(
          'PDF',
          Icons.picture_as_pdf_outlined,
          c.errorSurface,
          c.error,
        ),
        StudyMaterialType.note => MaterialTypeStyle(
          'Notes',
          Icons.sticky_note_2_outlined,
          c.infoSurface,
          c.info,
        ),
        StudyMaterialType.pastedText => MaterialTypeStyle(
          'Text',
          Icons.notes,
          c.warningSurface,
          c.warningText,
        ),
        StudyMaterialType.scan => MaterialTypeStyle(
          'Scan',
          Icons.document_scanner_outlined,
          c.successSurface,
          c.success,
        ),
      };
}
