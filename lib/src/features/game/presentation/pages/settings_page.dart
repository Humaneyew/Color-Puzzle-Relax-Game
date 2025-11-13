import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  static const String routeName = 'settings';
  static const String routePath = '/settings';

  static const List<String> _options = <String>[
    'Звук',
    'Вибрация',
    'Язык',
    'Темы',
    'Политика приватности',
  ];

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                for (int i = 0; i < _options.length; i++) ...<Widget>[
                  _SettingsBanner(
                    label: _options[i],
                    backgroundColor: colors.primaryContainer,
                    borderColor: colors.primary,
                    textStyle: theme.textTheme.titleMedium?.copyWith(
                      color: colors.onPrimaryContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (i != _options.length - 1) const SizedBox(height: 16),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SettingsBanner extends StatelessWidget {
  const _SettingsBanner({
    required this.label,
    required this.backgroundColor,
    required this.borderColor,
    required this.textStyle,
  });

  final String label;
  final Color backgroundColor;
  final Color borderColor;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: borderColor,
          width: 1.5,
        ),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: textStyle,
      ),
    );
  }
}
