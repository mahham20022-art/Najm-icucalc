import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/ai/ai_providers.dart';
import 'data/repositories/mastery_repository_impl.dart';
import 'domain/repositories/mastery_repository.dart';
import 'domain/usecases/ask_consultant_usecase.dart';
import 'domain/usecases/get_algorithm_usecase.dart';
import 'domain/usecases/get_comparison_table_usecase.dart';
import 'domain/usecases/get_flashcards_usecase.dart';
import 'domain/usecases/get_mcqs_usecase.dart';
import 'domain/usecases/get_prose_section_usecase.dart';
import 'domain/usecases/get_references_usecase.dart';

/// The DI graph for AI Mastery Mode, following the same
/// repositoryProvider → useCaseProvider chain as every other feature —
/// there's no local datasource here, since `MasteryRepositoryImpl` is
/// implemented entirely on top of `core/ai`'s `aiEngineRepositoryProvider`.
final masteryRepositoryProvider = Provider<MasteryRepository>((ref) {
  return MasteryRepositoryImpl(ref.watch(aiEngineRepositoryProvider));
});

final getProseSectionUseCaseProvider = Provider<GetProseSectionUseCase>((ref) {
  return GetProseSectionUseCase(ref.watch(masteryRepositoryProvider));
});

final getComparisonTableUseCaseProvider = Provider<GetComparisonTableUseCase>((ref) {
  return GetComparisonTableUseCase(ref.watch(masteryRepositoryProvider));
});

final getAlgorithmUseCaseProvider = Provider<GetAlgorithmUseCase>((ref) {
  return GetAlgorithmUseCase(ref.watch(masteryRepositoryProvider));
});

final getMcqsUseCaseProvider = Provider<GetMcqsUseCase>((ref) {
  return GetMcqsUseCase(ref.watch(masteryRepositoryProvider));
});

final getFlashcardsUseCaseProvider = Provider<GetFlashcardsUseCase>((ref) {
  return GetFlashcardsUseCase(ref.watch(masteryRepositoryProvider));
});

final getReferencesUseCaseProvider = Provider<GetReferencesUseCase>((ref) {
  return GetReferencesUseCase(ref.watch(masteryRepositoryProvider));
});

final askConsultantUseCaseProvider = Provider<AskConsultantUseCase>((ref) {
  return AskConsultantUseCase(ref.watch(masteryRepositoryProvider));
});
