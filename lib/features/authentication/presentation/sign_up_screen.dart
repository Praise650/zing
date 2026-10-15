import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/extensions/build_context_extensions.dart';
import '../../../core/utilities/validators.dart';
import '../../../core/widgets/zing_button.dart';
import '../../../core/widgets/zing_text_field.dart';
import 'auth_widgets.dart';
import 'session_cubit.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _agreed = false;
  bool _emailTouched = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  bool get _nameOk => Validators.name(_name.text) == null;
  bool get _emailOk => Validators.email(_email.text) == null;
  bool get _passwordOk => Validators.password(_password.text) == null;
  bool get _canSubmit => _nameOk && _emailOk && _passwordOk && _agreed;

  Color _meterColor(AppColors c, PasswordStrength s) => switch (s) {
    PasswordStrength.weak => c.error,
    PasswordStrength.fair => c.warning,
    _ => c.success,
  };

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final strength = passwordStrength(_password.text);
    return AuthScaffold(
      title: 'Create account',
      subtitle: 'Start with a free account.',
      footerText: 'Have an account? ',
      footerAction: 'Sign in',
      onFooterTap: () => context.go('/sign-in'),
      gap: 18,
      children: [
        ZingTextField(
          label: 'Full name',
          hint: 'Alex Morgan',
          controller: _name,
          valid: _nameOk,
          textInputAction: TextInputAction.next,
          onChanged: (_) => setState(() {}),
        ),
        ZingTextField(
          label: 'Email',
          hint: 'name@uni.edu',
          controller: _email,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          valid: _emailOk,
          errorText: _emailTouched && _email.text.isNotEmpty
              ? Validators.email(_email.text)
              : null,
          onChanged: (_) => setState(() => _emailTouched = true),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ZingTextField(
              label: 'Password',
              controller: _password,
              obscure: true,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 8),
            Row(
              spacing: 4,
              children: [
                for (var i = 0; i < 4; i++)
                  Expanded(
                    child: Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: i < strength.segments
                            ? _meterColor(c, strength)
                            : c.border,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
              ],
            ),
            if (strength != PasswordStrength.empty) ...[
              const SizedBox(height: 8),
              Text(
                strength.message,
                style: context.text.labelSmall?.copyWith(
                  color: _meterColor(c, strength),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ],
        ),
        InkWell(
          onTap: () => setState(() => _agreed = !_agreed),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: _agreed ? c.primary : c.surface,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: _agreed ? c.primary : c.border,
                    width: 1.5,
                  ),
                ),
                child: _agreed
                    ? Icon(Icons.check, size: 14, color: c.onPrimary)
                    : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'I agree to the Terms and Privacy Policy',
                  style: context.text.bodySmall?.copyWith(
                    color: c.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
        ZingButton(
          label: 'Create account',
          onPressed: _canSubmit
              ? () {
                  context.read<SessionCubit>().signUp(
                    name: _name.text,
                    email: _email.text,
                  );
                  context.go('/home');
                }
              : null,
        ),
      ],
    );
  }
}
