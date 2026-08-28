import 'package:flutter/material.dart';
import 'package:heroicons/heroicons.dart';

import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/currency_helper.dart';

class StatsCard extends StatelessWidget {
  final String title;
  final double? amount;
  final int? count;
  final HeroIcons icon;
  final Color color;

  const StatsCard({
    super.key,
    required this.title,
    this.amount,
    this.count,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              HeroIcon(icon, color: color, size: 22),
              Text(title.toUpperCase(), style: AppTypography.sectionOverhead),
            ],
          ),
          const SizedBox(height: 8),
          if (amount != null)
            Text(
              CurrencyHelper.formatAmount(amount!),
              style: AppTypography.cardFinancial.copyWith(color: color),
            )
          else if (count != null)
            Text(
              count.toString(),
              style: AppTypography.cardFinancial.copyWith(color: color),
            ),
        ],
      ),
    );
  }
}
