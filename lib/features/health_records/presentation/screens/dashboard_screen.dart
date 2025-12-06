import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../app.dart';
import '../providers/health_record_provider.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  static const Color _blue = Color(0xFF0A66FF);
  static const Color _paleBlue = Color(0xFFDCE7FF);
  static const Color _lightTile = Color(0xFFF5F5F7);
  static const Color _darkTile = Color(0xFF0B0B0B);

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HealthRecordProvider>();
    final summary = provider.todaySummary;
    final formatter = NumberFormat.decimalPattern();

    return Scaffold(
      backgroundColor: const Color(0xFFF2F3F7),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: provider.loadRecords,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            children: [
              _buildTopBar(context),
              const SizedBox(height: 12),
              Text(
                'Dashboard',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              _buildInfoBanner(context),
              const SizedBox(height: 16),
              _buildSummaryGrid(
                context,
                steps: formatter.format(summary.steps),
                calories: formatter.format(summary.calories),
                water: formatter.format(summary.water),
              ),
              const SizedBox(height: 16),
              _buildHydrationCard(context, provider),
              const SizedBox(height: 20),
              _buildQuickActions(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.pushNamed(context, AppRoutes.profile),
          child: const CircleAvatar(
            radius: 22,
            backgroundImage: NetworkImage('https://images.unsplash.com/photo-1544723795-3fb6469f5b39?auto=format&fit=crop&w=200&q=60'),
          ),
        ),
        const Spacer(),
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 4))],
          ),
          child: IconButton(
            icon: const Icon(Icons.notifications_none_rounded),
            color: Colors.black87,
            onPressed: () {},
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryGrid(BuildContext context, {required String steps, required String calories, required String water}) {
    final cards = [
      _SummaryCard(title: 'Steps', value: steps, unit: '', color: _blue, icon: Icons.directions_walk, textColor: Colors.white),
      _SummaryCard(title: 'Calories', value: calories, unit: 'cal', color: _darkTile, icon: Icons.local_fire_department_outlined, textColor: Colors.white),
      _SummaryCard(title: 'Water', value: water, unit: 'ml', color: _paleBlue, icon: Icons.opacity, textColor: Colors.black87),
      _SummaryCard(title: 'Records', value: '', unit: '', color: _lightTile, icon: Icons.list_alt, textColor: Colors.black87, footer: 'Tap History'),
    ];
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: cards.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.1,
      ),
      itemBuilder: (_, i) => cards[i],
    );
  }

  Widget _buildHydrationCard(BuildContext context, HealthRecordProvider provider) {
    final remaining = provider.remainingWater;
    final progressPercent = (provider.waterGoalProgress * 100).round();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 6))],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: const Color(0xFFECF4FF),
            ),
            child: const Icon(Icons.water_drop_outlined, color: _blue),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Daily hydration goal', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(
                  remaining == 0 ? 'Goal reached! Stay hydrated.' : '$remaining ml remaining',
                  style: const TextStyle(color: Colors.black54),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('$progressPercent%', style: const TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              SizedBox(
                width: 72,
                child: LinearProgressIndicator(
                  value: provider.waterGoalProgress,
                  minHeight: 6,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: const AlwaysStoppedAnimation<Color>(_blue),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('Add record'),
            onPressed: () => Navigator.pushNamed(context, AppRoutes.addEditRecord),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            icon: const Icon(Icons.list_alt),
            label: const Text('History'),
            onPressed: () => Navigator.pushNamed(context, AppRoutes.records),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoBanner(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 4))],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, color: Colors.black54),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              "See today's steps, calories, water, your hydration goal, and quick actions to add or view records.",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.title,
    required this.value,
    required this.unit,
    required this.color,
    required this.icon,
    required this.textColor,
    this.footer,
  });

  final String title;
  final String value;
  final String unit;
  final Color color;
  final IconData icon;
  final Color textColor;
  final String? footer;

  @override
  Widget build(BuildContext context) {
    final isDark = color.computeLuminance() < 0.2;
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 6),
            ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(title, style: TextStyle(color: textColor, fontWeight: FontWeight.w600)),
              const Spacer(),
              Icon(icon, color: textColor.withValues(alpha: 0.9), size: 20),
            ],
          ),
          const Spacer(),
          if (value.isNotEmpty)
            RichText(
              text: TextSpan(
                style: TextStyle(color: textColor),
                children: [
                  TextSpan(text: value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
                  if (unit.isNotEmpty) TextSpan(text: ' $unit', style: const TextStyle(fontSize: 12)),
                ],
              ),
            ),
          if (footer != null) ...[
            const SizedBox(height: 6),
            Text(footer!, style: TextStyle(color: textColor.withValues(alpha: 0.8))),
          ],
        ],
      ),
    );
  }
}
