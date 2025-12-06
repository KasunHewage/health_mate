import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../app.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../data/models/health_record.dart';
import '../providers/health_record_provider.dart';
import '../widgets/health_record_list_item.dart';

class HealthRecordListScreen extends StatelessWidget {
  const HealthRecordListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HealthRecordProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filter by date',
            onPressed: () => _pickFilterDate(context),
          ),
          if (provider.filterDate != null)
            IconButton(
              icon: const Icon(Icons.clear),
              tooltip: 'Clear filter',
              onPressed: () => provider.filterByDate(null),
            ),
        ],
      ),
      body: provider.isLoading
          ? const LoadingIndicator()
          : provider.filteredRecords.isEmpty
              ? const EmptyState(
                  message: 'No records yet. Add your first health entry!',
                  icon: Icons.list_alt,
                )
              : RefreshIndicator(
                  onRefresh: provider.loadRecords,
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: provider.filteredRecords.length,
                    itemBuilder: (context, index) {
                      final record = provider.filteredRecords[index];
                      return HealthRecordListItem(
                        record: record,
                        onTap: () => _navigateToEdit(context, record),
                        onDelete: () => _confirmDeletion(context, record),
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, AppRoutes.addEditRecord),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _pickFilterDate(BuildContext context) async {
    final provider = context.read<HealthRecordProvider>();
    final now = DateTime.now();
    final initialDate = provider.filterDate ?? now;
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 2),
    );
    if (selectedDate != null) {
      await provider.filterByDate(selectedDate);
    }
  }

  void _navigateToEdit(BuildContext context, HealthRecord record) {
    Navigator.pushNamed(
      context,
      AppRoutes.addEditRecord,
      arguments: record,
    );
  }

  Future<void> _confirmDeletion(BuildContext context, HealthRecord record) async {
    final provider = context.read<HealthRecordProvider>();
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete record?'),
          content: Text('Delete entry for ${record.date}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete ?? false) {
      await provider.deleteRecord(record.id!);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Record deleted')),
      );
    }
  }
}
