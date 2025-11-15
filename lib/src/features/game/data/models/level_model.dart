import '../../domain/entities/level.dart';

class LevelModel extends Level {
  LevelModel({
    required super.id,
    required super.title,
    required super.description,
    required super.difficulty,
    required super.boardSize,
    required super.isUnlocked,
  });

  factory LevelModel.fromJson(Map<String, dynamic> json) {
    return LevelModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      difficulty: json['difficulty'] as int,
      boardSize: json['boardSize'] as int,
      isUnlocked: json['isUnlocked'] as bool,
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
    };
  }

  LevelModel copyWith({
    String? id,
    String? title,
    String? description,
    int? difficulty,
    int? boardSize,
    bool? isUnlocked,
  }) {
    return LevelModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      difficulty: difficulty ?? this.difficulty,
      boardSize: boardSize ?? this.boardSize,
      isUnlocked: isUnlocked ?? this.isUnlocked,
    );
  }
}
