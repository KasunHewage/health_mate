import 'package:flutter/material.dart';

import '../../data/models/health_record.dart';

class HealthRecordListItem extends StatelessWidget {
  const HealthRecordListItem({
    super.key,
    required this.record,
    this.onTap,
    this.onDelete,
  });

  final HealthRecord record;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      record.date,
                      style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: onDelete,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _StatRow(
                icon: Icons.directions_walk,
                label: 'Steps',
                value: record.steps.toString(),
              ),
              const SizedBox(height: 8),
              _StatRow(
                icon: Icons.local_fire_department_outlined,
                label: 'Calories',
                value: record.calories.toString(),
              ),
              const SizedBox(height: 8),
              _StatRow(
                icon: Icons.opacity,
                label: 'Water (ml)',
                value: record.water.toString(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 10),
        Text(label, style: textTheme.bodyMedium),
        const Spacer(),
        Text(
          value,
          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
