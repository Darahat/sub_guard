import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:heroicons/heroicons.dart';

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
    final accentColor = isCritical ? AppColors.error : AppColors.warning;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: HeroIcon(
                  HeroIcons.clock,
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
                      'Action Hub: Contracts',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${activeContractSubs.length} subscription(s) require action to avoid lock-in.',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Items list
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: activeContractSubs.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final sub = activeContractSubs[index];
              final contract = sub.contractCommitment!;
              final risk = contract.evaluateRisk(now);
              final deadline = contract.cancellationDeadline;
              final daysLeft = contract.daysUntilDeadline(now);

              Color progressColor;
              if (risk == ContractRiskStatus.critical) {
                progressColor = AppColors.error;
              } else if (risk == ContractRiskStatus.approaching) {
                progressColor = AppColors.warning;
              } else {
                progressColor = Colors.grey;
              }

              final totalNoticeDays = contract.cancellationNoticeDays
                  .toDouble();
              // Prevent division by zero and cap progress between 0.0 and 1.0
              final safeNoticeDays = totalNoticeDays > 0
                  ? totalNoticeDays
                  : 1.0;
              final progressValue =
                  risk == ContractRiskStatus.cancellationWindowPassed
                  ? 0.0
                  : (daysLeft.clamp(0, safeNoticeDays) / safeNoticeDays)
                        .toDouble();

              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 44,
                      height: 44,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CircularProgressIndicator(
                            value: progressValue,
                            color: progressColor,
                            backgroundColor: Colors.grey.shade200,
                            strokeWidth: 3,
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                risk ==
                                        ContractRiskStatus
                                            .cancellationWindowPassed
                                    ? '0'
                                    : '$daysLeft',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: progressColor,
                                ),
                              ),
                              const Text(
                                'days',
                                style: TextStyle(
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
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
                          const SizedBox(height: 2),
                          Text(
                            'Cancel by ${DateHelper.formatDisplayDate(deadline)}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        HapticFeedback.selectionClick();
                        context.push('/vault');
                      },
                      icon: const HeroIcon(
                        HeroIcons.chevronRight,
                        size: 20,
                        color: AppColors.textSecondary,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              HeroIcon(
                HeroIcons.informationCircle,
                size: 13,
                color: AppColors.textSecondary,
              ),
              SizedBox(width: 6),
              Text(
                'Verify provider terms. Tap an item for Cancellation Vault.',
                style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
