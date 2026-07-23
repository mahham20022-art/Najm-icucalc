import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../daily_topic/domain/entities/topic.dart';
import '../../domain/entities/consultant_message.dart';
import '../viewmodels/consultant_view_model.dart';

class ConsultantChatView extends ConsumerStatefulWidget {
  const ConsultantChatView({super.key, required this.topic});

  final Topic topic;

  @override
  ConsumerState<ConsultantChatView> createState() => _ConsultantChatViewState();
}

class _ConsultantChatViewState extends ConsumerState<ConsultantChatView> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _send() {
    final text = _controller.text;
    if (text.trim().isEmpty) return;
    ref.read(consultantViewModelProvider(widget.topic).notifier).ask(text);
    _controller.clear();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(consultantViewModelProvider(widget.topic));
    final colors = AppColors.of(context);

    return Column(
      children: [
        Expanded(
          child: state.history.isEmpty && state.streamingText == null
              ? _EmptyState(topicTitle: widget.topic.title)
              : ListView(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(AppSpacing.space4),
                  children: [
                    for (final message in state.history) _MessageBubble(message: message),
                    if (state.streamingText != null)
                      _MessageBubble(
                        message: ConsultantMessage(
                          speaker: ConsultantSpeaker.consultant,
                          content: state.streamingText!,
                        ),
                      ),
                    if (state.error != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: AppSpacing.space2),
                        child: Text(
                          state.error!.message,
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(color: colors.danger),
                        ),
                      ),
                  ],
                ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.space3),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    minLines: 1,
                    maxLines: 4,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _send(),
                    decoration: const InputDecoration(hintText: 'Ask the consultant a question…'),
                    enabled: !state.sending,
                  ),
                ),
                const SizedBox(width: AppSpacing.space2),
                IconButton.filled(
                  onPressed: state.sending ? null : _send,
                  icon: state.sending
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.arrow_upward),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.topicTitle});
  final String topicTitle;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.space6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.medical_services_outlined, size: 36, color: colors.labelTertiary),
            const SizedBox(height: AppSpacing.space3),
            Text(
              'Ask a follow-up question about "$topicTitle" — like consulting a '
              'colleague.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: colors.labelSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});

  final ConsultantMessage message;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final textTheme = Theme.of(context).textTheme;
    final isUser = message.speaker == ConsultantSpeaker.user;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: AppSpacing.space2),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.space4,
          vertical: AppSpacing.space3,
        ),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
        decoration: BoxDecoration(
          color: isUser ? colors.accentFill : colors.backgroundSecondary,
          borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        ),
        child: Text(
          message.content,
          style: textTheme.bodyLarge?.copyWith(color: isUser ? Colors.white : colors.labelPrimary),
        ),
      ),
    );
  }
}
