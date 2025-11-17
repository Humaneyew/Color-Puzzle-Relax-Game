import 'package:equatable/equatable.dart';

class Level extends Equatable {
  const Level({
    required this.id,
    required this.title,
    required this.description,
    required this.difficulty,
    required this.boardColumns,
    required this.boardRows,
    required this.isUnlocked,
  });

  final String id;
  final String title;
  final String description;
  final int difficulty;
  final int boardColumns;
  final int boardRows;
  final bool isUnlocked;

  Level copyWith({
    String? id,
    String? title,
    String? description,
    int? difficulty,
    int? boardColumns,
    int? boardRows,
    bool? isUnlocked,
  }) {
    return Level(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      difficulty: difficulty ?? this.difficulty,
      boardColumns: boardColumns ?? this.boardColumns,
      boardRows: boardRows ?? this.boardRows,
      isUnlocked: isUnlocked ?? this.isUnlocked,
    );
  }

  @override
  List<Object?> get props => <Object?>[
        id,
        title,
        description,
        difficulty,
        boardColumns,
        boardRows,
        isUnlocked,
      ];
}
