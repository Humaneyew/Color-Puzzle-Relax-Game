import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter/painting.dart';

import '../../data/level.dart';

/// Loads gradient puzzle levels from a JSON asset file.
class LevelLoader {
  LevelLoader({
    AssetBundle? bundle,
    this.assetPath = 'assets/levels/levels.json',
  }) : bundle = bundle ?? rootBundle;

  /// Asset bundle used to read the JSON file. Defaults to [rootBundle].
  final AssetBundle bundle;

  /// Path to the JSON asset inside the bundle.
  final String assetPath;

  /// Loads and validates all levels defined in the JSON file.
  Future<List<GradientPuzzleLevel>> loadLevels() async {
    final jsonString = await bundle.loadString(assetPath);
    final dynamic decoded = jsonDecode(jsonString);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Level file must contain a JSON object.');
    }
    final dynamic rawLevels = decoded['levels'];
    if (rawLevels is! List) {
      throw const FormatException('Level file must contain a "levels" array.');
    }

    final seenIds = <String>{};
    final levels = <GradientPuzzleLevel>[];
    for (final dynamic entry in rawLevels) {
      if (entry is! Map<String, dynamic>) {
        throw const FormatException('Each level entry must be a JSON object.');
      }
      levels.add(_parseLevel(entry, seenIds));
    }

    return List.unmodifiable(levels);
  }

  GradientPuzzleLevel _parseLevel(
    Map<String, dynamic> data,
    Set<String> seenIds,
  ) {
    final dynamic idValue = data['id'];
    if (idValue is! String || idValue.trim().isEmpty) {
      throw const FormatException('Each level requires a non-empty "id".');
    }
    final id = idValue.trim();
    if (!seenIds.add(id)) {
      throw FormatException('Duplicate level id "$id" found.');
    }

    final dynamic nameValue = data['name'];
    if (nameValue is! String || nameValue.trim().isEmpty) {
      throw FormatException('Level "$id" requires a non-empty "name".');
    }
    final name = nameValue.trim();

    final dynamic gridSizeValue = data['gridSize'];
    if (gridSizeValue is! int || gridSizeValue < 2) {
      throw FormatException(
        'Level "$id" requires an integer "gridSize" of at least 2.',
      );
    }
    final gridSize = gridSizeValue;

    final dynamic paletteValue = data['palette'];
    if (paletteValue is! List) {
      throw FormatException('Level "$id" requires a "palette" array.');
    }
    final palette = <Color>[];
    for (final dynamic entry in paletteValue) {
      palette.add(_parseColor(entry, id));
    }
    if (palette.length < 2) {
      throw FormatException('Level "$id" palette must contain at least 2 colors.');
    }

    final dynamic fixedValue = data['fixedCells'];
    final fixedCells = <int>{};
    if (fixedValue != null) {
      if (fixedValue is! List) {
        throw FormatException('Level "$id" fixedCells must be an array.');
      }
      for (final dynamic cell in fixedValue) {
        if (cell is! int) {
          throw FormatException(
            'Level "$id" fixedCells must contain only integers.',
          );
        }
        fixedCells.add(cell);
      }
    }

    final tileCount = gridSize * gridSize;
    for (final cell in fixedCells) {
      if (cell < 0 || cell >= tileCount) {
        throw FormatException(
          'Level "$id" has a fixed cell index out of range: $cell.',
        );
      }
    }

    return GradientPuzzleLevel(
      id: id,
      name: name,
      gridSize: gridSize,
      palette: List.unmodifiable(palette),
      fixedCells: Set<int>.unmodifiable(fixedCells),
    );
  }

  Color _parseColor(dynamic value, String levelId) {
    if (value is int) {
      if (value <= 0xFFFFFF) {
        return Color(0xFF000000 | value);
      }
      return Color(value);
    }
    if (value is! String) {
      throw FormatException(
        'Level "$levelId" has an invalid color value: $value.',
      );
    }
    var hex = value.trim();
    if (hex.isEmpty) {
      throw FormatException('Level "$levelId" has an empty color string.');
    }
    if (hex.startsWith('#')) {
      hex = hex.substring(1);
    }
    if (hex.startsWith('0x')) {
      hex = hex.substring(2);
    }
    if (hex.length == 6) {
      final parsed = int.tryParse(hex, radix: 16);
      if (parsed == null) {
        throw FormatException(
          'Level "$levelId" has an invalid color string "$value".',
        );
      }
      return Color(0xFF000000 | parsed);
    }
    if (hex.length == 8) {
      final parsed = int.tryParse(hex, radix: 16);
      if (parsed == null) {
        throw FormatException(
          'Level "$levelId" has an invalid color string "$value".',
        );
      }
      return Color(parsed);
    }
    throw FormatException(
      'Level "$levelId" colors must be 6 or 8 hex digits: "$value".',
    );
  }
}
