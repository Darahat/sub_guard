import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_helper.dart';
import '../../domain/entities/insight_entity.dart';

class SpendingTrendChart extends StatefulWidget {
  final List<SpendingDataPoint> dataPoints;

  const SpendingTrendChart({super.key, required this.dataPoints});

  @override
  State<SpendingTrendChart> createState() => _SpendingTrendChartState();
}

class _SpendingTrendChartState extends State<SpendingTrendChart> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    if (widget.dataPoints.isEmpty) {
      return const Center(child: Text('No data available'));
    }

    final maxY = widget.dataPoints
        .map((p) => p.amount)
        .reduce((a, b) => a > b ? a : b);
    final minY = widget.dataPoints
        .map((p) => p.amount)
        .reduce((a, b) => a < b ? a : b);

    return Padding(
      padding: const EdgeInsets.only(right: 16, top: 16, bottom: 16),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: maxY / 5,
            getDrawingHorizontalLine: (value) {
              return FlLine(color: AppColors.border, strokeWidth: 1);
            },
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
                reservedSize: 30,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() >= widget.dataPoints.length) {
                    return const Text('');
                  }
                  final date = widget.dataPoints[value.toInt()].date;
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      DateFormat('MMM').format(date),
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: maxY / 5,
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
          minX: 0,
          maxX: (widget.dataPoints.length - 1).toDouble(),
          minY: minY * 0.8,
          maxY: maxY * 1.2,
          lineBarsData: [
            LineChartBarData(
              spots: widget.dataPoints
                  .asMap()
                  .entries
                  .map(
                    (entry) => FlSpot(entry.key.toDouble(), entry.value.amount),
                  )
                  .toList(),
              isCurved: true,
              color: AppColors.primary,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 4,
                    color: AppColors.primary,
                    strokeWidth: 2,
                    strokeColor: Colors.white,
                  );
                },
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.primary.withValues(alpha: 0.3),
                    AppColors.primary.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ],
          lineTouchData: LineTouchData(
            touchCallback: (FlTouchEvent event, lineTouchResponse) {
              setState(() {
                if (!event.isInterestedForInteractions ||
                    lineTouchResponse == null ||
                    lineTouchResponse.lineBarSpots == null ||
                    lineTouchResponse.lineBarSpots!.isEmpty) {
                  _touchedIndex = -1;
                  return;
                }

                final newIndex =
                    lineTouchResponse.lineBarSpots!.first.spotIndex;
                if (newIndex != _touchedIndex && newIndex != -1) {
                  HapticFeedback.selectionClick();
                }
                _touchedIndex = newIndex;
              });
            },
            touchTooltipData: LineTouchTooltipData(
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((spot) {
                  final date = widget.dataPoints[spot.x.toInt()].date;
                  final amount = spot.y;
                  final count =
                      widget.dataPoints[spot.x.toInt()].subscriptionCount;
                  return LineTooltipItem(
                    '${DateFormat('MMM yyyy').format(date)}\n${CurrencyHelper.formatAmount(amount)}\n$count subs',
                    const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  );
                }).toList();
              },
            ),
          ),
        ),
      ),
    );
  }
}
