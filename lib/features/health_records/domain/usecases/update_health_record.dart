import '../../data/models/health_record.dart';
import '../../data/repositories/health_record_repository.dart';

class UpdateHealthRecord {
  UpdateHealthRecord(this._repository);

  final HealthRecordRepository _repository;

  Future<int> call(HealthRecord record) {
    return _repository.updateRecord(record);
  }
}
