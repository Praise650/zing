import 'package:flutter/material.dart';

import '../extensions/build_context_extensions.dart';

/// Small uppercase eyebrow label (e.g. OVERVIEW, NOTIFICATIONS).
class ZingSectionLabel extends StatelessWidget {
  const ZingSectionLabel(this.text, {super.key, this.color});

  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) => Text(
    text.toUpperCase(),
    style: context.text.labelSmall?.copyWith(
      color: color ?? context.colors.textSecondary,
      fontWeight: FontWeight.w700,
      letterSpacing: .72,
    ),
  );
}
