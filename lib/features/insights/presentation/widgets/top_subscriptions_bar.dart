import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_helper.dart';
import '../../domain/entities/insight_entity.dart';

class TopSubscriptionsBar extends StatelessWidget {
  final List<TopSubscription> topSubscriptions;

  const TopSubscriptionsBar({super.key, required this.topSubscriptions});

  @override
  Widget build(BuildContext context) {
    if (topSubscriptions.isEmpty) {
      return const Center(child: Text('No subscription data available'));
    }

    final maxAmount = topSubscriptions
        .map((s) => s.monthlyAmount)
        .reduce((a, b) => a > b ? a : b);

    return Padding(
      padding: const EdgeInsets.only(right: 16, top: 16),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxAmount * 1.2,
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final sub = topSubscriptions[group.x.toInt()];
                return BarTooltipItem(
                  '${sub.serviceName}\n${CurrencyHelper.formatAmount(sub.monthlyAmount)}/mo\n${CurrencyHelper.formatAmount(sub.yearlyAmount)}/yr',
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() >= topSubscriptions.length) {
                    return const Text('');
                  }
                  final sub = topSubscriptions[value.toInt()];
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      sub.serviceName.length > 8
                          ? '${sub.serviceName.substring(0, 8)}...'
                          : sub.serviceName,
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  );
                },
                reservedSize: 30,
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 50,
                getTitlesWidget: (value, meta) {
                  return Text(
                    CurrencyHelper.formatAmount(value),
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.textSecondary,
                    ),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border(
              left: BorderSide(color: AppColors.border),
              bottom: BorderSide(color: AppColors.border),
            ),
          ),
          barGroups: topSubscriptions.asMap().entries.map((entry) {
            return BarChartGroupData(
              x: entry.key,
              barRods: [
                BarChartRodData(
                  toY: entry.value.monthlyAmount,
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [AppColors.primary, AppColors.accent],
                  ),
                  width: 20,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(6),
                  ),
                ),
              ],
            );
          }).toList(),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: maxAmount / 5,
            getDrawingHorizontalLine: (value) {
              return FlLine(color: AppColors.border, strokeWidth: 1);
            },
          ),
        ),
      ),
    );
  }
}
