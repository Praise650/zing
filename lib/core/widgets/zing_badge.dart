import 'package:flutter/material.dart';

import '../../app/theme/app_radius.dart';
import '../extensions/build_context_extensions.dart';

enum ZingTone { success, warning, error, info, brand }

class ZingBadge extends StatelessWidget {
  const ZingBadge(
    this.label, {
    super.key,
    this.tone = ZingTone.success,
    this.small = false,
  });

  final String label;
  final ZingTone tone;
  final bool small;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final (bg, fg) = switch (tone) {
      ZingTone.success => (c.successSurface, c.success),
      ZingTone.warning => (c.warningSurface, c.warningText),
      ZingTone.error => (c.errorSurface, c.error),
      ZingTone.info => (c.infoSurface, c.info),
      ZingTone.brand => (c.primarySurface, c.primaryDark),
    };
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: small ? 8 : 10,
        vertical: small ? 4 : 5,
      ),
      decoration: BoxDecoration(color: bg, borderRadius: AppRadius.chipAll),
      child: Text(
        label,
        style: context.text.labelSmall?.copyWith(
          color: fg,
          fontSize: small ? 11 : 12,
        ),
      ),
    );
  }
}
