import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_helper.dart';
import '../../../../core/utils/date_helper.dart';
import '../../domain/entities/price_change_record.dart';
import '../../domain/entities/subscription_entity.dart';

class PriceHistoryTimeline extends StatelessWidget {
  final SubscriptionEntity subscription;

  const PriceHistoryTimeline({super.key, required this.subscription});

  @override
  Widget build(BuildContext context) {
    if (subscription.priceHistory.isEmpty) return const SizedBox.shrink();

    // Sort descending by date
    final history = List<PriceChangeRecord>.from(subscription.priceHistory)
      ..sort((a, b) => b.changedAt.compareTo(a.changedAt));

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.history_rounded,
                  color: AppColors.primary,
                  size: 18,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Price Change History',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: history.length,
            separatorBuilder: (context, index) => const Divider(height: 16),
            itemBuilder: (context, index) {
              final item = history[index];
              final isHike = item.isIncrease;

              final badgeBg = isHike
                  ? Colors.red.shade50
                  : Colors.green.shade50;
              final badgeTextCol = isHike ? AppColors.error : AppColors.success;
              final icon = isHike ? Icons.trending_up : Icons.trending_down;

              return Row(
                children: [
                  Icon(icon, size: 18, color: badgeTextCol),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${CurrencyHelper.formatAmount(item.previousAmount, currency: item.currency)} → ${CurrencyHelper.formatAmount(item.newAmount, currency: item.currency)}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          DateHelper.formatDisplayDate(item.changedAt),
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: badgeBg,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${isHike ? '+' : ''}${item.percentageChange.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: badgeTextCol,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
