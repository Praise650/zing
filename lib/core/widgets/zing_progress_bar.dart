import 'package:flutter/material.dart';

import '../extensions/build_context_extensions.dart';

class ZingProgressBar extends StatelessWidget {
  const ZingProgressBar({
    super.key,
    required this.value,
    this.height = 8,
    this.track,
    this.fill,
  });

  /// 0.0 to 1.0.
  final double value;
  final double height;
  final Color? track;
  final Color? fill;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return ClipRRect(
      borderRadius: BorderRadius.circular(height / 2),
      child: LinearProgressIndicator(
        value: value.clamp(0, 1),
        minHeight: height,
        backgroundColor: track ?? c.primarySurface,
        valueColor: AlwaysStoppedAnimation(fill ?? c.primary),
      ),
    );
  }
}
