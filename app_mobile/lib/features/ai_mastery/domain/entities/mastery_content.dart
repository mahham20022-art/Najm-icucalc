import 'package:equatable/equatable.dart';

import 'mastery_section_type.dart';

/// A generated prose section (Summary, Clinical Pearls, Diagnosis,
/// Management, Guidelines, Explain Simply, Explain Deeply) — the
/// structured sections (Comparison Tables, Algorithms, MCQs, Flashcards,
/// References) each have their own entity instead, since rendering them
/// as a professional UI needs their shape, not just a body string.
class MasteryContent extends Equatable {
  const MasteryContent({required this.section, required this.body, required this.cached});

  final MasterySectionType section;
  final String body;
  final bool cached;

  @override
  List<Object?> get props => [section, body, cached];
}
