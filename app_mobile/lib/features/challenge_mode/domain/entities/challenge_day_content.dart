import 'package:equatable/equatable.dart';

/// The static content shown for one day of the 100-day journey.
class ChallengeDayContent extends Equatable {
  const ChallengeDayContent({required this.day, required this.title, required this.body});

  /// 1-based, 1..100.
  final int day;
  final String title;
  final String body;

  @override
  List<Object?> get props => [day, title, body];
}
