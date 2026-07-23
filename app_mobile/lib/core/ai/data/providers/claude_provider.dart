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

/// Anthropic's Messages API. Unlike OpenAI, Claude takes the system
/// prompt as a separate top-level `system` field, not a message with
/// role `system` — [_buildBody] pulls any system-role [AiMessage]s out
/// of the generic list and joins them into that field, leaving only
/// user/assistant turns in `messages`.
class ClaudeProvider implements AiProvider {
  ClaudeProvider({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  /// USD per 1K tokens, as published on Anthropic's pricing page at the
  /// time this was written.
  static const _pricing = <String, _ModelPricing>{
    'claude-3-5-haiku-20241022': _ModelPricing(0.80, 4.00),
    'claude-3-5-sonnet-20241022': _ModelPricing(3.00, 15.00),
  };

  @override
  AiProviderId get id => AiProviderId.claude;

  @override
  String get defaultModel => AiEngineConfig.claudeDefaultModel;

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
      Uri.parse('${AiEngineConfig.claudeBaseUrl}/messages'),
      headers: _headers,
      body: jsonEncode(_buildBody(messages, maxTokens, temperature, resolvedModel)),
    );
    if (response.statusCode != 200) {
      throw AiProviderHttpException(response.statusCode, response.body);
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final blocks = json['content'] as List;
    final content = blocks
        .whereType<Map<String, dynamic>>()
        .where((block) => block['type'] == 'text')
        .map((block) => block['text'] as String)
        .join();
    final usage = json['usage'] as Map<String, dynamic>?;

    return AiProviderCompletion(
      content: content,
      model: (json['model'] as String?) ?? resolvedModel,
      usage: TokenUsage(
        promptTokens: (usage?['input_tokens'] as int?) ?? 0,
        completionTokens: (usage?['output_tokens'] as int?) ?? 0,
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

    final request = http.Request('POST', Uri.parse('${AiEngineConfig.claudeBaseUrl}/messages'))
      ..headers.addAll(_headers)
      ..body = jsonEncode(
        _buildBody(messages, maxTokens, temperature, resolvedModel, stream: true),
      );

    final streamedResponse = await _client.send(request);
    if (streamedResponse.statusCode != 200) {
      final body = await streamedResponse.stream.bytesToString();
      throw AiProviderHttpException(streamedResponse.statusCode, body);
    }

    var promptTokens = 0;
    var completionTokens = 0;

    final lines = streamedResponse.stream.transform(utf8.decoder).transform(const LineSplitter());
    await for (final line in lines) {
      if (!line.startsWith('data: ')) continue;
      final json = jsonDecode(line.substring(6)) as Map<String, dynamic>;

      switch (json['type'] as String?) {
        case 'message_start':
          final usage =
              (json['message'] as Map<String, dynamic>?)?['usage'] as Map<String, dynamic>?;
          promptTokens = (usage?['input_tokens'] as int?) ?? 0;
        case 'content_block_delta':
          final delta = json['delta'] as Map<String, dynamic>?;
          final text = delta?['text'] as String?;
          if (text != null && text.isNotEmpty) {
            yield AiProviderStreamEvent(delta: text, done: false);
          }
        case 'message_delta':
          final usage = json['usage'] as Map<String, dynamic>?;
          completionTokens = (usage?['output_tokens'] as int?) ?? completionTokens;
        case 'message_stop':
          yield AiProviderStreamEvent(
            delta: '',
            done: true,
            model: resolvedModel,
            usage: TokenUsage(promptTokens: promptTokens, completionTokens: completionTokens),
          );
          return;
      }
    }
  }

  Map<String, dynamic> _buildBody(
    List<AiMessage> messages,
    int maxTokens,
    double temperature,
    String model, {
    bool stream = false,
  }) {
    final systemPrompt = messages
        .where((message) => message.role == AiMessageRole.system)
        .map((message) => message.content)
        .join('\n\n');
    final turns = messages
        .where((message) => message.role != AiMessageRole.system)
        .map(_toClaudeMessage)
        .toList();

    return {
      'model': model,
      'max_tokens': maxTokens,
      'temperature': temperature,
      if (systemPrompt.isNotEmpty) 'system': systemPrompt,
      'messages': turns,
      if (stream) 'stream': true,
    };
  }

  Map<String, String> _toClaudeMessage(AiMessage message) => {
    'role': message.role == AiMessageRole.assistant ? 'assistant' : 'user',
    'content': message.content,
  };

  void _requireApiKey() {
    if (AiEngineConfig.claudeApiKey.isEmpty) {
      throw const AiProviderHttpException(401, 'Anthropic API key is not configured');
    }
  }

  Map<String, String> get _headers => {
    'x-api-key': AiEngineConfig.claudeApiKey,
    'anthropic-version': AiEngineConfig.claudeApiVersion,
    'content-type': 'application/json',
  };
}
