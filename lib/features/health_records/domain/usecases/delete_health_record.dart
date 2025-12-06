import '../../data/repositories/health_record_repository.dart';

class DeleteHealthRecord {
  DeleteHealthRecord(this._repository);

  final HealthRecordRepository _repository;

  Future<int> call(int id) {
    return _repository.deleteRecord(id);
  }
}
