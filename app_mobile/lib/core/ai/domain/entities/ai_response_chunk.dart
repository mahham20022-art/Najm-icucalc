import 'package:equatable/equatable.dart';

import 'ai_response.dart';

/// One increment of a streamed generation. [finalResponse] is populated
/// only on the terminal chunk (`done == true`), once the full content,
/// usage, and cost are known — mirrors the non-streaming [AiResponse]
/// so a caller can treat "the answer, once streaming finishes" the same
/// way whether it arrived via `generate` or `generateStream`.
class AiResponseChunk extends Equatable {
  const AiResponseChunk({required this.delta, required this.done, this.finalResponse});

  final String delta;
  final bool done;
  final AiResponse? finalResponse;

  @override
  List<Object?> get props => [delta, done, finalResponse];
}
