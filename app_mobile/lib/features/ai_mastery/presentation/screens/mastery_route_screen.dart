import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../daily_topic/daily_topic_providers.dart';
import '../widgets/mastery_async_section.dart';
import 'mastery_home_screen.dart';

/// The actual `/topic/:topicId` route target — resolves the path
/// param into a full `Topic` (title + body) before handing off to
/// [MasteryHomeScreen], which needs the body text to generate anything.
class MasteryRouteScreen extends ConsumerWidget {
  const MasteryRouteScreen({super.key, required this.topicId});

  final String topicId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topicAsync = ref.watch(topicByIdProvider(topicId));

    return Scaffold(
      appBar: topicAsync.isLoading || topicAsync.hasError ? AppBar() : null,
      body: MasteryAsyncSection(
        value: topicAsync,
        onRetry: () => ref.invalidate(topicByIdProvider(topicId)),
        builder: (context, topic) => MasteryHomeScreen(topic: topic),
      ),
    );
  }
}
