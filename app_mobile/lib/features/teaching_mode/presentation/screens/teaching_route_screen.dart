import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/widgets/async_value_section.dart';
import '../../../daily_topic/daily_topic_providers.dart';
import 'teaching_mode_screen.dart';

/// The `/topic/:topicId/teach` route target — resolves the path param
/// into a full `Topic` before handing off to [TeachingModeScreen], which
/// needs the body text to evaluate an explanation against.
class TeachingRouteScreen extends ConsumerWidget {
  const TeachingRouteScreen({super.key, required this.topicId});

  final String topicId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topicAsync = ref.watch(topicByIdProvider(topicId));

    return Scaffold(
      appBar: topicAsync.isLoading || topicAsync.hasError ? AppBar() : null,
      body: AsyncValueSection(
        value: topicAsync,
        onRetry: () => ref.invalidate(topicByIdProvider(topicId)),
        builder: (context, topic) => TeachingModeScreen(topic: topic),
      ),
    );
  }
}
