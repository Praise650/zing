import 'package:flutter/material.dart';

import '../../app/theme/app_radius.dart';
import '../extensions/build_context_extensions.dart';

/// Pill segmented control (Preview | AI Summary, Grid | List, Light | Dark | Auto).
class ZingSegmented<T> extends StatelessWidget {
  const ZingSegmented({
    super.key,
    required this.options,
    required this.value,
    required this.onChanged,
    this.expand = false,
  });

  final Map<T, String> options;
  final T value;
  final ValueChanged<T> onChanged;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final items = options.entries.map((e) {
      final selected = e.key == value;
      final tile = GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onChanged(e.key),
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          decoration: BoxDecoration(
            color: selected ? c.primarySurface : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            e.value,
            style: context.text.labelMedium?.copyWith(
              color: selected ? c.primaryDark : c.textSecondary,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      );
      return expand ? Expanded(child: tile) : tile;
    }).toList();

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: AppRadius.buttonAll,
        border: Border.all(color: c.border),
      ),
      child: Row(
        mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
        children: items,
      ),
    );
  }
}
