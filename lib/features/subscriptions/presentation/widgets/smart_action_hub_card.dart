import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heroicons/heroicons.dart';

import '../../../../core/currency/currency_converter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../budget/presentation/providers/budget_providers.dart';
import '../../../payment_methods/domain/entities/payment_method_entity.dart';
import '../../../payment_methods/presentation/providers/payment_method_providers.dart';
import '../../domain/entities/contract_commitment.dart';
import '../../domain/entities/subscription_entity.dart';
import '../../domain/services/price_hike_detector.dart';
import '../providers/subscription_notifier.dart';
import 'action_hub_modal_sheet.dart';

class SmartActionHubCard extends ConsumerWidget {
  const SmartActionHubCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscriptions = ref.watch(subscriptionNotifierProvider).subscriptions;
    final primaryCurrency = ref.watch(primaryCurrencyProvider);
    final converter = ref.watch(currencyConverterProvider);
    final now = DateTime.now();

    // 1. Pending renewal check-ins
    final dueRenewals = subscriptions
        .where((s) => s.requiresRenewalConfirmation(now))
        .length;

    // 2. Contract alerts
    final contractRisks = subscriptions.where((sub) {
      if (sub.status != SubscriptionStatus.active || !sub.hasContract) {
        return false;
      }
      final risk = sub.contractCommitment!.evaluateRisk(now);
      return risk == ContractRiskStatus.approaching ||
          risk == ContractRiskStatus.critical ||
          risk == ContractRiskStatus.cancellationWindowPassed;
    }).length;

    // 3. Payment method risks
    final paymentRisks = ref.watch(paymentShieldRisksProvider);
    final paymentRiskCount = paymentRisks.length;

    // 4. Price hike anomalies
    final priceHikeMetrics = PriceHikeDetector.evaluateRecentPriceHikes(
      subscriptions: subscriptions,
      primaryCurrency: primaryCurrency,
      converter: converter,
    );
    final priceHikeCount = priceHikeMetrics.hikedSubscriptionsCount;

    // 5. Potentially unused subscriptions
    final unusedCount = subscriptions
        .map((s) => (subscription: s, health: s.evaluateHealth(now)))
        .where((item) => item.health.isPotentiallyUnused)
        .length;

    final totalCount =
        dueRenewals +
        contractRisks +
        paymentRiskCount +
        priceHikeCount +
        unusedCount;

    if (totalCount == 0) {
      return const SizedBox.shrink();
    }

    // Determine high priority status (e.g. red for expired cards / critical contract)
    final hasCriticalPayment = paymentRisks.any(
      (r) => r.status == PaymentExpiryStatus.expired,
    );
    final isUrgent = hasCriticalPayment || dueRenewals > 0;

    final primaryAccent = isUrgent ? AppColors.error : AppColors.warning;
    final badgeBg = isUrgent
        ? Colors.red.withValues(alpha: 0.08)
        : Colors.amber.withValues(alpha: 0.08);
    final badgeBorder = isUrgent
        ? Colors.red.withValues(alpha: 0.2)
        : Colors.amber.withValues(alpha: 0.2);

    // Build concise item summary text
    final List<String> summaryParts = [];
    if (dueRenewals > 0) {
      summaryParts.add('$dueRenewals renewal${dueRenewals > 1 ? 's' : ''}');
    }
    if (paymentRiskCount > 0) {
      summaryParts.add(
        '$paymentRiskCount card alert${paymentRiskCount > 1 ? 's' : ''}',
      );
    }
    if (contractRisks > 0) {
      summaryParts.add(
        '$contractRisks contract${contractRisks > 1 ? 's' : ''}',
      );
    }
    if (priceHikeCount > 0) {
      summaryParts.add(
        '$priceHikeCount price hike${priceHikeCount > 1 ? 's' : ''}',
      );
    }
    if (unusedCount > 0) {
      summaryParts.add('$unusedCount unused');
    }

    final summaryText = summaryParts.join(' • ');

    final content = totalCount == 0
        ? const SizedBox.shrink()
        : Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Material(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () {
                  HapticFeedback.lightImpact();
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) =>
                        ActionHubModalSheet(totalCount: totalCount),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppColors.darkOutline.withValues(alpha: 0.15),
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      // Badge / Icon
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: badgeBg,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: badgeBorder, width: 1),
                        ),
                        child: HeroIcon(
                          isUrgent
                              ? HeroIcons.exclamationTriangle
                              : HeroIcons.bellAlert,
                          color: primaryAccent,
                          size: 24,
                          style: HeroIconStyle.solid,
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Text Block
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  '$totalCount action item${totalCount != 1 ? 's' : ''} need review',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              summaryText,
                              style: AppTypography.bodyMetadata.copyWith(
                                fontSize: 12,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 8),

                      // Trailing Action Pill
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: primaryAccent.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Review',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: primaryAccent,
                              ),
                            ),
                            const SizedBox(width: 4),
                            HeroIcon(
                              HeroIcons.arrowRight,
                              size: 12,
                              color: primaryAccent,
                              style: HeroIconStyle.solid,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );

    return AnimatedSize(
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeInOutCubic,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 240),
        switchInCurve: Curves.easeInOutCubic,
        switchOutCurve: Curves.easeInOutCubic,
        child: content,
      ),
    );
  }
}
