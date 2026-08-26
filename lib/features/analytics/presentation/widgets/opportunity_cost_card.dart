import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_helper.dart';
import '../../../budget/presentation/providers/budget_providers.dart';
import '../../domain/services/opportunity_cost_calculator.dart';
import '../providers/analytics_providers.dart';

class OpportunityCostCard extends ConsumerStatefulWidget {
  const OpportunityCostCard({super.key});

  @override
  ConsumerState<OpportunityCostCard> createState() =>
      _OpportunityCostCardState();
}

class _OpportunityCostCardState extends ConsumerState<OpportunityCostCard> {
  double _monthlyAmount = 35.0;
  int _selectedYears = 5;
  double _selectedRate = 0.08;
  bool _isInitialized = false;

  @override
  Widget build(BuildContext context) {
    final opportunity = ref.watch(savingsOpportunityProvider);
    final primaryCurrency = ref.watch(primaryCurrencyProvider);

    // Initialize with potential savings if available and not yet touched
    if (!_isInitialized) {
      if (opportunity.hasOpportunities &&
          opportunity.potentialMonthlySavings > 0) {
        _monthlyAmount = opportunity.potentialMonthlySavings;
      }
      _isInitialized = true;
    }

    final result = OpportunityCostCalculator.calculate(
      monthlyContribution: _monthlyAmount,
      annualReturnRate: _selectedRate,
      years: _selectedYears,
    );

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
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.indigo.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.trending_up,
                    color: Colors.indigo,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Opportunity Cost Simulator',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'What recurring savings could become if invested',
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

            // Monthly Saving Selector
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Monthly Saving:',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
                Text(
                  CurrencyHelper.formatAmount(
                    _monthlyAmount,
                    currency: primaryCurrency,
                  ),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              children: [20, 35, 50, 75, 100].map((val) {
                final isSelected = (_monthlyAmount - val).abs() < 0.5;
                return ChoiceChip(
                  label: Text('\$$val/mo'),
                  selected: isSelected,
                  showCheckmark: false,
                  selectedColor: Colors.indigo,
                  labelStyle: TextStyle(
                    fontSize: 11,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                  ),
                  onSelected: (_) {
                    HapticFeedback.selectionClick();
                    setState(() => _monthlyAmount = val.toDouble());
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 14),

            // Time Horizon
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Time Horizon:',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
                Row(
                  children: [1, 3, 5, 10].map((years) {
                    final isSelected = _selectedYears == years;
                    return Padding(
                      padding: const EdgeInsets.only(left: 6),
                      child: ChoiceChip(
                        label: Text('${years}Y'),
                        selected: isSelected,
                        showCheckmark: false,
                        selectedColor: Colors.indigo,
                        labelStyle: TextStyle(
                          fontSize: 11,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: isSelected
                              ? Colors.white
                              : AppColors.textSecondary,
                        ),
                        onSelected: (_) {
                          HapticFeedback.selectionClick();
                          setState(() => _selectedYears = years);
                        },
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Return Scenario
            const Text(
              'Growth Scenario:',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              children: [
                _buildScenarioChip(0.05, '5% Conservative', _selectedRate),
                _buildScenarioChip(0.08, '8% Moderate', _selectedRate),
                _buildScenarioChip(0.10, '10% Optimistic', _selectedRate),
              ],
            ),
            const SizedBox(height: 16),

            // Compound Growth Highlight Box
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.indigo.shade900, Colors.indigo.shade700],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'POTENTIAL VALUE AFTER $_selectedYears ${_selectedYears == 1 ? "YEAR" : "YEARS"}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.white70,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    CurrencyHelper.formatAmount(
                      result.futureValue,
                      currency: primaryCurrency,
                    ),
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Divider(color: Colors.white24, height: 1),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Your Contributions',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.white70,
                            ),
                          ),
                          Text(
                            CurrencyHelper.formatAmount(
                              result.totalContributions,
                              currency: primaryCurrency,
                            ),
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text(
                            'Estimated Growth',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.white70,
                            ),
                          ),
                          Text(
                            '+${CurrencyHelper.formatAmount(result.compoundGrowth, currency: primaryCurrency)}',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.greenAccent,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Financial Disclaimer
            const Text(
              '⚠️ These are hypothetical educational projections, not guaranteed investment returns or financial advice.',
              style: TextStyle(
                fontSize: 10,
                color: AppColors.textSecondary,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScenarioChip(double rate, String label, double currentRate) {
    final isSelected = (rate - currentRate).abs() < 0.001;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      showCheckmark: false,
      selectedColor: Colors.indigo,
      labelStyle: TextStyle(
        fontSize: 11,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        color: isSelected ? Colors.white : AppColors.textSecondary,
      ),
      onSelected: (_) {
        HapticFeedback.selectionClick();
        setState(() => _selectedRate = rate);
      },
    );
  }
}
