import 'package:equatable/equatable.dart';

class ComparisonTable extends Equatable {
  const ComparisonTable({required this.title, required this.columns, required this.rows});

  final String title;
  final List<String> columns;

  /// Each row's length matches [columns].length — enforced when parsing
  /// the AI response, not assumed by consumers.
  final List<List<String>> rows;

  @override
  List<Object?> get props => [title, columns, rows];
}
