import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/currency/currency_converter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_helper.dart';
import '../../../../core/utils/date_helper.dart';
import '../../../budget/presentation/providers/budget_providers.dart';
import '../../../monetization/presentation/providers/purchase_notifier.dart';
import '../../../monetization/presentation/widgets/paywall_bottom_sheet.dart';
import '../../../payment_methods/presentation/providers/payment_method_providers.dart';
import '../../domain/entities/subscription_entity.dart';
import '../providers/subscription_notifier.dart';
import 'payment_confirmation_dialog.dart';
import 'service_brand_icon.dart';

class SubscriptionCard extends ConsumerWidget {
  final SubscriptionEntity subscription;
  final VoidCallback? onTap;

  const SubscriptionCard({super.key, required this.subscription, this.onTap});

  void _showPaymentConfirmationDialog(BuildContext context, WidgetRef ref) {
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
                subscription.copyWith(nextBillingDate: nextDate),
              );
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '✓ ${subscription.serviceName} renewal advanced to ${_formatDate(nextDate)}.',
                ),
                backgroundColor: AppColors.success,
              ),
            );
          }
        },
        onOpenCancellation: () {
          onTap?.call();
        },
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isPaused = subscription.status == SubscriptionStatus.paused;
    final primaryCurrency = ref.watch(primaryCurrencyProvider);
    final converter = ref.watch(currencyConverterProvider);

    return Dismissible(
      key: ValueKey(subscription.id),
      // Swipe Right -> Pause / Reactivate
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        decoration: BoxDecoration(
          color: isPaused ? AppColors.success : AppColors.warning,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(
              isPaused ? Icons.play_arrow : Icons.pause,
              color: Colors.white,
              size: 26,
            ),
            const SizedBox(width: 8),
            Text(
              isPaused ? 'Reactivate' : 'Pause',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
      // Swipe Left -> Delete / Cancel
      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              'Delete',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            SizedBox(width: 8),
            Icon(Icons.delete_outline, color: Colors.white, size: 26),
          ],
        ),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          // Pause / Reactivate action
          HapticFeedback.mediumImpact();

          if (isPaused) {
            final isPro = ref.read(purchaseNotifierProvider).isPro;
            final activeCount = ref
                .read(subscriptionNotifierProvider)
                .activeSubscriptionCount;

            if (!isPro && activeCount >= 5) {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => const PaywallBottomSheet(),
              );
              return false;
            }
          }

          final updatedStatus = isPaused
              ? SubscriptionStatus.active
              : SubscriptionStatus.paused;
          await ref
              .read(subscriptionNotifierProvider.notifier)
              .updateSubscription(subscription.copyWith(status: updatedStatus));
          return false; // Don't dismiss from tree
        } else {
          // Delete action with confirmation
          HapticFeedback.heavyImpact();
          return await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Delete Subscription?'),
                  content: Text(
                    'Are you sure you want to delete "${subscription.serviceName}"?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Cancel'),
                    ),
                    FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.error,
                      ),
                      onPressed: () {
                        ref
                            .read(subscriptionNotifierProvider.notifier)
                            .deleteSubscription(subscription.id);
                        Navigator.pop(ctx, true);
                      },
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              ) ??
              false;
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.withValues(alpha: 0.15)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              HapticFeedback.lightImpact();
              onTap?.call();
            },
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Row: Logo, Name & Category, Status Badge
                  Row(
                    children: [
                      Hero(
                        tag: 'sub_hero_${subscription.id}',
                        child: ServiceBrandIcon(
                          serviceName: subscription.serviceName,
                          size: 44,
                          borderRadius: 12,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              subscription.serviceName,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (subscription.category != null)
                              Text(
                                subscription.category!,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                          ],
                        ),
                      ),
                      _buildStatusBadge(),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Middle Row: Neutral Financial Amount & Billing Cycle + Dual Currency + Shared Badge
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      Text(
                        CurrencyHelper.formatAmount(
                          subscription.amount,
                          currency: subscription.currency,
                        ),
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          subscription.billingCycleText,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      if (subscription.currency.toUpperCase() !=
                          primaryCurrency.toUpperCase())
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '≈ ${CurrencyHelper.formatAmount(
                              converter.convert(amount: subscription.effectivePersonalAmount, fromCurrency: subscription.currency, toCurrency: primaryCurrency),
                              currency: primaryCurrency,
                            )}',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      if (subscription.isSharedPlan)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.purple.shade50,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.purple.shade200),
                          ),
                          child: Text(
                            '👥 My share: ${CurrencyHelper.formatAmount(subscription.effectivePersonalAmount, currency: subscription.currency)}',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.purple.shade800,
                            ),
                          ),
                        ),
                      if (subscription.hasContract)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade50,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.amber.shade200),
                          ),
                          child: Text(
                            '🔒 ${subscription.contractCommitment!.cancellationNoticeDays}d Notice (Deadline: ${DateHelper.formatDisplayDate(subscription.contractCommitment!.cancellationDeadline)})',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.amber.shade900,
                            ),
                          ),
                        ),
                      if (subscription.paymentMethodId != null) ...[
                        () {
                          final methods = ref
                              .watch(paymentMethodNotifierProvider)
                              .paymentMethods;
                          final method = methods
                              .where(
                                (m) => m.id == subscription.paymentMethodId,
                              )
                              .firstOrNull;
                          if (method == null) return const SizedBox.shrink();
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blueGrey.shade50,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: Colors.blueGrey.shade200,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  method.type.icon,
                                  size: 11,
                                  color: Colors.blueGrey.shade800,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  method.displayLabel,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blueGrey.shade900,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }(),
                      ],
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Bottom Row: Next Billing Date & Expiring / Renewal Check-in Pill
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 15,
                        color: subscription.daysUntilBilling <= 0
                            ? AppColors.error
                            : subscription.isExpiringSoon
                            ? AppColors.warning
                            : AppColors.textSecondary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        subscription.daysUntilBilling < 0
                            ? 'Overdue: ${_formatDate(subscription.nextBillingDate)}'
                            : subscription.daysUntilBilling == 0
                            ? 'Due Today: ${_formatDate(subscription.nextBillingDate)}'
                            : 'Next billing: ${_formatDate(subscription.nextBillingDate)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: subscription.daysUntilBilling <= 7
                              ? FontWeight.w600
                              : FontWeight.normal,
                          color: subscription.daysUntilBilling <= 0
                              ? AppColors.error
                              : subscription.isExpiringSoon
                              ? AppColors.warning
                              : AppColors.textSecondary,
                        ),
                      ),
                      const Spacer(),

                      // Interactive Renewal Confirmation Pill (within 3 days, today, or overdue)
                      if (subscription.daysUntilBilling <= 3)
                        InkWell(
                          onTap: () =>
                              _showPaymentConfirmationDialog(context, ref),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: subscription.daysUntilBilling <= 0
                                  ? AppColors.error.withValues(alpha: 0.12)
                                  : AppColors.warning.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: subscription.daysUntilBilling <= 0
                                    ? AppColors.error.withValues(alpha: 0.4)
                                    : AppColors.warning.withValues(alpha: 0.4),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.check_circle_outline,
                                  size: 13,
                                  color: subscription.daysUntilBilling <= 0
                                      ? AppColors.error
                                      : AppColors.warning,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  subscription.daysUntilBilling <= 0
                                      ? 'Confirm Renewal'
                                      : 'Renewed?',
                                  style: TextStyle(
                                    color: subscription.daysUntilBilling <= 0
                                        ? AppColors.error
                                        : AppColors.warning,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else if (subscription.isExpiringSoon)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.warning.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${subscription.daysUntilBilling} days left',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.warning,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    final statusColor = _getStatusColor();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        subscription.statusText,
        style: TextStyle(
          color: statusColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Color _getStatusColor() {
    switch (subscription.status) {
      case SubscriptionStatus.active:
        return AppColors.success;
      case SubscriptionStatus.paused:
        return AppColors.warning;
      case SubscriptionStatus.cancelled:
        return AppColors.textSecondary;
      case SubscriptionStatus.expired:
        return AppColors.error;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = date.difference(DateTime(now.year, now.month, now.day)).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Tomorrow';
    if (diff > 1 && diff < 7) return 'in $diff days';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
