import 'package:flutter/foundation.dart';

import '../../../../core/utils/date_utils.dart';
import '../../data/models/health_record.dart';
import '../../data/repositories/health_record_repository.dart';
import '../../domain/usecases/add_health_record.dart';
import '../../domain/usecases/delete_health_record.dart';
import '../../domain/usecases/get_health_records.dart';
import '../../domain/usecases/get_today_summary.dart';
import '../../domain/usecases/update_health_record.dart';

class HealthRecordProvider extends ChangeNotifier {
  HealthRecordProvider({HealthRecordRepository? repository})
      : _repository = repository ?? HealthRecordRepository() {
    _getHealthRecords = GetHealthRecords(_repository);
    _addHealthRecord = AddHealthRecord(_repository);
    _updateHealthRecord = UpdateHealthRecord(_repository);
    _deleteHealthRecord = DeleteHealthRecord(_repository);
  }

  final HealthRecordRepository _repository;
  late final GetHealthRecords _getHealthRecords;
  late final AddHealthRecord _addHealthRecord;
  late final UpdateHealthRecord _updateHealthRecord;
  late final DeleteHealthRecord _deleteHealthRecord;

  final int _waterGoal = 2000;

  List<HealthRecord> _allRecords = <HealthRecord>[];
  List<HealthRecord> _filteredRecords = <HealthRecord>[];
  DateTime? _filterDate;
  TodaySummary _todaySummary = const TodaySummary();
  bool _isLoading = false;
  double _waterGoalProgress = 0;

  List<HealthRecord> get allRecords => List.unmodifiable(_allRecords);
  List<HealthRecord> get filteredRecords => List.unmodifiable(_filteredRecords);
  DateTime? get filterDate => _filterDate;
  TodaySummary get todaySummary => _todaySummary;
  bool get isLoading => _isLoading;
  double get waterGoalProgress => _waterGoalProgress;
  int get waterGoal => _waterGoal;
  int get remainingWater => (_waterGoal - _todaySummary.water).clamp(0, _waterGoal).toInt();

  Future<void> loadRecords() async {
    await _syncRecords(showLoader: true);
  }

  Future<void> addRecord(HealthRecord record) async {
    await _addHealthRecord(record);
    await _syncRecords();
  }

  Future<void> updateRecord(HealthRecord record) async {
    await _updateHealthRecord(record);
    await _syncRecords();
  }

  Future<void> deleteRecord(int id) async {
    await _deleteHealthRecord(id);
    await _syncRecords();
  }

  Future<void> filterByDate(DateTime? date) async {
    _filterDate = date;
    _applyFilter();
    notifyListeners();
  }

  Future<void> _syncRecords({bool showLoader = false}) async {
    if (showLoader) {
      _isLoading = true;
      notifyListeners();
    }

    _allRecords = await _getHealthRecords();
    _applyFilter();
    await _computeTodaySummary();

    if (showLoader) {
      _isLoading = false;
    }
    notifyListeners();
  }

  void _applyFilter() {
    if (_filterDate == null) {
      _filteredRecords = List<HealthRecord>.from(_allRecords);
    } else {
      final filterValue = AppDateUtils.formatDate(_filterDate!);
      _filteredRecords = _allRecords.where((record) => record.date == filterValue).toList();
    }
  }

  Future<void> _computeTodaySummary() async {
    final targetDate = AppDateUtils.formatDate(DateTime.now());
    final todaysRecords = _allRecords.where((record) => record.date == targetDate);
    _todaySummary = todaysRecords.fold<TodaySummary>(
      const TodaySummary(),
      (prev, record) => TodaySummary(
        steps: prev.steps + record.steps,
        calories: prev.calories + record.calories,
        water: prev.water + record.water,
      ),
    );
    _waterGoalProgress = (_todaySummary.water / _waterGoal).clamp(0, 1).toDouble();
  }
}
