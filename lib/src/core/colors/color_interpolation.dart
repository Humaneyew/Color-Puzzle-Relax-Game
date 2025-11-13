import 'lab_color.dart';

LabColor lerpLab(LabColor start, LabColor end, double t) {
  final double clampedT = t.clamp(0.0, 1.0);
  return LabColor(
    start.l + (end.l - start.l) * clampedT,
    start.a + (end.a - start.a) * clampedT,
    start.b + (end.b - start.b) * clampedT,
  );
}

List<LabColor> bilinearInterpolate(
  LabColor topLeft,
  LabColor topRight,
  LabColor bottomLeft,
  LabColor bottomRight,
  int width,
  int height,
) {
  assert(width > 0 && height > 0, 'Grid dimensions must be positive');

  final List<LabColor> result = List<LabColor>.filled(width * height, topLeft, growable: false);
  for (int y = 0; y < height; y++) {
    final double v = height == 1 ? 0.0 : y / (height - 1);
    final LabColor left = lerpLab(topLeft, bottomLeft, v);
    final LabColor right = lerpLab(topRight, bottomRight, v);
    for (int x = 0; x < width; x++) {
      final double u = width == 1 ? 0.0 : x / (width - 1);
      result[y * width + x] = lerpLab(left, right, u);
    }
  }
  return result;
}
