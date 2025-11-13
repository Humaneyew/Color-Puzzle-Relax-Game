import 'package:flutter_test/flutter_test.dart';

import 'package:color_puzzle_relax_game/src/core/colors/color_interpolation.dart';
import 'package:color_puzzle_relax_game/src/core/colors/lab_color.dart';

void main() {
  test('lerpLab interpolates linearly between LAB values', () {
    const LabColor start = LabColor(0, 0, 0);
    const LabColor end = LabColor(100, 10, -10);

    final LabColor halfway = lerpLab(start, end, 0.5);

    expect(halfway.l, closeTo(50, 0.0001));
    expect(halfway.a, closeTo(5, 0.0001));
    expect(halfway.b, closeTo(-5, 0.0001));
  });

  test('bilinearInterpolate returns smooth grid', () {
    const LabColor topLeft = LabColor(0, 0, 0);
    const LabColor topRight = LabColor(0, 100, 0);
    const LabColor bottomLeft = LabColor(100, 0, 100);
    const LabColor bottomRight = LabColor(100, 100, 100);

    final List<LabColor> grid = bilinearInterpolate(
      topLeft,
      topRight,
      bottomLeft,
      bottomRight,
      3,
      3,
    );

    expect(grid, hasLength(9));
    final LabColor center = grid[4];
    expect(center.l, closeTo(50, 0.0001));
    expect(center.a, closeTo(50, 0.0001));
    expect(center.b, closeTo(50, 0.0001));
  });
}
