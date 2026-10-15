import 'package:flutter/material.dart';

import '../../app/theme/app_radius.dart';
import '../extensions/build_context_extensions.dart';
import 'zing_button.dart';

class ZingEmptyState extends StatelessWidget {
  const ZingEmptyState({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.description_outlined,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String message;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: c.primarySurface,
              borderRadius: BorderRadius.circular(AppRadius.sheet),
            ),
            child: Icon(icon, size: 36, color: c.secondary),
          ),
          const SizedBox(height: 12),
          Text(title, style: context.text.titleMedium),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: context.text.bodyMedium?.copyWith(color: c.textSecondary),
          ),
          if (actionLabel != null) ...[
            const SizedBox(height: 20),
            ZingButton(label: actionLabel!, onPressed: onAction, expand: false),
          ],
        ],
      ),
    );
  }
}
