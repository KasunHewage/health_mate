import '../../../../core/utils/date_utils.dart';
import '../../data/repositories/health_record_repository.dart';

class TodaySummary {
  const TodaySummary({this.steps = 0, this.calories = 0, this.water = 0});

  final int steps;
  final int calories;
  final int water;
}

class GetTodaySummary {
  GetTodaySummary(this._repository);

  final HealthRecordRepository _repository;

  Future<TodaySummary> call({DateTime? referenceDate}) async {
    final targetDate = AppDateUtils.formatDate(referenceDate ?? DateTime.now());
    final records = await _repository.getRecords();
    final todaysRecords = records.where((record) => record.date == targetDate);

    final totals = todaysRecords.fold<TodaySummary>(
      const TodaySummary(),
      (previous, record) => TodaySummary(
        steps: previous.steps + record.steps,
        calories: previous.calories + record.calories,
        water: previous.water + record.water,
      ),
    );

    return totals;
  }
}
