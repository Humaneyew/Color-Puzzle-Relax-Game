import 'package:meta/meta.dart';

import 'level.dart';

enum LevelStatus { locked, unlocked, completed }

@immutable
class LevelProgress {
  const LevelProgress({
    required this.levelId,
    this.status = LevelStatus.locked,
    this.bestMoves,
  });

  final String levelId;
  final LevelStatus status;
  final int? bestMoves;

  bool get isUnlocked => status != LevelStatus.locked;

  bool get isCompleted => status == LevelStatus.completed;

  LevelProgress copyWith({
    LevelStatus? status,
    int? bestMoves,
  }) {
    return LevelProgress(
      levelId: levelId,
      status: status ?? this.status,
      bestMoves: bestMoves ?? this.bestMoves,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'status': status.name,
      if (bestMoves != null) 'bestMoves': bestMoves,
    };
  }

  factory LevelProgress.fromJson(String levelId, Map<String, Object?> json) {
    final statusValue = json['status'] as String?;
    final status = LevelStatus.values.firstWhere(
      (value) => value.name == statusValue,
      orElse: () => LevelStatus.locked,
    );
    return LevelProgress(
      levelId: levelId,
      status: status,
      bestMoves: json['bestMoves'] as int?,
    );
  }
}

@immutable
class PlayerProgress {
  PlayerProgress({
    required Map<String, LevelProgress> levelStates,
    this.currentLevelId,
  }) : _levelStates = Map<String, LevelProgress>.unmodifiable(levelStates);

  final Map<String, LevelProgress> _levelStates;
  final String? currentLevelId;

  Map<String, LevelProgress> get levelStates => _levelStates;

  factory PlayerProgress.initial(List<GradientPuzzleLevel> levels) {
    final entries = <String, LevelProgress>{};
    for (var i = 0; i < levels.length; i++) {
      final level = levels[i];
      final status = i == 0 ? LevelStatus.unlocked : LevelStatus.locked;
      entries[level.id] = LevelProgress(levelId: level.id, status: status);
    }
    final currentId = levels.isEmpty ? null : levels.first.id;
    return PlayerProgress(levelStates: entries, currentLevelId: currentId);
  }

  factory PlayerProgress.fromJson(
    Map<String, Object?> json,
    List<GradientPuzzleLevel> levels,
  ) {
    final rawLevels = json['levels'];
    final mapped = <String, LevelProgress>{};
    if (rawLevels is Map<String, Object?>) {
      for (final entry in rawLevels.entries) {
        final value = entry.value;
        if (value is Map<String, Object?>) {
          mapped[entry.key] = LevelProgress.fromJson(entry.key, value);
        }
      }
    }
    for (var i = 0; i < levels.length; i++) {
      final level = levels[i];
      mapped.putIfAbsent(
        level.id,
        () => LevelProgress(
          levelId: level.id,
          status: i == 0 ? LevelStatus.unlocked : LevelStatus.locked,
        ),
      );
    }
    if (levels.isNotEmpty) {
      final firstLevelId = levels.first.id;
      final firstProgress = mapped[firstLevelId]!;
      if (!firstProgress.isUnlocked) {
        mapped[firstLevelId] =
            firstProgress.copyWith(status: LevelStatus.unlocked);
      }
    }
    final storedCurrent = json['currentLevelId'] as String?;
    final current =
        storedCurrent != null && mapped.containsKey(storedCurrent)
            ? storedCurrent
            : (levels.isEmpty ? null : levels.first.id);
    return PlayerProgress(levelStates: mapped, currentLevelId: current);
  }

  LevelProgress progressFor(String levelId) {
    return _levelStates[levelId] ?? LevelProgress(levelId: levelId);
  }

  bool isLevelUnlocked(String levelId) {
    return progressFor(levelId).isUnlocked;
  }

  bool isLevelCompleted(String levelId) {
    return progressFor(levelId).isCompleted;
  }

  PlayerProgress updateLevel(LevelProgress progress) {
    final updated = Map<String, LevelProgress>.from(_levelStates);
    updated[progress.levelId] = progress;
    return PlayerProgress(levelStates: updated, currentLevelId: currentLevelId);
  }

  PlayerProgress unlockLevel(String levelId) {
    final existing = progressFor(levelId);
    if (existing.status == LevelStatus.completed) {
      return updateLevel(existing);
    }
    return updateLevel(existing.copyWith(status: LevelStatus.unlocked));
  }

  PlayerProgress withCurrentLevel(String? levelId) {
    return PlayerProgress(levelStates: _levelStates, currentLevelId: levelId);
  }

  int? currentLevelIndex(List<GradientPuzzleLevel> levels) {
    if (currentLevelId == null) {
      return null;
    }
    final index = levels.indexWhere((level) => level.id == currentLevelId);
    return index < 0 ? null : index;
  }

  int highestUnlockedIndex(List<GradientPuzzleLevel> levels) {
    var highest = 0;
    for (var i = 0; i < levels.length; i++) {
      final id = levels[i].id;
      if (isLevelUnlocked(id)) {
        highest = i;
      } else {
        break;
      }
    }
    return highest;
  }

  Map<String, Object?> toJson() {
    return {
      'currentLevelId': currentLevelId,
      'levels': _levelStates.map(
        (key, value) => MapEntry(key, value.toJson()),
      ),
    };
  }
}
