import 'package:easy_localization/easy_localization.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:islamic_utils/islamic_utils.dart' as iu;
import '../../data/models/heir.dart';

class InheritancePieChart extends StatelessWidget {
  final List<iu.HeirShare> shares;

  const InheritancePieChart({super.key, required this.shares});

  @override
  Widget build(BuildContext context) {
    if (shares.isEmpty) return const SizedBox();

    final total = shares.fold<double>(0, (sum, s) => sum + s.totalValue);
    if (total == 0) return const SizedBox();

    final colors = [
      Colors.teal.shade600,
      Colors.blue.shade600,
      Colors.orange.shade600,
      Colors.purple.shade600,
      Colors.red.shade600,
      Colors.green.shade600,
      Colors.brown.shade600,
      Colors.cyan.shade600,
    ];

    return Column(
      children: [
        SizedBox(
          height: 220,
          child: PieChart(
            PieChartData(
              sections: shares.asMap().entries.map((entry) {
                final index = entry.key;
                final share = entry.value;
                final percentage = (share.totalValue / total) * 100;
                return PieChartSectionData(
                  color: colors[index % colors.length],
                  value: share.totalValue,
                  title: '${percentage.toStringAsFixed(1)}%',
                  radius: 60,
                  titleStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                );
              }).toList(),
              centerSpaceRadius: 40,
              sectionsSpace: 2,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 16,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: shares.asMap().entries.map((entry) {
            final index = entry.key;
            final share = entry.value;
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: colors[index % colors.length],
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Text(heirTypeLabelKey(share.heirType).tr(),
                    style: const TextStyle(fontSize: 12)),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }
}