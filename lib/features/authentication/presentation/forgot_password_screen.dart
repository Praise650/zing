import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/extensions/build_context_extensions.dart';
import '../../../core/utilities/validators.dart';
import '../../../core/widgets/zing_button.dart';
import '../../../core/widgets/zing_icon_button.dart';
import '../../../core/widgets/zing_text_field.dart';

/// Two states: ask for an email, then confirm the (simulated) reset link.
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key, this.initialEmail});

  final String? initialEmail;

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  late final _email = TextEditingController(text: widget.initialEmail);
  bool _submitted = false;
  String? _sentTo;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  String? get _error => _submitted ? Validators.email(_email.text) : null;

  void _send() {
    setState(() => _submitted = true);
    if (Validators.email(_email.text) == null) {
      setState(() => _sentTo = _email.text.trim());
    }
  }

  void _back() => context.canPop() ? context.pop() : context.go('/sign-in');

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final t = context.text;
    final sent = _sentTo != null;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ZingIconButton(
                icon: Icons.arrow_back,
                tooltip: 'Back',
                onPressed: _back,
              ),
              const SizedBox(height: 28),
              Text(
                sent ? 'Check your email' : 'Reset password',
                style: t.displayMedium,
              ),
              const SizedBox(height: 6),
              Text(
                sent
                    ? 'If an account exists for $_sentTo, we sent a link to reset your password.'
                    : 'Enter your email and we will send you a reset link.',
                style: t.bodyLarge?.copyWith(color: c.textSecondary),
              ),
              const SizedBox(height: 24),
              if (!sent) ...[
                ZingTextField(
                  label: 'Email',
                  hint: 'name@uni.edu',
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.done,
                  errorText: _error,
                  onChanged: (_) => setState(() {}),
                  onSubmitted: (_) => _send(),
                ),
                const SizedBox(height: 20),
                ZingButton(label: 'Send reset link', onPressed: _send),
              ] else ...[
                ZingButton(label: 'Back to sign in', onPressed: _back),
                const SizedBox(height: 8),
                Center(
                  child: TextButton(
                    onPressed: () => setState(() => _sentTo = null),
                    child: Text(
                      'Use a different email',
                      style: t.labelLarge?.copyWith(color: c.primary),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
