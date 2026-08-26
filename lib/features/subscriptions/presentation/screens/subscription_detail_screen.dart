import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {
              HapticFeedback.lightImpact();
              context.push('/subscriptions/edit/$subscriptionId');
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.error),
            onPressed: () => _showDeleteDialog(context, ref, subscription),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary,
                    AppColors.primary.withValues(alpha: 0.8),
                  ],
                ),
              ),
              child: Column(
                children: [
                  Hero(
                    tag: 'sub_hero_${subscription.id}',
                    child: ServiceBrandIcon(
                      serviceName: subscription.serviceName,
                      customColor: preset?.brandColor,
                      size: 72,
                      borderRadius: 20,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    subscription.serviceName,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (subscription.category != null &&
                      subscription.category!.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(top: 6),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        subscription.category!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.2,
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
                  // 1. Dedicated Cancellation Vault Card
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
                          const Icon(
                            Icons.check_circle,
                            color: AppColors.success,
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

                  // 2. Billing Information
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.grey.shade200),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _buildInfoRow(
                            'Amount',
                            CurrencyHelper.formatAmount(
                              subscription.amount,
                              currency: subscription.currency,
                            ),
                            isBold: true,
                          ),
                          const Divider(height: 20),
                          _buildInfoRow(
                            'Billing Cycle',
                            subscription.billingCycleText,
                          ),
                          const Divider(height: 20),
                          _buildInfoRow(
                            'Next Billing Date',
                            _formatDate(subscription.nextBillingDate),
                          ),
                          const Divider(height: 20),
                          _buildInfoRow(
                            'Days Until Billing',
                            '${subscription.daysUntilBilling} days',
                          ),
                          const Divider(height: 20),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton.tonalIcon(
                              style: FilledButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                              ),
                              icon: const Icon(
                                Icons.check_circle_outline,
                                size: 18,
                              ),
                              label: const Text(
                                'Record Renewal / Advance Date',
                                style: TextStyle(fontWeight: FontWeight.bold),
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
                                          .read(
                                            subscriptionNotifierProvider
                                                .notifier,
                                          )
                                          .updateSubscription(
                                            subscription.copyWith(
                                              nextBillingDate: nextDate,
                                            ),
                                          );
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
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
                        ],
                      ),
                    ),
                  ),

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
    HapticFeedback.heavyImpact();
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
    HapticFeedback.heavyImpact();
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
