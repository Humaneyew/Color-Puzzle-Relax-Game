import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';

import 'package:color_puzzle_relax_game/src/features/game/data/models/puzzle_level_model.dart';

void main() {
  group('puzzle level data', () {
    test('decodes the first level and validates anchors', () {
      final File file = File('assets/data/puzzle_levels.json');
      final Map<String, dynamic> decoded =
          jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
      final List<dynamic> rawLevels = decoded['levels'] as List<dynamic>;
      expect(rawLevels, hasLength(50));

      final PuzzleLevelModel first =
          PuzzleLevelModel.fromJson(rawLevels.first as Map<String, dynamic>);
      expect(<int>[3, 4, 5], contains(first.rows));
      expect(<int>[5, 7], contains(first.cols));
      expect(first.solution.length, first.rows);
      expect(first.start.length, first.rows);
      expect(first.anchors.length, first.rows);

      for (int r = 0; r < first.rows; r++) {
        expect(first.solution[r].length, first.cols);
        expect(first.start[r].length, first.cols);
        expect(first.anchors[r].length, first.cols);
        for (int c = 0; c < first.cols; c++) {
          if (first.anchors[r][c]) {
            expect(first.start[r][c], first.solution[r][c]);
          }
        }
      }
    });

    test('solution lightness is monotonic by rows and columns', () {
      final File file = File('assets/data/puzzle_levels.json');
      final Map<String, dynamic> decoded =
          jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
      final List<dynamic> rawLevels = decoded['levels'] as List<dynamic>;
      for (final dynamic entry in rawLevels.take(2)) {
        final PuzzleLevelModel level =
            PuzzleLevelModel.fromJson(entry as Map<String, dynamic>);
        final List<List<double>> lightnessGrid = level.solution
            .map((List<String> row) =>
                row.map((String hex) => _labFromHex(hex).$1).toList())
            .toList();

        for (final List<double> row in lightnessGrid) {
          expect(_isMonotonic(row), isTrue,
              reason: 'Row lightness should not oscillate.');
        }
        for (int c = 0; c < level.cols; c++) {
          final List<double> column =
              List<double>.generate(level.rows, (int r) => lightnessGrid[r][c]);
          expect(_isMonotonic(column), isTrue,
              reason: 'Column lightness should not oscillate.');
        }
      }
    });
  });
}

bool _isMonotonic(List<double> values) {
  if (values.length <= 1) {
    return true;
  }
  final double delta = values.last - values.first;
  final bool increasing = delta >= 0;
  for (int i = 1; i < values.length; i++) {
    final double diff = values[i] - values[i - 1];
    if (increasing && diff < -0.5) {
      return false;
    }
    if (!increasing && diff > 0.5) {
      return false;
    }
  }
  return true;
}

(double, double, double) _labFromHex(String hex) {
  final String cleaned = hex.replaceAll('#', '');
  final int value = int.parse(cleaned, radix: 16);
  final double r = ((value >> 16) & 0xFF) / 255.0;
  final double g = ((value >> 8) & 0xFF) / 255.0;
  final double b = (value & 0xFF) / 255.0;
  final (double, double, double) xyz = _rgbToXyz(r, g, b);
  return _xyzToLab(xyz);
}

(double, double, double) _rgbToXyz(double r, double g, double b) {
  double linearize(double channel) {
    if (channel <= 0.04045) {
      return channel / 12.92;
    }
    return math.pow((channel + 0.055) / 1.055, 2.4).toDouble();
  }

  final double rl = linearize(r) * 100;
  final double gl = linearize(g) * 100;
  final double bl = linearize(b) * 100;

  final double x = rl * 0.4124 + gl * 0.3576 + bl * 0.1805;
  final double y = rl * 0.2126 + gl * 0.7152 + bl * 0.0722;
  final double z = rl * 0.0193 + gl * 0.1192 + bl * 0.9505;
  return (x, y, z);
}

(double, double, double) _xyzToLab((double, double, double) xyz) {
  double pivot(double value) {
    if (value > 0.008856) {
      return math.pow(value, 1 / 3).toDouble();
    }
    return (7.787 * value) + (16 / 116);
  }

  const double refX = 95.047;
  const double refY = 100.0;
  const double refZ = 108.883;

  final double x = pivot(xyz.$1 / refX);
  final double y = pivot(xyz.$2 / refY);
  final double z = pivot(xyz.$3 / refZ);

  final double l = (116 * y) - 16;
  final double a = 500 * (x - y);
  final double b = 200 * (y - z);
  return (l, a, b);
}
