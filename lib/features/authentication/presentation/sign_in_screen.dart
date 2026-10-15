import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/extensions/build_context_extensions.dart';
import '../../../core/utilities/validators.dart';
import '../../../core/widgets/zing_button.dart';
import '../../../core/widgets/zing_text_field.dart';
import 'auth_widgets.dart';
import 'session_cubit.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _submitted = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  String? get _emailError => _submitted ? Validators.email(_email.text) : null;
  String? get _passwordError =>
      _submitted && _password.text.isEmpty ? 'Enter your password.' : null;

  void _submit() {
    setState(() => _submitted = true);
    if (_emailError == null && _passwordError == null) {
      context.read<SessionCubit>().signIn(email: _email.text);
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return AuthScaffold(
      title: 'Welcome back',
      subtitle: 'Sign in to continue studying.',
      footerText: 'New here? ',
      footerAction: 'Create account',
      onFooterTap: () => context.go('/sign-up'),
      children: [
        ZingTextField(
          label: 'Email',
          hint: 'name@uni.edu',
          controller: _email,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          errorText: _emailError,
          onChanged: (_) => setState(() {}),
        ),
        ZingTextField(
          label: 'Password',
          controller: _password,
          obscure: true,
          textInputAction: TextInputAction.done,
          errorText: _passwordError,
          onChanged: (_) => setState(() {}),
          onSubmitted: (_) => _submit(),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: InkWell(
            onTap: () => context.push('/forgot-password', extra: _email.text),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(
                'Forgot password?',
                style: context.text.labelMedium?.copyWith(color: c.primary),
              ),
            ),
          ),
        ),
        ZingButton(label: 'Sign in', onPressed: _submit),
        const OrDivider(),
        const SocialButtons(),
      ],
    );
  }
}
