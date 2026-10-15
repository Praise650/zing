import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_shadows.dart';
import '../../../core/extensions/build_context_extensions.dart';
import '../../../core/widgets/zing_button.dart';
import '../../authentication/presentation/session_cubit.dart';

class _Page {
  const _Page(this.title, this.body, this.icon);
  final String title;
  final String body;
  final IconData icon;
}

const _pages = [
  _Page(
    'Turn your notes into study materials',
    'Upload a PDF or paste text. Zing creates summaries, flashcards and quizzes.',
    Icons.auto_awesome,
  ),
  _Page(
    'Remember more with active recall',
    'Flip flashcards and rate how well you knew each one. Zing brings back the hard ones.',
    Icons.style_outlined,
  ),
  _Page(
    'Track progress and keep your streak',
    'See study time, quiz scores and weekly activity in one place.',
    Icons.insights_outlined,
  ),
];

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  bool get _last => _page == _pages.length - 1;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _leaveTo(String route) {
    context.read<SessionCubit>().completeOnboarding();
    context.go(route);
  }

  void _next() {
    if (_last) {
      _leaveTo('/sign-up');
    } else {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => _leaveTo('/sign-in'),
                child: Text(
                  'Skip',
                  style: context.text.labelLarge?.copyWith(
                    color: c.textSecondary,
                  ),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _page = i),
                itemBuilder: (_, i) =>
                    _OnboardingPage(page: _pages[i], first: i == 0),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 0, 28, 24),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (var i = 0; i < _pages.length; i++)
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          width: i == _page ? 24 : 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: i == _page ? c.primary : c.border,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  ZingButton(
                    label: _last ? 'Get started' : 'Continue',
                    onPressed: _next,
                  ),
                  if (_last)
                    TextButton(
                      onPressed: () => _leaveTo('/sign-in'),
                      child: Text(
                        'I already have an account',
                        style: context.text.labelLarge?.copyWith(
                          color: c.primary,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  const _OnboardingPage({required this.page, required this.first});

  final _Page page;
  final bool first;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Container(
            height: 300,
            width: double.infinity,
            decoration: BoxDecoration(
              color: c.primarySurface,
              borderRadius: AppRadius.sheetAll,
            ),
            child: first
                ? const _HeroIllustration()
                : Center(
                    child: Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        color: c.primary,
                        borderRadius: BorderRadius.circular(32),
                        boxShadow: AppShadows.glow(c.primary, alpha: .4),
                      ),
                      child: Icon(page.icon, size: 44, color: c.onPrimary),
                    ),
                  ),
          ),
          const SizedBox(height: 36),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  page.title,
                  style: context.text.displayMedium?.copyWith(
                    fontSize: 30,
                    height: 1.15,
                    letterSpacing: -.8,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  page.body,
                  style: context.text.bodyLarge?.copyWith(
                    color: c.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Document -> summary / flashcards / quiz composition from the design.
class _HeroIllustration extends StatelessWidget {
  const _HeroIllustration();

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    Widget line(double f) => FractionallySizedBox(
      widthFactor: f,
      alignment: Alignment.centerLeft,
      child: Container(
        height: 6,
        decoration: BoxDecoration(
          color: c.border,
          borderRadius: BorderRadius.circular(3),
        ),
      ),
    );
    Widget chip(String title, {String? sub, bool filled = false}) => Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: filled ? c.primary : c.surface,
        borderRadius: AppRadius.buttonAll,
        boxShadow: filled ? null : AppShadows.level2(c.shadow),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: context.text.labelSmall?.copyWith(
              color: filled ? c.onPrimary : c.textPrimary,
            ),
          ),
          if (sub != null)
            Text(
              sub,
              style: context.text.labelSmall?.copyWith(
                fontWeight: FontWeight.w400,
                color: c.textSecondary,
              ),
            ),
        ],
      ),
    );

    return Stack(
      children: [
        Positioned(
          left: 24,
          top: 40,
          child: Transform.rotate(
            angle: -0.105,
            child: Container(
              width: 120,
              height: 160,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: c.surface,
                borderRadius: AppRadius.buttonAll,
                border: Border.all(color: c.border),
              ),
              child: Column(
                spacing: 8,
                children: [line(.7), line(1), line(.85), line(1), line(.5)],
              ),
            ),
          ),
        ),
        Positioned(
          left: 134,
          top: 112,
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: c.primary,
              shape: BoxShape.circle,
              boxShadow: AppShadows.glow(c.primary, alpha: .4),
            ),
            child: Icon(Icons.arrow_forward, size: 18, color: c.onPrimary),
          ),
        ),
        Positioned(
          right: 20,
          top: 60,
          width: 130,
          child: Column(
            spacing: 10,
            children: [
              chip('Summary', sub: '3 key concepts'),
              Padding(
                padding: const EdgeInsets.only(left: 16),
                child: chip('24 flashcards', filled: true),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: chip('10 quiz questions'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
