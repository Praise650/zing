import 'package:flutter/material.dart';

import '../../app/theme/app_radius.dart';
import '../extensions/build_context_extensions.dart';

/// Labelled text field with a focus ring, inline error and optional
/// password visibility toggle.
class ZingTextField extends StatefulWidget {
  const ZingTextField({
    super.key,
    required this.label,
    this.controller,
    this.hint,
    this.errorText,
    this.obscure = false,
    this.valid = false,
    this.maxLines = 1,
    this.keyboardType,
    this.textInputAction,
    this.onChanged,
    this.onSubmitted,
  });

  final String label;
  final TextEditingController? controller;
  final String? hint;
  final String? errorText;
  final bool obscure;

  /// Shows a green check and border when true.
  final bool valid;
  final int maxLines;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  @override
  State<ZingTextField> createState() => _ZingTextFieldState();
}

class _ZingTextFieldState extends State<ZingTextField> {
  final _focus = FocusNode();
  late bool _hidden = widget.obscure;

  @override
  void initState() {
    super.initState();
    _focus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final hasError = widget.errorText != null;
    final focused = _focus.hasFocus;
    final borderColor = hasError
        ? c.error
        : focused
        ? c.primary
        : widget.valid
        ? c.success
        : c.border;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: context.text.labelMedium?.copyWith(
            color: hasError ? c.error : c.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            color: hasError ? c.errorSurface : c.surface,
            borderRadius: AppRadius.buttonAll,
            border: Border.all(color: borderColor, width: focused ? 2 : 1.5),
            boxShadow: focused
                ? [BoxShadow(color: c.primarySurface, spreadRadius: 4)]
                : null,
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  focusNode: _focus,
                  obscureText: _hidden,
                  maxLines: _hidden ? 1 : widget.maxLines,
                  keyboardType: widget.keyboardType,
                  textInputAction: widget.textInputAction,
                  onChanged: widget.onChanged,
                  onSubmitted: widget.onSubmitted,
                  style: context.text.bodyLarge,
                  cursorColor: c.primary,
                  decoration: InputDecoration(
                    hintText: widget.hint,
                    hintStyle: context.text.bodyLarge?.copyWith(
                      color: c.textDisabled,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 15,
                    ),
                  ),
                ),
              ),
              if (widget.obscure)
                GestureDetector(
                  onTap: () => setState(() => _hidden = !_hidden),
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 14, left: 8),
                    child: Text(
                      _hidden ? 'Show' : 'Hide',
                      style: context.text.labelMedium?.copyWith(
                        color: c.primary,
                      ),
                    ),
                  ),
                )
              else if (widget.valid)
                Padding(
                  padding: const EdgeInsets.only(right: 14),
                  child: Icon(Icons.check, size: 18, color: c.success),
                ),
            ],
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 6),
          Text(
            widget.errorText!,
            style: context.text.labelSmall?.copyWith(color: c.error),
          ),
        ],
      ],
    );
  }
}
