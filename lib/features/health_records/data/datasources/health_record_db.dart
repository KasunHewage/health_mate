import 'dart:async';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../../../../core/utils/date_utils.dart';
import '../models/health_record.dart';

class HealthRecordDb {
  HealthRecordDb._();

  static final HealthRecordDb instance = HealthRecordDb._();
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await _initDb();
    return _database!;
  }

  Future<Database> _initDb() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = join(directory.path, 'health_mate.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: _createDb,
    );
  }

  Future<void> _createDb(Database db, int version) async {
    await db.execute('''
      CREATE TABLE health_records(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT,
        steps INTEGER,
        calories INTEGER,
        water INTEGER
      )
    ''');

    await _seedData(db);
  }

  Future<void> _seedData(Database db) async {
    final now = DateTime.now();
    final dummyRecords = [
      HealthRecord(date: AppDateUtils.formatDate(now), steps: 8500, calories: 2100, water: 1800),
      HealthRecord(date: AppDateUtils.formatDate(now.subtract(const Duration(days: 1))), steps: 7200, calories: 1950, water: 2000),
      HealthRecord(date: AppDateUtils.formatDate(now.subtract(const Duration(days: 2))), steps: 10000, calories: 2300, water: 2200),
    ];

    final batch = db.batch();
    for (final record in dummyRecords) {
      batch.insert('health_records', record.toMap()..remove('id'));
    }
    await batch.commit(noResult: true);
  }

  Future<int> insertRecord(HealthRecord record) async {
    final db = await database;
    final data = record.toMap()..remove('id');
    return db.insert('health_records', data, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<HealthRecord>> getRecords() async {
    final db = await database;
    final results = await db.query('health_records', orderBy: 'date DESC');
    return results.map(HealthRecord.fromMap).toList();
  }

  Future<HealthRecord?> getRecordByDate(String date) async {
    final db = await database;
    final results = await db.query(
      'health_records',
      where: 'date = ?',
      whereArgs: [date],
      limit: 1,
    );
    if (results.isEmpty) {
      return null;
    }
    return HealthRecord.fromMap(results.first);
  }

  Future<int> updateRecord(HealthRecord record) async {
    if (record.id == null) {
      throw ArgumentError('Record id is required for update');
    }
    final db = await database;
    final data = record.toMap()..remove('id');
    return db.update(
      'health_records',
      data,
      where: 'id = ?',
      whereArgs: [record.id],
    );
  }

  Future<int> deleteRecord(int id) async {
    final db = await database;
    return db.delete(
      'health_records',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
