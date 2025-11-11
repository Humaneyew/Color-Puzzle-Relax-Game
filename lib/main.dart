import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:color_puzzle_relax_game/src/app.dart';
import 'package:color_puzzle_relax_game/src/logic/services/sound_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  final soundService = SoundService();
  runApp(ColorPuzzleApp(soundService: soundService));
}
