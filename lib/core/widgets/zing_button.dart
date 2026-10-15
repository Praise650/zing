import 'package:flutter/material.dart';

import '../../app/theme/app_radius.dart';
import '../extensions/build_context_extensions.dart';

enum ZingButtonVariant { primary, tonal, outlined, text, danger }

class ZingButton extends StatelessWidget {
  const ZingButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = ZingButtonVariant.primary,
    this.icon,
    this.isLoading = false,
    this.expand = true,
    this.compact = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final ZingButtonVariant variant;
  final IconData? icon;
  final bool isLoading;
  final bool expand;
  final bool compact;

  bool get _enabled => onPressed != null && !isLoading;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final (bg, fg, border) = switch (variant) {
      ZingButtonVariant.primary => (c.primary, c.onPrimary, null),
      ZingButtonVariant.tonal => (c.primarySurface, c.primaryDark, null),
      ZingButtonVariant.outlined => (c.surface, c.textPrimary, c.border),
      ZingButtonVariant.text => (Colors.transparent, c.primary, null),
      ZingButtonVariant.danger => (c.error, Colors.white, null),
    };
    final disabled = !_enabled && !isLoading;
    final background = disabled && variant != ZingButtonVariant.text
        ? c.border
        : bg;
    final foreground = disabled ? c.textDisabled : fg;

    final child = Row(
      mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading)
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: foreground,
            ),
          )
        else ...[
          if (icon != null) ...[
            Icon(icon, size: 18, color: foreground),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: context.text.labelLarge?.copyWith(color: foreground),
            ),
          ),
        ],
      ],
    );

    return Semantics(
      button: true,
      enabled: _enabled,
      child: Material(
        color: background,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.buttonAll,
          side: border == null
              ? BorderSide.none
              : BorderSide(color: border, width: 1.5),
        ),
        child: InkWell(
          onTap: _enabled ? onPressed : null,
          borderRadius: AppRadius.buttonAll,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: compact ? 20 : 22,
              vertical: compact ? 12 : 16,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
