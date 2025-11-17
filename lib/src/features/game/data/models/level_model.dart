import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/level.dart';

class LevelModel extends Level {
  LevelModel({
    required super.id,
    required super.title,
    required super.description,
    required super.difficulty,
    required super.boardColumns,
    required super.boardRows,
    required super.isUnlocked,
  });

  factory LevelModel.fromJson(Map<String, dynamic> json) {
    final int? legacySize = json['boardSize'] as int?;
    final int columns =
        json['boardColumns'] as int? ?? legacySize ?? AppConstants.defaultBoardColumns;
    final int rows = json['boardRows'] as int? ?? legacySize ?? AppConstants.defaultBoardRows;
    return LevelModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      difficulty: json['difficulty'] as int,
      boardColumns: columns,
      boardRows: rows,
      isUnlocked: json['isUnlocked'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'description': description,
      'difficulty': difficulty,
      'boardColumns': boardColumns,
      'boardRows': boardRows,
      'isUnlocked': isUnlocked,
    };
  }

  LevelModel copyWith({
    String? id,
    String? title,
    String? description,
    int? difficulty,
    int? boardColumns,
    int? boardRows,
    bool? isUnlocked,
  }) {
    return LevelModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      difficulty: difficulty ?? this.difficulty,
      boardColumns: boardColumns ?? this.boardColumns,
      boardRows: boardRows ?? this.boardRows,
      isUnlocked: isUnlocked ?? this.isUnlocked,
    );
  }
}
