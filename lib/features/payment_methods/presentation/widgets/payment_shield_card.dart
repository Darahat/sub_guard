import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heroicons/heroicons.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_helper.dart';
import '../../../budget/presentation/providers/budget_providers.dart';
import '../../domain/entities/payment_method_entity.dart';
import '../../domain/services/payment_shield_evaluator.dart';
import '../providers/payment_method_providers.dart';
import '../screens/reassign_payment_method_sheet.dart';

class PaymentShieldCard extends ConsumerWidget {
  const PaymentShieldCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final risks = ref.watch(paymentShieldRisksProvider);
    if (risks.isEmpty) return const SizedBox.shrink();

    final primaryCurrency = ref.watch(primaryCurrencyProvider);
    final hasExpired = risks.any(
      (r) => r.status == PaymentExpiryStatus.expired,
    );

    final bannerBg = hasExpired ? Colors.red.shade50 : Colors.amber.shade50;
    final bannerBorder = hasExpired
        ? Colors.red.shade200
        : Colors.amber.shade200;
    final accentColor = hasExpired ? AppColors.error : AppColors.warning;

    double totalSpendAtRisk = 0;
    int affectedSubs = 0;
    for (var r in risks) {
      totalSpendAtRisk += r.monthlySpendAtRisk;
      affectedSubs += r.affectedSubscriptions.length;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: bannerBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: bannerBorder),
      ),
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          _showRisksSheet(context, risks, primaryCurrency);
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: HeroIcon(
                  hasExpired
                      ? HeroIcons.exclamationTriangle
                      : HeroIcons.shieldExclamation,
                  color: accentColor,
                  size: 20,
                  style: HeroIconStyle.solid,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Payment Shield Alert',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: hasExpired
                            ? Colors.red.shade900
                            : Colors.amber.shade900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      affectedSubs > 0
                          ? '${CurrencyHelper.formatAmount(totalSpendAtRisk, currency: primaryCurrency)}/mo across $affectedSubs sub(s) at risk.'
                          : '${risks.length} payment method(s) require review.',
                      style: TextStyle(
                        fontSize: 12,
                        color: hasExpired
                            ? Colors.red.shade800
                            : Colors.amber.shade900,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: accentColor, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _showRisksSheet(
    BuildContext context,
    List<PaymentShieldRiskGroup> risks,
    String primaryCurrency,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'At-Risk Payment Methods',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: risks.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final group = risks[index];
                      final method = group.paymentMethod;
                      final isExpired =
                          group.status == PaymentExpiryStatus.expired;

                      String badgeText;
                      Color badgeBg;
                      Color badgeTextCol;

                      if (isExpired) {
                        badgeText = 'Expired ${method.formattedExpiry}';
                        badgeBg = Colors.red.shade100;
                        badgeTextCol = AppColors.error;
                      } else if (group.daysUntilExpiry == 0) {
                        badgeText = 'Expires Today!';
                        badgeBg = Colors.red.shade100;
                        badgeTextCol = AppColors.error;
                      } else {
                        badgeText = 'Expires in ${group.daysUntilExpiry} days';
                        badgeBg = Colors.amber.shade100;
                        badgeTextCol = Colors.amber.shade900;
                      }

                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                HeroIcon(
                                  method.type.heroIcon,
                                  size: 18,
                                  color: AppColors.textSecondary,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    method.displayLabel,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: badgeBg,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    badgeText,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: badgeTextCol,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              group.affectedSubscriptions.isEmpty
                                  ? 'No active subscriptions currently linked to this method.'
                                  : '${group.affectedSubscriptions.length} subscription(s) (${CurrencyHelper.formatAmount(group.monthlySpendAtRisk, currency: primaryCurrency)}/mo) use this card and may require an update.',
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            if (group.affectedSubscriptions.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  visualDensity: VisualDensity.compact,
                                ),
                                onPressed: () {
                                  Navigator.pop(ctx);
                                  HapticFeedback.lightImpact();
                                  showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    backgroundColor: Colors.transparent,
                                    builder: (_) => ReassignPaymentMethodSheet(
                                      currentPaymentMethod: method,
                                      affectedSubscriptions:
                                          group.affectedSubscriptions,
                                    ),
                                  );
                                },
                                icon: const HeroIcon(
                                  HeroIcons.arrowsRightLeft,
                                  size: 14,
                                ),
                                label: const Text(
                                  'Reassign Subscriptions',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
