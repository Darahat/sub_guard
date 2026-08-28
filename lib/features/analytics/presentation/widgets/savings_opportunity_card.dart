import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:heroicons/heroicons.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_helper.dart';
import '../providers/analytics_providers.dart';

class SavingsOpportunityCard extends ConsumerWidget {
  const SavingsOpportunityCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final opportunity = ref.watch(savingsOpportunityProvider);

    if (!opportunity.hasOpportunities) {
      return const SizedBox.shrink();
    }

    final currency = opportunity.primaryCurrency;
    final subs = opportunity.subscriptionsToReview;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.green.shade200),
      ),
      color: Colors.green.shade50.withValues(alpha: 0.5),
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
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: HeroIcon(
                    HeroIcons.arrowTrendingDown,
                    color: Colors.green.shade800,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Potential Recurring Savings',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${subs.length} subscription(s) recommended for review',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.green.shade900,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Savings Metrics Row
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.shade100),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Monthly Saving',
                          style: TextStyle(
                            fontSize: 10,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          CurrencyHelper.formatAmount(
                            opportunity.potentialMonthlySavings,
                            currency: currency,
                          ),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(width: 1, height: 28, color: Colors.grey.shade200),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '1-Year Saving',
                          style: TextStyle(
                            fontSize: 10,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          CurrencyHelper.formatAmount(
                            opportunity.potentialAnnualSavings,
                            currency: currency,
                          ),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(width: 1, height: 28, color: Colors.grey.shade200),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '5-Year Saving',
                          style: TextStyle(
                            fontSize: 10,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          CurrencyHelper.formatAmount(
                            opportunity.potentialFiveYearSavings,
                            currency: currency,
                          ),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Candidate names chips
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: subs.take(4).map((sub) {
                return Chip(
                  padding: EdgeInsets.zero,
                  labelPadding: const EdgeInsets.symmetric(horizontal: 8),
                  label: Text(
                    '${sub.serviceName} (${CurrencyHelper.formatAmount(sub.effectivePersonalAmount, currency: sub.currency)})',
                    style: const TextStyle(fontSize: 11),
                  ),
                  backgroundColor: Colors.white,
                  side: BorderSide(color: Colors.green.shade200),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),

            // Link to Cancellation Vault
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.green.shade900,
                side: BorderSide(color: Colors.green.shade400),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                HapticFeedback.lightImpact();
                context.push('/vault');
              },
              icon: const Icon(Icons.shield_outlined, size: 16),
              label: const Text('Review Guides in Cancellation Vault'),
            ),
          ],
        ),
      ),
    );
  }
}
