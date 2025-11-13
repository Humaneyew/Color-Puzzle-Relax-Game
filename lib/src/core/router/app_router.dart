import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/game/presentation/pages/game_screen.dart';
import '../../features/game/presentation/pages/home_page.dart';
import '../../features/game/presentation/pages/level_overview_page.dart';
import '../../features/game/presentation/pages/main_menu_page.dart';
import '../../features/game/presentation/pages/settings_page.dart';

GoRouter createRouter() {
  return GoRouter(
    initialLocation: MainMenuPage.routePath,
    routes: <RouteBase>[
      GoRoute(
        name: MainMenuPage.routeName,
        path: MainMenuPage.routePath,
        pageBuilder: (context, state) => const NoTransitionPage(
          child: MainMenuPage(),
        ),
      ),
      GoRoute(
        name: HomePage.routeName,
        path: HomePage.routePath,
        pageBuilder: (context, state) => const NoTransitionPage(
          child: HomePage(),
        ),
      ),
      GoRoute(
        name: LevelOverviewPage.routeName,
        path: LevelOverviewPage.routePath,
        pageBuilder: (context, state) {
          final levelId = state.pathParameters['levelId'] ?? '';
          return NoTransitionPage(
            child: LevelOverviewPage(levelId: levelId),
          );
        },
      ),
      GoRoute(
        name: GameScreen.routeName,
        path: GameScreen.routePath,
        pageBuilder: (context, state) {
          final levelId = state.pathParameters['levelId'] ?? '';
          return NoTransitionPage(
            child: GameScreen(levelId: levelId),
          );
        },
      ),
      GoRoute(
        name: SettingsPage.routeName,
        path: SettingsPage.routePath,
        pageBuilder: (context, state) => const NoTransitionPage(
          child: SettingsPage(),
        ),
      ),
    ],
    observers: <NavigatorObserver>[
      _RouterLogger(),
    ],
  );
}

class _RouterLogger extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    debugPrint('Route pushed: ${route.settings.name ?? route.settings.arguments}');
  }
}
