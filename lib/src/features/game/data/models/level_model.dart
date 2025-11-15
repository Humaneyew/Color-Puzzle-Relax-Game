import '../../domain/entities/level.dart';

class LevelModel extends Level {
  LevelModel({
    required super.id,
    required super.title,
    required super.description,
    required super.difficulty,
    required super.width,
    required super.height,
    required super.isUnlocked,
  });

  factory LevelModel.fromJson(Map<String, dynamic> json) {
    final int? width = json['width'] as int?;
    final int? height = json['height'] as int?;
    final int? boardSize = json['boardSize'] as int?;
    final int resolvedWidth = width ?? boardSize ?? 0;
    final int resolvedHeight = height ?? boardSize ?? 0;
    if (resolvedWidth <= 0 || resolvedHeight <= 0) {
      throw ArgumentError('Level dimensions must be positive.');
    }
    return LevelModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      difficulty: json['difficulty'] as int,
      width: resolvedWidth,
      height: resolvedHeight,
      isUnlocked: json['isUnlocked'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = <String, dynamic>{
      'id': id,
      'title': title,
      'description': description,
      'difficulty': difficulty,
      'width': width,
      'height': height,
      'isUnlocked': isUnlocked,
    };
    if (width == height) {
      json['boardSize'] = width;
    }
    return json;
  }

  LevelModel copyWith({
    String? id,
    String? title,
    String? description,
    int? difficulty,
    int? width,
    int? height,
    bool? isUnlocked,
  }) {
    return LevelModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      difficulty: difficulty ?? this.difficulty,
      width: width ?? this.width,
      height: height ?? this.height,
      isUnlocked: isUnlocked ?? this.isUnlocked,
    );
  }
}
