import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:heroicons/heroicons.dart';

import '../../../../core/constants/preset_catalog.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_helper.dart';
import '../../../preset_catalog/presentation/widgets/cancellation_vault_card.dart';
import '../../domain/entities/subscription_entity.dart';
import '../providers/subscription_notifier.dart';
import '../widgets/payment_confirmation_dialog.dart';
import '../widgets/price_history_timeline.dart';
import '../widgets/service_brand_icon.dart';

class SubscriptionDetailScreen extends ConsumerWidget {
  final String subscriptionId;

  const SubscriptionDetailScreen({super.key, required this.subscriptionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscriptionState = ref.watch(subscriptionNotifierProvider);
    final subscription = subscriptionState.subscriptions
        .where((s) => s.id == subscriptionId)
        .firstOrNull;

    if (subscription == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Subscription Details')),
        body: const Center(child: Text('Subscription not found')),
      );
    }

    final isCancelled = subscription.status == SubscriptionStatus.cancelled;
    final preset = PresetCatalog.getByName(subscription.serviceName);

    return Scaffold(
      appBar: AppBar(
        title: Text(subscription.serviceName),
        actions: [
          IconButton(
            icon: const HeroIcon(HeroIcons.pencilSquare, size: 20),
            onPressed: () {
              HapticFeedback.lightImpact();
              context.push('/subscriptions/edit/$subscriptionId');
            },
          ),
          IconButton(
            icon: const HeroIcon(
              HeroIcons.trash,
              color: AppColors.error,
              size: 20,
            ),
            onPressed: () => _showDeleteDialog(context, ref, subscription),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(
          bottom: MediaQuery.paddingOf(context).bottom + 24,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Hero Card
            Container(
              margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary,
                    AppColors.primary.withValues(alpha: 0.85),
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Hero(
                    tag: 'sub_hero_${subscription.id}',
                    child: ServiceBrandIcon(
                      serviceName: subscription.serviceName,
                      customColor: preset?.brandColor,
                      size: 64,
                      borderRadius: 16,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    subscription.serviceName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    CurrencyHelper.formatAmount(
                      subscription.amount,
                      currency: subscription.currency,
                    ),
                    style: const TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Next Bill: ${_formatDate(subscription.nextBillingDate)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Grouped Billing Details
                  const Padding(
                    padding: EdgeInsets.only(left: 4, bottom: 8),
                    child: Text(
                      'BILLING DETAILS',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.grey.withValues(alpha: 0.15),
                      ),
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: _buildInfoRow(
                            'Category',
                            subscription.category ?? 'Uncategorized',
                          ),
                        ),
                        const Divider(height: 1),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: _buildInfoRow(
                            'Cycle',
                            subscription.billingCycleText,
                          ),
                        ),
                        const Divider(height: 1),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: _buildInfoRow(
                            'Days Remaining',
                            '${subscription.daysUntilBilling} days',
                          ),
                        ),
                        if (subscription.isSharedPlan) ...[
                          const Divider(height: 1),
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: _buildInfoRow(
                              'My Share',
                              CurrencyHelper.formatAmount(
                                subscription.myShareAmount ??
                                    (subscription.amount /
                                        (subscription.splitCount ?? 2)),
                                currency: subscription.currency,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Record Renewal Button
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.tonalIcon(
                      style: FilledButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      icon: const HeroIcon(HeroIcons.checkCircle, size: 20),
                      label: const Text(
                        'Record Renewal Payment',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        showDialog(
                          context: context,
                          builder: (ctx) => PaymentConfirmationDialog(
                            subscription: subscription,
                            onConfirmedCharge: () async {
                              final nextDate = _calculateNextDate(
                                subscription.nextBillingDate,
                                subscription.billingCycle,
                              );
                              await ref
                                  .read(subscriptionNotifierProvider.notifier)
                                  .updateSubscription(
                                    subscription.copyWith(
                                      nextBillingDate: nextDate,
                                    ),
                                  );
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      '✓ Next billing date advanced to ${_formatDate(nextDate)}',
                                    ),
                                    backgroundColor: AppColors.success,
                                  ),
                                );
                              }
                            },
                            onOpenCancellation: () {},
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Dedicated Cancellation Vault Card
                  if (!isCancelled) ...[
                    CancellationVaultCard(
                      preset:
                          preset ??
                          PresetService(
                            id: subscription.serviceName
                                .toLowerCase()
                                .replaceAll(' ', '_'),
                            name: subscription.serviceName,
                            category: subscription.category ?? 'Other',
                            brandColor: AppColors.primary,
                            websiteUrl: subscription.websiteUrl,
                            cancellationGuide: CancellationGuide(
                              lastVerified: DateTime(2026, 8, 26),
                              web: CancellationMethod(
                                actionUrl: subscription.websiteUrl,
                                steps: const [
                                  'Log in to your account page in a browser.',
                                  'Navigate to your Subscription, Billing, or Plan settings.',
                                  'Select "Cancel Subscription" or "Turn off auto-renew".',
                                  'Confirm your cancellation to stop upcoming charges.',
                                ],
                              ),
                            ),
                          ),
                      customWebsiteUrl: subscription.websiteUrl,
                      onMarkCancelled: () =>
                          _showCancelDialog(context, ref, subscription),
                    ),
                    const SizedBox(height: 20),
                  ] else ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const HeroIcon(
                            HeroIcons.checkCircle,
                            color: AppColors.success,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Cancelled on ${_formatDate(subscription.cancellationDate ?? DateTime.now())}. Alarms are deactivated.',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () async {
                              HapticFeedback.mediumImpact();
                              final reactivated = subscription.copyWith(
                                status: SubscriptionStatus.active,
                                cancellationDate: null,
                              );
                              await ref
                                  .read(subscriptionNotifierProvider.notifier)
                                  .updateSubscription(reactivated);
                            },
                            child: const Text('Reactivate'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // 2.5. Price History Timeline (Phase 16)
                  PriceHistoryTimeline(subscription: subscription),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  DateTime _calculateNextDate(DateTime current, BillingCycle cycle) {
    switch (cycle) {
      case BillingCycle.daily:
        return current.add(const Duration(days: 1));
      case BillingCycle.weekly:
        return current.add(const Duration(days: 7));
      case BillingCycle.monthly:
        return DateTime(current.year, current.month + 1, current.day);
      case BillingCycle.quarterly:
        return DateTime(current.year, current.month + 3, current.day);
      case BillingCycle.yearly:
        return DateTime(current.year + 1, current.month, current.day);
    }
  }

  Widget _buildInfoRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textSecondary)),
        Text(
          value,
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            fontSize: isBold ? 16 : 14,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  void _showCancelDialog(
    BuildContext context,
    WidgetRef ref,
    SubscriptionEntity subscription,
  ) {
    HapticFeedback.mediumImpact();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Cancellation'),
        content: Text(
          'Mark "${subscription.serviceName}" as cancelled? Scheduled reminder alarms will be turned off.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Keep Active'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await ref
                  .read(subscriptionNotifierProvider.notifier)
                  .cancelSubscription(subscription.id);
            },
            child: const Text('Yes, Confirm'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    WidgetRef ref,
    SubscriptionEntity subscription,
  ) {
    HapticFeedback.mediumImpact();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Subscription?'),
        content: Text(
          'Are you sure you want to delete "${subscription.serviceName}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              Navigator.pop(ctx);
              await ref
                  .read(subscriptionNotifierProvider.notifier)
                  .deleteSubscription(subscription.id);
              if (context.mounted) context.pop();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
