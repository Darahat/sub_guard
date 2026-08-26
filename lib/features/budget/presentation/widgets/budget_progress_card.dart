import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_helper.dart';
import '../../domain/entities/budget_health.dart';
import '../providers/budget_providers.dart';

class BudgetProgressCard extends ConsumerWidget {
  const BudgetProgressCard({super.key});

  void _showSetBudgetModal(
    BuildContext context,
    WidgetRef ref,
    double? currentLimit,
  ) {
    HapticFeedback.selectionClick();
    final controller = TextEditingController(
      text: currentLimit != null && currentLimit > 0
          ? currentLimit.toStringAsFixed(0)
          : '100',
    );
    final primaryCurrency = ref.read(primaryCurrencyProvider);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Monthly Subscription Budget',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                if (currentLimit != null)
                  TextButton(
                    onPressed: () {
                      ref
                          .read(monthlyBudgetLimitProvider.notifier)
                          .setBudgetLimit(null);
                      Navigator.pop(ctx);
                    },
                    child: const Text(
                      'Clear',
                      style: TextStyle(color: AppColors.error),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Set a target to keep your recurring subscriptions under control.',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'Monthly Target ($primaryCurrency)',
                prefixIcon: const Icon(Icons.track_changes_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Quick Presets
            Wrap(
              spacing: 8,
              children: [50, 100, 150, 200, 300].map((preset) {
                return ActionChip(
                  label: Text('\$$preset'),
                  onPressed: () {
                    controller.text = preset.toString();
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () {
                final val = double.tryParse(controller.text.trim());
                if (val != null && val > 0) {
                  ref
                      .read(monthlyBudgetLimitProvider.notifier)
                      .setBudgetLimit(val);
                  Navigator.pop(ctx);
                }
              },
              child: const Text('Save Budget'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final evaluation = ref.watch(budgetEvaluationProvider);

    if (!evaluation.hasBudget) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.track_changes_outlined,
                color: AppColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Set Monthly Budget',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    'Track spending & get overspend guards',
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            FilledButton.tonal(
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () => _showSetBudgetModal(context, ref, null),
              child: const Text('Set Target', style: TextStyle(fontSize: 12)),
            ),
          ],
        ),
      );
    }

    final progress = evaluation.percentageUsed.clamp(0.0, 1.0);
    final percentageText = (evaluation.percentageUsed * 100).toStringAsFixed(1);

    Color healthColor;
    Color healthBgColor;
    String insightText;
    IconData healthIcon;

    switch (evaluation.health) {
      case BudgetHealth.onTrack:
        healthColor = AppColors.success;
        healthBgColor = Colors.green.shade50;
        insightText =
            '🎉 You\'re ${CurrencyHelper.formatAmount(evaluation.remainingBudget, currency: evaluation.primaryCurrency)} under budget ($percentageText% used)';
        healthIcon = Icons.check_circle_outline;
        break;
      case BudgetHealth.nearLimit:
        healthColor = AppColors.warning;
        healthBgColor = Colors.amber.shade50;
        insightText =
            '⚠️ Approaching limit (${CurrencyHelper.formatAmount(evaluation.remainingBudget, currency: evaluation.primaryCurrency)} remaining)';
        healthIcon = Icons.warning_amber_rounded;
        break;
      case BudgetHealth.overBudget:
        healthColor = AppColors.error;
        healthBgColor = Colors.red.shade50;
        final overAmount =
            evaluation.totalMonthlySpent - (evaluation.budgetLimit ?? 0);
        insightText =
            '🚨 ${CurrencyHelper.formatAmount(overAmount, currency: evaluation.primaryCurrency)} over monthly budget!';
        healthIcon = Icons.error_outline;
        break;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: evaluation.isOverBudget
              ? Colors.red.shade200
              : Colors.grey.shade200,
          width: evaluation.isOverBudget ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: healthColor.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Top Row: Header & Health Pill Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'MONTHLY SPENDING BUDGET',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                  color: AppColors.textSecondary,
                ),
              ),
              InkWell(
                onTap: () =>
                    _showSetBudgetModal(context, ref, evaluation.budgetLimit),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: healthBgColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: healthColor.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(healthIcon, size: 13, color: healthColor),
                      const SizedBox(width: 4),
                      Text(
                        evaluation.health.label,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: healthColor,
                        ),
                      ),
                      const SizedBox(width: 2),
                      Icon(Icons.edit, size: 10, color: healthColor),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Big Amount Numbers
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                CurrencyHelper.formatAmount(
                  evaluation.totalMonthlySpent,
                  currency: evaluation.primaryCurrency,
                ),
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: evaluation.isOverBudget
                      ? AppColors.error
                      : AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '/ ${CurrencyHelper.formatAmount(evaluation.budgetLimit ?? 0, currency: evaluation.primaryCurrency)}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Linear Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.grey.shade100,
              valueColor: AlwaysStoppedAnimation<Color>(healthColor),
            ),
          ),
          const SizedBox(height: 8),

          // Insight text
          Text(
            insightText,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: evaluation.isOverBudget
                  ? AppColors.error
                  : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
