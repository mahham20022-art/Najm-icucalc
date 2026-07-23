import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/teaching_session.dart';
import '../../teaching_providers.dart';

/// This topic's past Teaching Mode attempts, most recent first — powers
/// the "Best score" indicator on the mode-selection step, the visible
/// evidence that "Store progress" actually persisted something.
final teachingSessionsForTopicProvider = StreamProvider.family<List<TeachingSession>, String>((
  ref,
  topicId,
) {
  return ref.watch(watchSessionsForTopicUseCaseProvider)(topicId);
});
