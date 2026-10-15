import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/extensions/build_context_extensions.dart';

/// Bottom navigation shell for the four main tabs.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  static const _tabs = [
    (Icons.home_outlined, Icons.home_rounded, 'Home'),
    (Icons.folder_outlined, Icons.folder_rounded, 'Library'),
    (Icons.insights_outlined, Icons.insights, 'Progress'),
    (Icons.person_outline, Icons.person, 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          color: c.surface,
          border: Border(top: BorderSide(color: c.border)),
        ),
        child: NavigationBarTheme(
          data: NavigationBarThemeData(
            backgroundColor: c.surface,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            height: 72,
            indicatorColor: c.primarySurface,
            labelTextStyle: WidgetStateProperty.resolveWith(
              (s) => context.text.labelSmall?.copyWith(
                fontSize: 11,
                color: s.contains(WidgetState.selected)
                    ? c.primaryDark
                    : c.textSecondary,
                fontWeight: s.contains(WidgetState.selected)
                    ? FontWeight.w600
                    : FontWeight.w500,
              ),
            ),
            iconTheme: WidgetStateProperty.resolveWith(
              (s) => IconThemeData(
                size: 22,
                color: s.contains(WidgetState.selected)
                    ? c.primary
                    : c.textSecondary,
              ),
            ),
          ),
          child: NavigationBar(
            selectedIndex: navigationShell.currentIndex,
            onDestinationSelected: (i) => navigationShell.goBranch(
              i,
              initialLocation: i == navigationShell.currentIndex,
            ),
            destinations: [
              for (final t in _tabs)
                NavigationDestination(
                  icon: Icon(t.$1),
                  selectedIcon: Icon(t.$2),
                  label: t.$3,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
