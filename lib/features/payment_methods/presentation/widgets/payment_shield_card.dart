import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_helper.dart';
import '../../../budget/presentation/providers/budget_providers.dart';
import '../../domain/entities/payment_method_entity.dart';
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

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bannerBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: bannerBorder),
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
                  color: accentColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  hasExpired
                      ? Icons.credit_card_off_rounded
                      : Icons.shield_outlined,
                  color: accentColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hasExpired
                          ? 'Payment Method Expired'
                          : 'Payment Card Expiring Soon',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: hasExpired
                            ? Colors.red.shade900
                            : Colors.amber.shade900,
                      ),
                    ),
                    Text(
                      '${risks.length} payment method(s) require review to avoid payment interruptions.',
                      style: TextStyle(
                        fontSize: 11,
                        color: hasExpired
                            ? Colors.red.shade800
                            : Colors.amber.shade900,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Cards list
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: risks.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final group = risks[index];
              final method = group.paymentMethod;
              final isExpired = group.status == PaymentExpiryStatus.expired;

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
                  border: Border.all(color: bannerBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          method.type.icon,
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
                          foregroundColor: accentColor,
                          side: BorderSide(color: bannerBorder),
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
                        icon: const Icon(Icons.swap_horiz, size: 14),
                        label: const Text(
                          'Review & Reassign Subscriptions',
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
          const SizedBox(height: 6),
          const Text(
            '🔒 SubGuard monitors only user-entered metadata. No banking or card credentials are stored.',
            style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
