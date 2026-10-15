import 'package:flutter/material.dart';

import '../../../core/extensions/build_context_extensions.dart';
import '../../../core/widgets/zing_button.dart';

/// Shared layout for sign-in and sign-up.
class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    super.key,
    required this.title,
    required this.subtitle,
    required this.children,
    required this.footerText,
    required this.footerAction,
    required this.onFooterTap,
    this.gap = 20,
  });

  final String title;
  final String subtitle;
  final List<Widget> children;
  final String footerText;
  final String footerAction;
  final VoidCallback onFooterTap;
  final double gap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, box) => SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: box.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 40),
                    Text(title, style: context.text.displayMedium),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: context.text.bodyLarge?.copyWith(
                        color: c.textSecondary,
                      ),
                    ),
                    SizedBox(height: gap + 4),
                    for (final w in children) ...[w, SizedBox(height: gap)],
                    const Spacer(),
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: GestureDetector(
                          onTap: onFooterTap,
                          child: Text.rich(
                            TextSpan(
                              text: footerText,
                              style: context.text.bodyMedium?.copyWith(
                                color: c.textSecondary,
                              ),
                              children: [
                                TextSpan(
                                  text: footerAction,
                                  style: context.text.bodyMedium?.copyWith(
                                    color: c.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class OrDivider extends StatelessWidget {
  const OrDivider({super.key});

  @override
  Widget build(BuildContext context) => Row(
    children: [
      const Expanded(child: Divider()),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Text(
          'or',
          style: context.text.labelSmall?.copyWith(
            color: context.colors.textSecondary,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
      const Expanded(child: Divider()),
    ],
  );
}

class SocialButtons extends StatelessWidget {
  const SocialButtons({super.key});

  @override
  Widget build(BuildContext context) => Row(
    spacing: 12,
    children: [
      Expanded(
        child: ZingButton(
          label: 'Google',
          variant: ZingButtonVariant.outlined,
          onPressed: () => _soon(context),
        ),
      ),
      Expanded(
        child: ZingButton(
          label: 'Apple',
          variant: ZingButtonVariant.outlined,
          onPressed: () => _soon(context),
        ),
      ),
    ],
  );

  void _soon(BuildContext context) =>
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Social sign-in is not available yet.')),
      );
}
