import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/game/presentation/pages/home_page.dart';
import '../../features/game/presentation/pages/level_overview_page.dart';

GoRouter createRouter() {
  return GoRouter(
    initialLocation: HomePage.routePath,
    routes: <RouteBase>[
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
