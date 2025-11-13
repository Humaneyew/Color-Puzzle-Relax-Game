import 'package:flutter_test/flutter_test.dart';

import 'package:color_puzzle_relax_game/src/app.dart';
import 'package:color_puzzle_relax_game/src/core/di/injection_container.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await serviceLocator.reset();
    await configureDependencies();
  });

  tearDownAll(() async {
    await serviceLocator.reset();
  });

  testWidgets('ColorPuzzleApp shows the main menu start button',
      (WidgetTester tester) async {
    await tester.pumpWidget(const ColorPuzzleApp());
    await tester.pumpAndSettle();

    expect(find.text('Старт'), findsOneWidget);
  });
}
