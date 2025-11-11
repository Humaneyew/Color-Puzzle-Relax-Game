/// Immutable snapshot of the player session exposed to the UI.
class GameStateSnapshot {
  const GameStateSnapshot({
    required this.levelId,
    required this.lives,
    required this.hints,
    required this.rewards,
    required this.highestUnlocked,
    required this.moveCount,
  });

  final String? levelId;
  final int lives;
  final int hints;
  final int rewards;
  final int highestUnlocked;
  final int moveCount;

  GameStateSnapshot copyWith({
    String? levelId,
    int? lives,
    int? hints,
    int? rewards,
    int? highestUnlocked,
    int? moveCount,
  }) {
    return GameStateSnapshot(
      levelId: levelId ?? this.levelId,
      lives: lives ?? this.lives,
      hints: hints ?? this.hints,
      rewards: rewards ?? this.rewards,
      highestUnlocked: highestUnlocked ?? this.highestUnlocked,
      moveCount: moveCount ?? this.moveCount,
    );
  }
}
