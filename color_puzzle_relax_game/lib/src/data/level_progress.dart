import 'package:flutter/foundation.dart';

@immutable
class LevelProgress {
  const LevelProgress({
    this.highestUnlockedLevelIndex = 0,
    this.bestScores = const <String, int>{},
    this.completedLevelIds = const <String>{},
  });

  final int highestUnlockedLevelIndex;
  final Map<String, int> bestScores;
  final Set<String> completedLevelIds;

  const LevelProgress.initial()
      : highestUnlockedLevelIndex = 0,
        bestScores = const <String, int>{},
        completedLevelIds = const <String>{};

  LevelProgress copyWith({
    int? highestUnlockedLevelIndex,
    Map<String, int>? bestScores,
    Set<String>? completedLevelIds,
  }) {
    return LevelProgress(
      highestUnlockedLevelIndex:
          highestUnlockedLevelIndex ?? this.highestUnlockedLevelIndex,
      bestScores: bestScores ?? this.bestScores,
      completedLevelIds: completedLevelIds ?? this.completedLevelIds,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'highestUnlockedLevelIndex': highestUnlockedLevelIndex,
      'bestScores': bestScores,
      'completedLevelIds': completedLevelIds.toList(),
    };
  }

  factory LevelProgress.fromJson(Map<String, dynamic> json) {
    final rawScores = json['bestScores'];
    final scores = <String, int>{};
    if (rawScores is Map) {
      rawScores.forEach((key, value) {
        final k = key?.toString();
        final v = int.tryParse(value.toString());
        if (k != null && v != null) {
          scores[k] = v;
        }
      });
    }
    final completed = <String>{};
    final rawCompleted = json['completedLevelIds'];
    if (rawCompleted is Iterable) {
      for (final item in rawCompleted) {
        final id = item?.toString();
        if (id != null) {
          completed.add(id);
        }
      }
    }
    final highest = json['highestUnlockedLevelIndex'];
    return LevelProgress(
      highestUnlockedLevelIndex: highest is int
          ? highest
          : int.tryParse(highest.toString()) ?? 0,
      bestScores: scores,
      completedLevelIds: completed,
    );
  }
}
