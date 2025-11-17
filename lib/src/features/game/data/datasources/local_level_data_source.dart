import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/level_model.dart';
import '../models/puzzle_level_model.dart';

abstract class LevelDataSource {
  Future<List<LevelModel>> loadLevels();
  Future<void> persistProgress(List<LevelModel> levels);
  Future<PuzzleLevelModel> loadPuzzle(String levelId);
}

class LocalLevelDataSource implements LevelDataSource {
  LocalLevelDataSource({AssetBundle? bundle}) : _bundle = bundle ?? rootBundle;

  static const String _assetPath = 'assets/data/puzzle_levels.json';
  final AssetBundle _bundle;

  List<LevelModel>? _levelsCache;
  Map<String, PuzzleLevelModel>? _puzzleCache;
  Future<void>? _initialization;

  @override
  Future<List<LevelModel>> loadLevels() async {
    await _ensureLoaded();
    return List<LevelModel>.unmodifiable(_levelsCache!);
  }

  @override
  Future<PuzzleLevelModel> loadPuzzle(String levelId) async {
    await _ensureLoaded();
    final PuzzleLevelModel? puzzle = _puzzleCache![levelId];
    if (puzzle == null) {
      throw ArgumentError('Unknown level: $levelId');
    }
    return puzzle;
  }

  @override
  Future<void> persistProgress(List<LevelModel> levels) async {
    _levelsCache = List<LevelModel>.from(levels);
  }

  Future<void> _ensureLoaded() {
    _initialization ??= _loadFromAsset();
    return _initialization!;
  }

  Future<void> _loadFromAsset() async {
    final String raw = await _bundle.loadString(_assetPath);
    final Map<String, dynamic> decoded = jsonDecode(raw) as Map<String, dynamic>;
    final List<dynamic> levelEntries = decoded['levels'] as List<dynamic>;

    final List<LevelModel> levels = <LevelModel>[];
    final Map<String, PuzzleLevelModel> puzzles = <String, PuzzleLevelModel>{};

    for (final dynamic entry in levelEntries) {
      final PuzzleLevelModel puzzle =
          PuzzleLevelModel.fromJson(entry as Map<String, dynamic>);
      final String levelId = puzzle.levelId;
      puzzles[levelId] = puzzle;
      levels.add(
        LevelModel(
          id: levelId,
          title: 'Level ${puzzle.id}',
          description: 'Restore palette ${puzzle.paletteId}.',
          difficulty: _difficultyToNumber(puzzle.difficulty),
          boardColumns: puzzle.cols,
          boardRows: puzzle.rows,
          isUnlocked: puzzle.id <= 2,
        ),
      );
    }

    _levelsCache = levels;
    _puzzleCache = puzzles;
  }

  int _difficultyToNumber(String difficulty) {
    switch (difficulty) {
      case 'easy':
        return 1;
      case 'medium':
        return 2;
      case 'hard':
        return 3;
      default:
        return 1;
    }
  }
}
