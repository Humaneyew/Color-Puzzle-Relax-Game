import 'package:equatable/equatable.dart';

class Level extends Equatable {
  const Level({
    required this.id,
    required this.title,
    required this.description,
    required this.difficulty,
    required this.width,
    required this.height,
    required this.isUnlocked,
  }) : assert(width > 0, 'Level width must be positive'),
        assert(height > 0, 'Level height must be positive');

  final String id;
  final String title;
  final String description;
  final int difficulty;
  final int width;
  final int height;
  final bool isUnlocked;

  Level copyWith({
    String? id,
    String? title,
    String? description,
    int? difficulty,
    int? width,
    int? height,
    bool? isUnlocked,
  }) {
    return Level(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      difficulty: difficulty ?? this.difficulty,
      width: width ?? this.width,
      height: height ?? this.height,
      isUnlocked: isUnlocked ?? this.isUnlocked,
    );
  }

  @override
  List<Object?> get props => <Object?>[
        id,
        title,
        description,
        difficulty,
        width,
        height,
        isUnlocked,
      ];
}
