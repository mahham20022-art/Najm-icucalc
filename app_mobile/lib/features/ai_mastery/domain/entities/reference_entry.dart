import 'package:equatable/equatable.dart';

class ReferenceEntry extends Equatable {
  const ReferenceEntry(this.citation);

  final String citation;

  @override
  List<Object?> get props => [citation];
}
