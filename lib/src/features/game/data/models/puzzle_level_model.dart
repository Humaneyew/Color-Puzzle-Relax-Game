class PuzzleLevelModel {
  PuzzleLevelModel({
    required this.id,
    required this.rows,
    required this.cols,
    required this.paletteId,
    required this.solution,
    required this.fixedMask,
    required this.start,
    required this.difficulty,
  });

  factory PuzzleLevelModel.fromJson(Map<String, dynamic> json) {
    return PuzzleLevelModel(
      id: json['id'] as int,
      rows: json['rows'] as int,
      cols: json['cols'] as int,
      paletteId: json['paletteId'] as String,
      solution: _convertColorMatrix(json['solution'] as List<dynamic>),
      fixedMask: _convertBoolMatrix(json['fixedMask'] as List<dynamic>),
      start: _convertColorMatrix(json['start'] as List<dynamic>),
      difficulty: json['difficulty'] as String,
    );
  }

  final int id;
  final int rows;
  final int cols;
  final String paletteId;
  final List<List<String>> solution;
  final List<List<bool>> fixedMask;
  final List<List<String>> start;
  final String difficulty;

  String get levelId => 'level_$id';

  Set<int> get anchorIndices {
    final Set<int> indices = <int>{};
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        if (fixedMask[r][c]) {
          indices.add(r * cols + c);
        }
      }
    }
    return indices;
  }

  List<String> flattenSolution() => _flatten(solution);

  List<String> flattenStart() => _flatten(start);

  static List<List<String>> _convertColorMatrix(List<dynamic> raw) {
    return raw
        .map((dynamic row) => List<String>.from(row as List<dynamic>))
        .toList(growable: false);
  }

  static List<List<bool>> _convertBoolMatrix(List<dynamic> raw) {
    return raw
        .map((dynamic row) => List<bool>.from(row as List<dynamic>))
        .toList(growable: false);
  }

  static List<String> _flatten(List<List<String>> matrix) {
    if (matrix.isEmpty) {
      return <String>[];
    }
    final int cols = matrix.first.length;
    return List<String>.generate(
      matrix.length * cols,
      (int index) {
        final int row = index ~/ cols;
        final int col = index % cols;
        return matrix[row][col];
      },
      growable: false,
    );
  }
}
