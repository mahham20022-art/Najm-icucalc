import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../domain/entities/explanation_mode.dart';

class ExplanationInputView extends StatefulWidget {
  const ExplanationInputView({
    super.key,
    required this.mode,
    required this.draftText,
    required this.isListening,
    required this.onTextChanged,
    required this.onStartVoice,
    required this.onStopVoice,
    required this.onSubmit,
  });

  final ExplanationMode mode;
  final String draftText;
  final bool isListening;
  final ValueChanged<String> onTextChanged;
  final VoidCallback onStartVoice;
  final VoidCallback onStopVoice;
  final VoidCallback onSubmit;

  @override
  State<ExplanationInputView> createState() => _ExplanationInputViewState();
}

class _ExplanationInputViewState extends State<ExplanationInputView> {
  late final TextEditingController _controller = TextEditingController(text: widget.draftText);

  @override
  void didUpdateWidget(covariant ExplanationInputView oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only voice mode pushes text programmatically (the live transcript);
    // in written mode the field is the source of truth, so re-syncing it
    // here would fight the user's cursor position on every keystroke.
    if (widget.mode == ExplanationMode.voice && _controller.text != widget.draftText) {
      _controller.text = widget.draftText;
      _controller.selection = TextSelection.collapsed(offset: _controller.text.length);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canSubmit = widget.draftText.trim().isNotEmpty && !widget.isListening;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.space5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: widget.mode == ExplanationMode.written
                ? _WrittenInput(controller: _controller, onChanged: widget.onTextChanged)
                : _VoiceInput(
                    transcript: widget.draftText,
                    isListening: widget.isListening,
                    onStart: widget.onStartVoice,
                    onStop: widget.onStopVoice,
                  ),
          ),
          const SizedBox(height: AppSpacing.space4),
          FilledButton(
            onPressed: canSubmit ? widget.onSubmit : null,
            child: const Text('Submit for Evaluation'),
          ),
        ],
      ),
    );
  }
}

class _WrittenInput extends StatelessWidget {
  const _WrittenInput({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      maxLines: null,
      expands: true,
      textAlignVertical: TextAlignVertical.top,
      decoration: const InputDecoration(
        hintText: 'Explain this topic as if you were teaching a colleague…',
        alignLabelWithHint: true,
      ),
    );
  }
}

class _VoiceInput extends StatefulWidget {
  const _VoiceInput({
    required this.transcript,
    required this.isListening,
    required this.onStart,
    required this.onStop,
  });

  final String transcript;
  final bool isListening;
  final VoidCallback onStart;
  final VoidCallback onStop;

  @override
  State<_VoiceInput> createState() => _VoiceInputState();
}

class _VoiceInputState extends State<_VoiceInput> with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );

  @override
  void initState() {
    super.initState();
    if (widget.isListening) _pulseController.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(covariant _VoiceInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isListening && !oldWidget.isListening) {
      _pulseController.repeat(reverse: true);
    } else if (!widget.isListening && oldWidget.isListening) {
      _pulseController.stop();
      _pulseController.reset();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        Expanded(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.space4),
            decoration: BoxDecoration(
              color: colors.backgroundSecondary,
              borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
            ),
            child: widget.transcript.isEmpty
                ? Center(
                    child: Text(
                      widget.isListening
                          ? 'Listening… start speaking'
                          : 'Tap the microphone to start',
                      style: textTheme.bodyMedium?.copyWith(color: colors.labelSecondary),
                    ),
                  )
                : SingleChildScrollView(child: Text(widget.transcript, style: textTheme.bodyLarge)),
          ),
        ),
        const SizedBox(height: AppSpacing.space5),
        GestureDetector(
          onTap: widget.isListening ? widget.onStop : widget.onStart,
          child: AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              final scale = widget.isListening ? 1.0 + (_pulseController.value * 0.15) : 1.0;
              return Transform.scale(scale: scale, child: child);
            },
            child: Container(
              width: 72,
              height: 72,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: widget.isListening ? colors.danger : colors.accentFill,
                shape: BoxShape.circle,
              ),
              child: Icon(
                widget.isListening ? Icons.stop : Icons.mic,
                color: Colors.white,
                size: 32,
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.space2),
        Text(
          widget.isListening ? 'Tap to stop' : 'Tap to speak',
          style: textTheme.labelMedium?.copyWith(color: colors.labelSecondary),
        ),
      ],
    );
  }
}
