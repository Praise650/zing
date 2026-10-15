import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../features/authentication/presentation/forgot_password_screen.dart';
import '../features/authentication/presentation/session_cubit.dart';
import '../features/authentication/presentation/sign_in_screen.dart';
import '../features/authentication/presentation/sign_up_screen.dart';
import '../features/flashcards/presentation/flashcard_cubit.dart';
import '../features/flashcards/presentation/flashcard_screen.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/library/presentation/library_cubit.dart';
import '../features/library/presentation/library_screen.dart';
import '../features/materials/presentation/add_material_screen.dart';
import '../features/materials/presentation/import_cubit.dart';
import '../features/materials/presentation/materials_cubit.dart';
import '../features/onboarding/presentation/onboarding_screen.dart';
import '../features/profile/presentation/profile_screen.dart';
import '../features/progress/presentation/progress_screen.dart';
import '../features/quizzes/presentation/quiz_cubit.dart';
import '../features/quizzes/presentation/quiz_screen.dart';
import '../features/summaries/presentation/material_detail_screen.dart';
import '../features/materials/domain/study_material.dart';
import 'app_shell.dart';
import 'router_refresh.dart';

const _authRoutes = {'/onboarding', '/sign-in', '/sign-up', '/forgot-password'};

/// Sends signed-out users to the auth flow and signed-in users past it.
/// Returns null (no redirect) when [session] is state-less, e.g. in tests.
String? sessionRedirect(SessionState session, String location) {
  if (!session.signedIn) {
    if (location == '/onboarding' && session.onboardingSeen) return '/sign-in';
    if (_authRoutes.contains(location)) return null;
    return session.onboardingSeen ? '/sign-in' : '/onboarding';
  }
  return _authRoutes.contains(location) ? '/home' : null;
}

/// Pass [session] to enable auth redirects; without it every route is open.
GoRouter createRouter({
  String initialLocation = '/onboarding',
  SessionCubit? session,
}) => GoRouter(
  initialLocation: initialLocation,
  refreshListenable: session == null
      ? null
      : StreamRefreshListenable(session.stream),
  redirect: session == null
      ? null
      : (_, state) => sessionRedirect(session.state, state.matchedLocation),
  routes: [
    GoRoute(path: '/onboarding', builder: (_, _) => const OnboardingScreen()),
    GoRoute(path: '/sign-in', builder: (_, _) => const SignInScreen()),
    GoRoute(path: '/sign-up', builder: (_, _) => const SignUpScreen()),
    GoRoute(
      path: '/forgot-password',
      builder: (_, state) =>
          ForgotPasswordScreen(initialEmail: state.extra as String?),
    ),
    StatefulShellRoute.indexedStack(
      builder: (_, _, shell) => AppShell(navigationShell: shell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(path: '/home', builder: (_, _) => const HomeScreen()),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/library',
              builder: (context, _) => BlocProvider(
                create: (_) => LibraryCubit(
                  context.read<MaterialsCubit>().state.materials,
                ),
                child: BlocListener<MaterialsCubit, MaterialsState>(
                  listener: (context, state) => context
                      .read<LibraryCubit>()
                      .setMaterials(state.materials),
                  child: const LibraryScreen(),
                ),
              ),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/progress',
              builder: (_, _) => const ProgressScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(path: '/profile', builder: (_, _) => const ProfileScreen()),
          ],
        ),
      ],
    ),
    // Full-screen routes sit outside the shell, so the bottom nav is hidden.
    GoRoute(
      path: '/add-material',
      builder: (context, _) => BlocProvider(
        create: (_) =>
            ImportCubit(onImported: context.read<MaterialsCubit>().add),
        child: const AddMaterialScreen(),
      ),
    ),
    GoRoute(
      path: '/material/:id',
      builder: (context, state) => MaterialDetailScreen(
        material: _material(context, state.pathParameters['id']!),
      ),
    ),
    GoRoute(
      path: '/flashcards/:id',
      builder: (context, state) => BlocProvider(
        create: (_) => FlashcardCubit(
          _material(context, state.pathParameters['id']!).flashcards,
        ),
        child: const FlashcardScreen(),
      ),
    ),
    GoRoute(
      path: '/quiz/:id',
      builder: (context, state) => BlocProvider(
        create: (_) => QuizCubit(
          _material(context, state.pathParameters['id']!).questions,
        ),
        child: const QuizScreen(),
      ),
    ),
  ],
);

StudyMaterial _material(BuildContext context, String id) {
  final cubit = context.read<MaterialsCubit>();
  return cubit.find(id) ?? cubit.state.materials.first;
}
