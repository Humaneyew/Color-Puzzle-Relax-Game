import '../../domain/entities/level.dart';

class LevelModel extends Level {
  LevelModel({
    required super.id,
    required super.title,
    required super.description,
    required super.difficulty,
    required super.boardSize,
    required super.isUnlocked,
    this.bestScore,
    required this.worldAverage,
    required this.hintsRemaining,
  });

  final int? bestScore;
  final int worldAverage;
  final int hintsRemaining;

  factory LevelModel.fromJson(Map<String, dynamic> json) {
    return LevelModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      difficulty: json['difficulty'] as int,
      boardSize: json['boardSize'] as int,
      isUnlocked: json['isUnlocked'] as bool,
      bestScore: json['bestScore'] as int?,
      worldAverage: json['worldAverage'] as int,
      hintsRemaining: json['hintsRemaining'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'description': description,
      'difficulty': difficulty,
      'boardSize': boardSize,
      'isUnlocked': isUnlocked,
      'bestScore': bestScore,
      'worldAverage': worldAverage,
      'hintsRemaining': hintsRemaining,
    };
  }

  LevelModel copyWith({
    String? id,
    String? title,
    String? description,
    int? difficulty,
    int? boardSize,
    bool? isUnlocked,
    int? bestScore,
    int? worldAverage,
    int? hintsRemaining,
  }) {
    return LevelModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      difficulty: difficulty ?? this.difficulty,
      boardSize: boardSize ?? this.boardSize,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      bestScore: bestScore ?? this.bestScore,
      worldAverage: worldAverage ?? this.worldAverage,
      hintsRemaining: hintsRemaining ?? this.hintsRemaining,
    );
  }
}
