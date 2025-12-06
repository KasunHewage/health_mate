import '../../data/models/health_record.dart';
import '../../data/repositories/health_record_repository.dart';

class GetHealthRecords {
  GetHealthRecords(this._repository);

  final HealthRecordRepository _repository;

  Future<List<HealthRecord>> call() {
    return _repository.getRecords();
  }
}
