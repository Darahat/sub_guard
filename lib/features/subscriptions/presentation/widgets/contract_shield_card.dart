import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_helper.dart';
import '../../domain/entities/contract_commitment.dart';
import '../../domain/entities/subscription_entity.dart';
import '../providers/subscription_notifier.dart';

class ContractShieldCard extends ConsumerWidget {
  const ContractShieldCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscriptions = ref.watch(subscriptionNotifierProvider).subscriptions;
    final now = DateTime.now();

    final activeContractSubs = subscriptions.where((sub) {
      if (sub.status != SubscriptionStatus.active || !sub.hasContract) {
        return false;
      }
      final risk = sub.contractCommitment!.evaluateRisk(now);
      return risk == ContractRiskStatus.approaching ||
          risk == ContractRiskStatus.critical ||
          risk == ContractRiskStatus.cancellationWindowPassed;
    }).toList();

    if (activeContractSubs.isEmpty) return const SizedBox.shrink();

    final criticalCount = activeContractSubs.where((s) {
      return s.contractCommitment!.evaluateRisk(now) ==
          ContractRiskStatus.critical;
    }).length;

    final isCritical = criticalCount > 0;
    final bannerColor = isCritical ? Colors.red.shade50 : Colors.amber.shade50;
    final borderColor = isCritical
        ? Colors.red.shade200
        : Colors.amber.shade200;
    final accentColor = isCritical ? AppColors.error : AppColors.warning;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bannerColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  isCritical ? Icons.emergency_rounded : Icons.shield_outlined,
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
                      isCritical
                          ? 'Critical Cancellation Notice Period'
                          : 'Contract Cancellation Notice Approaching',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isCritical
                            ? Colors.red.shade900
                            : Colors.amber.shade900,
                      ),
                    ),
                    Text(
                      '${activeContractSubs.length} subscription(s) require advance cancellation to avoid lock-in.',
                      style: TextStyle(
                        fontSize: 11,
                        color: isCritical
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

          // Items list
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: activeContractSubs.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final sub = activeContractSubs[index];
              final contract = sub.contractCommitment!;
              final risk = contract.evaluateRisk(now);
              final deadline = contract.cancellationDeadline;
              final daysLeft = contract.daysUntilDeadline(now);

              String badgeText;
              Color badgeColor;
              Color badgeTextColor;

              if (risk == ContractRiskStatus.critical) {
                badgeText = daysLeft == 0
                    ? 'Deadline Today!'
                    : '$daysLeft days left';
                badgeColor = Colors.red.shade100;
                badgeTextColor = AppColors.error;
              } else if (risk == ContractRiskStatus.approaching) {
                badgeText = '$daysLeft days left';
                badgeColor = Colors.amber.shade100;
                badgeTextColor = Colors.amber.shade900;
              } else {
                badgeText = 'Window Passed';
                badgeColor = Colors.grey.shade200;
                badgeTextColor = Colors.grey.shade800;
              }

              return Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: borderColor),
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
                            'Cancel by ${DateHelper.formatDisplayDate(deadline)} (${contract.cancellationNoticeDays}d notice required)',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: badgeColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        badgeText,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: badgeTextColor,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 10),

          // Shortcut to Cancellation Vault
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: isCritical
                  ? AppColors.error
                  : Colors.amber.shade900,
              side: BorderSide(
                color: isCritical ? Colors.red.shade300 : Colors.amber.shade400,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(vertical: 8),
            ),
            onPressed: () {
              HapticFeedback.lightImpact();
              context.push('/vault');
            },
            icon: const Icon(Icons.open_in_new, size: 14),
            label: const Text(
              'Open Cancellation Vault Steps',
              style: TextStyle(fontSize: 12),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            '⚠️ Based on your entered notice period. Check your provider\'s terms to confirm exact requirements.',
            style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
