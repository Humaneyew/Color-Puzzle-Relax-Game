import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  static const String routeName = 'settings';
  static const String routePath = '/settings';

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _soundEffectsEnabled = true;
  bool _musicEnabled = true;
  bool _hintsEnabled = false;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: <Widget>[
          Text(
            'Gameplay',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          SwitchListTile.adaptive(
            value: _soundEffectsEnabled,
            onChanged: (bool value) {
              setState(() {
                _soundEffectsEnabled = value;
              });
            },
            title: const Text('Sound Effects'),
            subtitle: const Text('Toggle puzzle interaction sounds.'),
          ),
          SwitchListTile.adaptive(
            value: _musicEnabled,
            onChanged: (bool value) {
              setState(() {
                _musicEnabled = value;
              });
            },
            title: const Text('Music'),
            subtitle: const Text('Enable relaxing background music.'),
          ),
          const SizedBox(height: 24),
          Text(
            'Assistance',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          SwitchListTile.adaptive(
            value: _hintsEnabled,
            onChanged: (bool value) {
              setState(() {
                _hintsEnabled = value;
              });
            },
            title: const Text('Hints'),
            subtitle:
                const Text('Show subtle hints during challenging puzzles.'),
          ),
          const SizedBox(height: 24),
          Text(
            'These options are stored locally on this device and will be '
            'expanded in future updates.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
