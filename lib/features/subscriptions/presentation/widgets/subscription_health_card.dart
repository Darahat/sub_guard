import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_helper.dart';
import '../../domain/entities/subscription_entity.dart';
import '../../domain/entities/subscription_health.dart';
import '../providers/subscription_notifier.dart';
import 'service_brand_icon.dart';

class SubscriptionHealthCard extends ConsumerWidget {
  const SubscriptionHealthCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(subscriptionNotifierProvider);
    final now = DateTime.now();

    final healthAuditList = state.subscriptions
        .map((s) => (subscription: s, health: s.evaluateHealth(now)))
        .where((item) => item.health.isPotentiallyUnused)
        .toList();

    if (healthAuditList.isEmpty) {
      return const SizedBox.shrink();
    }

    final totalPotentialAnnualSavings = healthAuditList.fold<double>(
      0.0,
      (sum, item) => sum + item.health.potentialAnnualSavings,
    );

    int activeCount = state.subscriptions
        .where((s) => s.status == SubscriptionStatus.active)
        .length;
    int healthScore = activeCount == 0
        ? 100
        : ((1 - (healthAuditList.length / activeCount)) * 100).round();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          _showReviewSheet(
            context,
            healthAuditList,
            totalPotentialAnnualSavings,
            ref,
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.purple.shade100),
            boxShadow: [
              BoxShadow(
                color: Colors.purple.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              SizedBox(
                width: 50,
                height: 50,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: healthScore / 100,
                      color: Colors.purple,
                      backgroundColor: Colors.purple.shade50,
                      strokeWidth: 4,
                    ),
                    Text(
                      '$healthScore',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.purple,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Subscription Hygiene Score',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${healthAuditList.length} unused items detected (~${CurrencyHelper.formatAmount(totalPotentialAnnualSavings)}/yr)',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.purple, size: 24),
            ],
          ),
        ),
      ),
    );
  }

  void _showReviewSheet(
    BuildContext context,
    List<({SubscriptionEntity subscription, SubscriptionHealth health})>
    healthAuditList,
    double totalSavings,
    WidgetRef ref,
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
                  'Review Unused Subscriptions',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Save up to ${CurrencyHelper.formatAmount(totalSavings)} per year by cancelling these unused items.',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: healthAuditList.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final item = healthAuditList[index];
                      final sub = item.subscription;
                      final health = item.health;

                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.purple.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.purple.shade100),
                        ),
                        child: Row(
                          children: [
                            ServiceBrandIcon(
                              serviceName: sub.serviceName,
                              size: 36,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    sub.serviceName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    'Unused for ~${(health.daysSinceReview / 30).round()} months',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.purple,
                                side: BorderSide(color: Colors.purple.shade200),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                visualDensity: VisualDensity.compact,
                              ),
                              onPressed: () {
                                Navigator.pop(ctx);
                                context.push('/subscriptions/${sub.id}');
                              },
                              child: const Text(
                                'Review',
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
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
