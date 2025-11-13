import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'home_page.dart';

class MainMenuPage extends StatelessWidget {
  const MainMenuPage({super.key});

  static const String routeName = 'main-menu';
  static const String routePath = '/';

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 320),
          child: FilledButton(
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 24),
              textStyle: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            onPressed: () => context.push(HomePage.routePath),
            child: const Text('Старт'),
          ),
        ),
      ),
    );
  }
}
