import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heroicons/heroicons.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_helper.dart';
import '../../../budget/presentation/providers/budget_providers.dart';
import '../providers/analytics_providers.dart';

class SpendingProjectionCard extends ConsumerWidget {
  const SpendingProjectionCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projection = ref.watch(spendingProjectionProvider);
    final primaryCurrency = ref.watch(primaryCurrencyProvider);
    final selectedGrowth = ref.watch(annualPriceGrowthProvider);

    if (projection.monthlySpend <= 0) {
      return const SizedBox.shrink();
    }

    final hasGrowth = selectedGrowth > 0.0;

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
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const HeroIcon(
                    HeroIcons.arrowTrendingUp,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Future Cost Outlook',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Cumulative cost at ${CurrencyHelper.formatAmount(projection.monthlySpend, currency: primaryCurrency)}/month',
                        style: const TextStyle(
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

            // 4-Horizon Grid
            Row(
              children: [
                Expanded(
                  child: _buildHorizonTile(
                    label: '1 Year',
                    amount: projection.oneYearCost,
                    baseline: projection.oneYearBaseline,
                    currency: primaryCurrency,
                    isHighlight: false,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildHorizonTile(
                    label: '3 Years',
                    amount: projection.threeYearCost,
                    baseline: projection.threeYearBaseline,
                    currency: primaryCurrency,
                    isHighlight: false,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildHorizonTile(
                    label: '5 Years',
                    amount: projection.fiveYearCost,
                    baseline: projection.fiveYearBaseline,
                    currency: primaryCurrency,
                    isHighlight: true,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildHorizonTile(
                    label: '10 Years',
                    amount: projection.tenYearCost,
                    baseline: projection.tenYearBaseline,
                    currency: primaryCurrency,
                    isHighlight: false,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Estimated Annual Price Growth Chips
            Row(
              children: [
                const Text(
                  'Price Increase:',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Wrap(
                    spacing: 6,
                    children: [
                      _buildGrowthChip(ref, 0.0, '0% (Flat)', selectedGrowth),
                      _buildGrowthChip(ref, 0.03, '+3%/yr', selectedGrowth),
                      _buildGrowthChip(ref, 0.05, '+5%/yr', selectedGrowth),
                    ],
                  ),
                ),
              ],
            ),

            if (hasGrowth) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.amber.shade200),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.trending_up,
                      size: 16,
                      color: Colors.amber.shade900,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Estimated +${CurrencyHelper.formatAmount(projection.fiveYearPriceGrowthDelta, currency: primaryCurrency)} extra over 5 years due to ${(selectedGrowth * 100).toInt()}% annual price drift.',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.amber.shade900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHorizonTile({
    required String label,
    required double amount,
    required double baseline,
    required String currency,
    required bool isHighlight,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      decoration: BoxDecoration(
        color: isHighlight
            ? AppColors.primary.withValues(alpha: 0.08)
            : Colors.grey.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isHighlight
              ? AppColors.primary.withValues(alpha: 0.3)
              : Colors.grey.withValues(alpha: 0.12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isHighlight ? AppColors.primary : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            CurrencyHelper.formatAmount(amount, currency: currency),
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: isHighlight ? AppColors.primary : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrowthChip(
    WidgetRef ref,
    double growthValue,
    String label,
    double currentGrowth,
  ) {
    final isSelected = (growthValue - currentGrowth).abs() < 0.001;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      showCheckmark: false,
      labelStyle: TextStyle(
        fontSize: 11,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        color: isSelected ? Colors.white : AppColors.textSecondary,
      ),
      selectedColor: AppColors.primary,
      backgroundColor: Colors.grey.withValues(alpha: 0.08),
      onSelected: (_) {
        HapticFeedback.selectionClick();
        ref.read(annualPriceGrowthProvider.notifier).state = growthValue;
      },
    );
  }
}
