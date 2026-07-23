import 'package:equatable/equatable.dart';

class TokenUsage extends Equatable {
  const TokenUsage({required this.promptTokens, required this.completionTokens});

  static const zero = TokenUsage(promptTokens: 0, completionTokens: 0);

  final int promptTokens;
  final int completionTokens;

  int get totalTokens => promptTokens + completionTokens;

  @override
  List<Object?> get props => [promptTokens, completionTokens];
}
