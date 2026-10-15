import 'package:flutter/material.dart';

import '../../app/theme/app_radius.dart';
import '../../app/theme/app_shadows.dart';
import '../extensions/build_context_extensions.dart';

class ZingCard extends StatelessWidget {
  const ZingCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.color,
    this.radius,
    this.elevated = false,
    this.bordered = true,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final BorderRadius? radius;
  final bool elevated;
  final bool bordered;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final r = radius ?? AppRadius.cardAll;
    return Container(
      decoration: BoxDecoration(
        color: color ?? c.surface,
        borderRadius: r,
        border: bordered ? Border.all(color: c.border) : null,
        boxShadow: elevated ? AppShadows.level1(c.shadow) : null,
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          borderRadius: r,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}
