import 'package:flutter_test/flutter_test.dart';

import 'package:health_mate/core/utils/date_utils.dart';

void main() {
  test('formatDate generates yyyy-MM-dd strings', () {
    final formatted = AppDateUtils.formatDate(DateTime(2024, 1, 2));
    expect(formatted, '2024-01-02');
  });

  test('isToday identifies today\'s date', () {
    final today = DateTime.now();
    final reference = DateTime(today.year, today.month, today.day);
    expect(AppDateUtils.isToday(reference), isTrue);
    expect(AppDateUtils.isToday(reference.subtract(const Duration(days: 1))), isFalse);
  });
}
