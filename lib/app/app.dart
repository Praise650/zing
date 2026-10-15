import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../core/data/mock_data.dart';
import '../features/authentication/presentation/session_cubit.dart';
import '../features/materials/presentation/materials_cubit.dart';
import '../features/profile/presentation/theme_cubit.dart';
import '../features/settings/presentation/settings_cubit.dart';
import 'router.dart';
import 'theme/app_theme.dart';

class ZingApp extends StatefulWidget {
  const ZingApp({super.key, this.router});

  /// Override in tests to start on a specific route. An injected router is
  /// responsible for its own auth redirects.
  final GoRouter? router;

  @override
  State<ZingApp> createState() => _ZingAppState();
}

class _ZingAppState extends State<ZingApp> {
  // Created here (not in build) because the router listens to the session.
  final _session = SessionCubit();
  late final GoRouter _router =
      widget.router ?? createRouter(session: _session);

  @override
  void dispose() {
    _session.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _session),
        BlocProvider(create: (_) => ThemeCubit()),
        BlocProvider(create: (_) => SettingsCubit()),
        BlocProvider(create: (_) => MaterialsCubit(seed: MockData.materials)),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, mode) => MaterialApp.router(
          title: 'Zing',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: mode,
          routerConfig: _router,
        ),
      ),
    );
  }
}
