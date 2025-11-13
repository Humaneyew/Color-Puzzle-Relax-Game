import 'package:equatable/equatable.dart';

class LabColor extends Equatable {
  const LabColor(this.l, this.a, this.b);

  final double l;
  final double a;
  final double b;

  LabColor copyWith({double? l, double? a, double? b}) {
    return LabColor(
      l ?? this.l,
      a ?? this.a,
      b ?? this.b,
    );
  }

  @override
  List<Object?> get props => <Object?>[l, a, b];
}
