import '../models/topic_dto.dart';

/// Remote (Firestore/CDN-backed) data source contract. The foundation-
/// stage implementation below returns fixed sample data instead of
/// calling Firestore or the CDN — wiring up real content delivery
/// (including the free/premium split from `MED100_DATABASE_DESIGN.md`
/// §2) is feature work, not foundation work.
abstract interface class TopicRemoteDataSource {
  Future<TopicDto> fetchTodaysTopic();
  Future<TopicDto> fetchTopicById(String topicId);
}

class SampleTopicRemoteDataSource implements TopicRemoteDataSource {
  static const _sample = TopicDto(
    id: 'sample-topic-001',
    title: 'Recognizing Early Sepsis (Sample Content)',
    body:
        'Sepsis is life-threatening organ dysfunction caused by a dysregulated host '
        'response to infection. Early recognition hinges on trending vital signs '
        'rather than any single reading: a rising respiratory rate, new '
        'tachycardia, or a falling blood pressure in a patient with a suspected '
        'infection source should prompt an immediate qSOFA or NEWS2 assessment. '
        'Lactate elevation above 2 mmol/L signals tissue hypoperfusion even before '
        'hypotension develops, and is one of the strongest early predictors of '
        'deterioration. The Surviving Sepsis Campaign\'s "hour-1 bundle" calls for '
        'blood cultures before antibiotics, broad-spectrum antibiotics within one '
        'hour of recognition, 30 mL/kg crystalloid for hypotension or lactate ≥4, '
        'and vasopressors if the patient remains hypotensive after fluid '
        'resuscitation to maintain a MAP ≥65 mmHg. Delay in antibiotic '
        'administration is directly associated with increased mortality, roughly '
        '7-8% per hour of delay after the onset of hypotension, which is why '
        'sepsis protocols are built around minimizing time-to-recognition rather '
        'than diagnostic certainty.',
    specialtyId: 'critical-care',
    estimatedMinutes: 4,
    isFree: true,
    version: 1,
  );

  @override
  Future<TopicDto> fetchTodaysTopic() async => _sample;

  @override
  Future<TopicDto> fetchTopicById(String topicId) async => _sample;
}
