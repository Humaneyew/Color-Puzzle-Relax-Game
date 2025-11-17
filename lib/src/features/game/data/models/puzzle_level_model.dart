class PuzzleLevelModel {
  PuzzleLevelModel({
    required this.id,
    required this.rows,
    required this.cols,
    required this.solution,
    required this.anchors,
    required this.start,
    this.palette,
  });

  factory PuzzleLevelModel.fromJson(Map<String, dynamic> json) {
    return PuzzleLevelModel(
      id: json['id'] as int,
      rows: json['rows'] as int,
      cols: json['cols'] as int,
      solution: _convertColorMatrix(json['solution'] as List<dynamic>),
      anchors: _convertBoolMatrix(json['anchors'] as List<dynamic>),
      start: _convertColorMatrix(json['start'] as List<dynamic>),
      palette: (json['palette'] as List<dynamic>?)?.cast<String>(),
    );
  }

  final int id;
  final int rows;
  final int cols;
  final List<List<String>> solution;
  final List<List<String>> start;
  final List<List<bool>> anchors;
  final List<String>? palette;

  String get levelId => 'level_$id';

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
