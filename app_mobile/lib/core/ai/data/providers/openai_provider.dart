import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../domain/entities/ai_message.dart';
import '../../domain/entities/ai_provider_id.dart';
import '../../domain/entities/token_usage.dart';
import '../../domain/repositories/ai_provider.dart';
import '../config/ai_engine_config.dart';

class _ModelPricing {
  const _ModelPricing(this.promptPerThousand, this.completionPerThousand);
  final double promptPerThousand;
  final double completionPerThousand;
}

/// OpenAI's Chat Completions API — non-streaming JSON and SSE streaming
/// both hit `/chat/completions`, differing only in the `stream` flag and
/// response shape.
class OpenAiProvider implements AiProvider {
  OpenAiProvider({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  /// USD per 1K tokens, as published on OpenAI's pricing page at the
  /// time this was written — update alongside any model change in
  /// `AiEngineConfig`. Falls back to [defaultModel]'s price for an
  /// unrecognized model rather than throwing, so a new/renamed model the
  /// engine hasn't been updated for yet still gets a cost estimate
  /// (approximate, not silently `0`) instead of crashing.
  static const _pricing = <String, _ModelPricing>{
    'gpt-4o-mini': _ModelPricing(0.15, 0.60),
    'gpt-4o': _ModelPricing(2.50, 10.00),
  };

  @override
  AiProviderId get id => AiProviderId.openAi;

  @override
  String get defaultModel => AiEngineConfig.openAiDefaultModel;

  @override
  double costPerThousandPromptTokensUsd(String model) =>
      (_pricing[model] ?? _pricing[defaultModel]!).promptPerThousand;

  @override
  double costPerThousandCompletionTokensUsd(String model) =>
      (_pricing[model] ?? _pricing[defaultModel]!).completionPerThousand;

  @override
  Future<AiProviderCompletion> complete({
    required List<AiMessage> messages,
    required int maxTokens,
    required double temperature,
    String? model,
  }) async {
    _requireApiKey();
    final resolvedModel = model ?? defaultModel;

    final response = await _client.post(
      Uri.parse('${AiEngineConfig.openAiBaseUrl}/chat/completions'),
      headers: _headers,
      body: jsonEncode({
        'model': resolvedModel,
        'messages': messages.map(_toOpenAiMessage).toList(),
        'max_tokens': maxTokens,
        'temperature': temperature,
      }),
    );
    if (response.statusCode != 200) {
      throw AiProviderHttpException(response.statusCode, response.body);
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final choice = (json['choices'] as List).first as Map<String, dynamic>;
    final content = (choice['message'] as Map<String, dynamic>)['content'] as String? ?? '';
    final usage = json['usage'] as Map<String, dynamic>?;

    return AiProviderCompletion(
      content: content,
      model: (json['model'] as String?) ?? resolvedModel,
      usage: TokenUsage(
        promptTokens: (usage?['prompt_tokens'] as int?) ?? 0,
        completionTokens: (usage?['completion_tokens'] as int?) ?? 0,
      ),
    );
  }

  @override
  Stream<AiProviderStreamEvent> completeStream({
    required List<AiMessage> messages,
    required int maxTokens,
    required double temperature,
    String? model,
  }) async* {
    _requireApiKey();
    final resolvedModel = model ?? defaultModel;

    final request =
        http.Request('POST', Uri.parse('${AiEngineConfig.openAiBaseUrl}/chat/completions'))
          ..headers.addAll(_headers)
          ..body = jsonEncode({
            'model': resolvedModel,
            'messages': messages.map(_toOpenAiMessage).toList(),
            'max_tokens': maxTokens,
            'temperature': temperature,
            'stream': true,
            'stream_options': {'include_usage': true},
          });

    final streamedResponse = await _client.send(request);
    if (streamedResponse.statusCode != 200) {
      final body = await streamedResponse.stream.bytesToString();
      throw AiProviderHttpException(streamedResponse.statusCode, body);
    }

    var promptTokens = 0;
    var completionTokens = 0;
    var resultModel = resolvedModel;

    final lines = streamedResponse.stream.transform(utf8.decoder).transform(const LineSplitter());
    await for (final line in lines) {
      if (!line.startsWith('data: ')) continue;
      final payload = line.substring(6).trim();
      if (payload == '[DONE]') {
        yield AiProviderStreamEvent(
          delta: '',
          done: true,
          model: resultModel,
          usage: TokenUsage(promptTokens: promptTokens, completionTokens: completionTokens),
        );
        return;
      }

      final json = jsonDecode(payload) as Map<String, dynamic>;
      resultModel = (json['model'] as String?) ?? resultModel;
      final usage = json['usage'] as Map<String, dynamic>?;
      if (usage != null) {
        promptTokens = (usage['prompt_tokens'] as int?) ?? promptTokens;
        completionTokens = (usage['completion_tokens'] as int?) ?? completionTokens;
      }

      final choices = json['choices'] as List?;
      if (choices == null || choices.isEmpty) continue;
      final delta = (choices.first as Map<String, dynamic>)['delta'] as Map<String, dynamic>?;
      final content = delta?['content'] as String?;
      if (content != null && content.isNotEmpty) {
        yield AiProviderStreamEvent(delta: content, done: false);
      }
    }
  }

  void _requireApiKey() {
    if (AiEngineConfig.openAiApiKey.isEmpty) {
      throw const AiProviderHttpException(401, 'OpenAI API key is not configured');
    }
  }

  Map<String, String> get _headers => {
    'Authorization': 'Bearer ${AiEngineConfig.openAiApiKey}',
    'Content-Type': 'application/json',
  };

  Map<String, String> _toOpenAiMessage(AiMessage message) => {
    'role': switch (message.role) {
      AiMessageRole.system => 'system',
      AiMessageRole.user => 'user',
      AiMessageRole.assistant => 'assistant',
    },
    'content': message.content,
  };
}
