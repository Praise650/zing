import 'package:flutter/material.dart';

import '../../app/theme/app_radius.dart';
import '../extensions/build_context_extensions.dart';

class ZingFilterChip extends StatelessWidget {
  const ZingFilterChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Semantics(
      selected: selected,
      button: true,
      child: Material(
        color: selected ? c.primary : c.surface,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.chipAll,
          side: selected ? BorderSide.none : BorderSide(color: c.border),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.chipAll,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            child: Text(
              label,
              style: context.text.labelMedium?.copyWith(
                color: selected ? c.onPrimary : c.textPrimary,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
