import '../datasources/health_record_db.dart';
import '../models/health_record.dart';

class HealthRecordRepository {
  HealthRecordRepository({HealthRecordDb? db}) : _db = db ?? HealthRecordDb.instance;

  final HealthRecordDb _db;

  Future<List<HealthRecord>> getRecords() {
    return _db.getRecords();
  }

  Future<HealthRecord?> getRecordByDate(String date) {
    return _db.getRecordByDate(date);
  }

  Future<int> addRecord(HealthRecord record) {
    return _db.insertRecord(record);
  }

  Future<int> updateRecord(HealthRecord record) {
    return _db.updateRecord(record);
  }

  Future<int> deleteRecord(int id) {
    return _db.deleteRecord(id);
  }
}
