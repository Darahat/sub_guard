import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heroicons/heroicons.dart';

import '../../../../core/currency/currency_converter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_helper.dart';
import '../../../budget/presentation/providers/budget_providers.dart';
import '../../../subscriptions/domain/entities/subscription_entity.dart';
import '../../../subscriptions/presentation/providers/subscription_notifier.dart';

class TopCostServicesCard extends ConsumerWidget {
  const TopCostServicesCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscriptions = ref.watch(subscriptionNotifierProvider).subscriptions;
    final primaryCurrency = ref.watch(primaryCurrencyProvider);
    final converter = ref.watch(currencyConverterProvider);

    final activeSubs = subscriptions
        .where((s) => s.status == SubscriptionStatus.active)
        .toList();
    if (activeSubs.isEmpty) return const SizedBox.shrink();

    // Map each subscription to its 5-year normalized cost
    final rankedItems = activeSubs.map((sub) {
      final monthly = _normalizeToMonthly(
        sub.effectivePersonalAmount,
        sub.billingCycle,
      );
      final convertedMonthly = converter.convert(
        amount: monthly,
        fromCurrency: sub.currency,
        toCurrency: primaryCurrency,
      );
      final fiveYearCost = convertedMonthly * 60.0;
      return (
        subscription: sub,
        monthly: convertedMonthly,
        fiveYearCost: fiveYearCost,
      );
    }).toList()..sort((a, b) => b.fiveYearCost.compareTo(a.fiveYearCost));

    final topItems = rankedItems.take(5).toList();
    final maxFiveYear = topItems.first.fiveYearCost;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.withValues(alpha: 0.15)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const HeroIcon(
                    HeroIcons.trophy,
                    color: Colors.orange,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Top 5-Year Lifetime Costs',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Subscriptions with the largest long-term impact',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: topItems.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = topItems[index];
                final sub = item.subscription;
                final fraction = maxFiveYear > 0
                    ? (item.fiveYearCost / maxFiveYear)
                    : 0.0;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              '#${index + 1}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              sub.serviceName,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '${CurrencyHelper.formatAmount(item.fiveYearCost, currency: primaryCurrency)} (5Y)',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: fraction.clamp(0.05, 1.0),
                        backgroundColor: Colors.grey.withValues(alpha: 0.1),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.primary,
                        ),
                        minHeight: 6,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${CurrencyHelper.formatAmount(item.monthly, currency: primaryCurrency)}/mo · ${sub.category ?? "General"}',
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  double _normalizeToMonthly(double amount, BillingCycle cycle) {
    switch (cycle) {
      case BillingCycle.daily:
        return amount * 30.4375;
      case BillingCycle.weekly:
        return amount * 4.348;
      case BillingCycle.monthly:
        return amount;
      case BillingCycle.quarterly:
        return amount / 3.0;
      case BillingCycle.yearly:
        return amount / 12.0;
    }
  }
}
