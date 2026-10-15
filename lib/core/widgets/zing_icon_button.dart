import 'package:flutter/material.dart';

import '../extensions/build_context_extensions.dart';

/// Circular bordered icon button used for back/close controls.
class ZingIconButton extends StatelessWidget {
  const ZingIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    required this.tooltip,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Tooltip(
      message: tooltip,
      child: Material(
        color: c.surface,
        shape: CircleBorder(side: BorderSide(color: c.border)),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: SizedBox(
            width: 40,
            height: 40,
            child: Icon(icon, size: 20, color: c.textPrimary),
          ),
        ),
      ),
    );
  }
}
