import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_helper.dart';
import '../../domain/entities/insight_entity.dart';

class CategoryPieChart extends StatefulWidget {
  final List<CategorySpending> categories;

  const CategoryPieChart({super.key, required this.categories});

  @override
  State<CategoryPieChart> createState() => _CategoryPieChartState();
}

class _CategoryPieChartState extends State<CategoryPieChart> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    if (widget.categories.isEmpty) {
      return const Center(child: Text('No category data available'));
    }

    return Column(
      children: [
        Expanded(
          child: PieChart(
            PieChartData(
              pieTouchData: PieTouchData(
                touchCallback: (FlTouchEvent event, pieTouchResponse) {
                  setState(() {
                    if (!event.isInterestedForInteractions ||
                        pieTouchResponse == null ||
                        pieTouchResponse.touchedSection == null) {
                      touchedIndex = -1;
                      return;
                    }

                    final newIndex =
                        pieTouchResponse.touchedSection!.touchedSectionIndex;
                    if (newIndex != touchedIndex && newIndex != -1) {
                      HapticFeedback.selectionClick();
                    }
                    touchedIndex = newIndex;
                  });
                },
              ),
              borderData: FlBorderData(show: false),
              sectionsSpace: 2,
              centerSpaceRadius: 60,
              sections: _buildSections(),
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildLegend(),
      ],
    );
  }

  List<PieChartSectionData> _buildSections() {
    final colors = _getColors();

    return widget.categories.asMap().entries.map((entry) {
      final index = entry.key;
      final category = entry.value;
      final isTouched = index == touchedIndex;
      final fontSize = isTouched ? 16.0 : 12.0;
      final radius = isTouched ? 65.0 : 55.0;

      return PieChartSectionData(
        color: colors[index % colors.length],
        value: category.amount,
        title: '${category.percentage.toStringAsFixed(1)}%',
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  Widget _buildLegend() {
    final colors = _getColors();

    return Wrap(
      spacing: 16,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: widget.categories.asMap().entries.map((entry) {
        final index = entry.key;
        final category = entry.value;
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
            Text(
              '${category.category} (${CurrencyHelper.formatAmount(category.amount)})',
              style: const TextStyle(fontSize: 11),
            ),
          ],
        );
      }).toList(),
    );
  }

  List<Color> _getColors() {
    return [
      AppColors.chartColor1,
      AppColors.chartColor2,
      AppColors.chartColor3,
      AppColors.chartColor4,
      AppColors.chartColor5,
      AppColors.chartColor6,
      AppColors.primary,
      AppColors.accent,
      AppColors.info,
      AppColors.warning,
    ];
  }
}
