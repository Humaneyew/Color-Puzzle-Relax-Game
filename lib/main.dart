import 'package:flutter/material.dart';

import 'src/app.dart';
import 'src/core/di/injection_container.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await configureDependencies();

  runApp(const ColorPuzzleApp());
}
