import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/currency/currency_converter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_helper.dart';
import '../../../budget/presentation/providers/budget_providers.dart';
import '../../domain/services/price_hike_detector.dart';
import '../providers/subscription_notifier.dart';

class PriceHikeAlertCard extends ConsumerWidget {
  const PriceHikeAlertCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscriptions = ref.watch(subscriptionNotifierProvider).subscriptions;
    final primaryCurrency = ref.watch(primaryCurrencyProvider);
    final converter = ref.watch(currencyConverterProvider);

    final metrics = PriceHikeDetector.evaluateRecentPriceHikes(
      subscriptions: subscriptions,
      primaryCurrency: primaryCurrency,
      converter: converter,
    );

    if (!metrics.hasRecentHikes) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.deepOrange.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.deepOrange.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.deepOrange.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.trending_up_rounded,
                  color: Colors.deepOrange,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Price Increase Detected',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepOrange.shade900,
                      ),
                    ),
                    Text(
                      '${metrics.hikedSubscriptionsCount} subscription(s) increased prices (+${CurrencyHelper.formatAmount(metrics.totalMonthlyCreep, currency: primaryCurrency)}/mo · +${CurrencyHelper.formatAmount(metrics.totalAnnualCreep, currency: primaryCurrency)}/yr)',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.deepOrange.shade800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // List of hikes
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: metrics.hikes.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final hike = metrics.hikes[index];
              final sub = hike.subscription;
              final change = hike.latestChange;

              return InkWell(
                onTap: () {
                  HapticFeedback.lightImpact();
                  context.push('/subscriptions/${sub.id}');
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.deepOrange.shade100),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              sub.serviceName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${CurrencyHelper.formatAmount(change.previousAmount, currency: sub.currency)} → ${CurrencyHelper.formatAmount(change.newAmount, currency: sub.currency)} (${hike.daysSinceChange == 0 ? 'today' : '${hike.daysSinceChange}d ago'})',
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
                          color: Colors.deepOrange.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '+${hike.percentageChange.toStringAsFixed(1)}%',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepOrange.shade900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 10),

          // Bottom Action
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.deepOrange.shade900,
              side: BorderSide(color: Colors.deepOrange.shade200),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(vertical: 8),
              visualDensity: VisualDensity.compact,
            ),
            onPressed: () {
              HapticFeedback.lightImpact();
              context.push('/catalog');
            },
            icon: const Icon(Icons.search, size: 16),
            label: const Text(
              'Explore Lower-Tier Plans & Cancellation Guides',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
