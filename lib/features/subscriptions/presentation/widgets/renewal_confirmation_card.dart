import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_helper.dart';
import '../../domain/entities/price_history.dart';
import '../../domain/entities/subscription_entity.dart';
import '../providers/subscription_notifier.dart';
import 'service_brand_icon.dart';

class RenewalConfirmationCard extends ConsumerStatefulWidget {
  const RenewalConfirmationCard({super.key});

  @override
  ConsumerState<RenewalConfirmationCard> createState() =>
      _RenewalConfirmationCardState();
}

class _RenewalConfirmationCardState
    extends ConsumerState<RenewalConfirmationCard> {
  int _currentIndex = 0;

  Future<void> _handleConfirmRenewal(SubscriptionEntity subscription) async {
    HapticFeedback.mediumImpact();
    await ref
        .read(subscriptionNotifierProvider.notifier)
        .confirmRenewal(subscription: subscription);

    if (mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '✓ ${subscription.serviceName} renewed! Next renewal date advanced.',
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _handleDidNotRenew(SubscriptionEntity subscription) async {
    HapticFeedback.selectionClick();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Stop ${subscription.serviceName}?'),
        content: Text(
          'Did you stop or cancel ${subscription.serviceName}? This will move it to Cancelled without deleting your history.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('No, Keep Active'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Yes, Mark Cancelled'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await ref
          .read(subscriptionNotifierProvider.notifier)
          .markDidNotRenew(subscription);
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${subscription.serviceName} marked as cancelled.',
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _handlePriceChanged(SubscriptionEntity subscription) async {
    HapticFeedback.selectionClick();
    final controller = TextEditingController(
      text: subscription.amount.toStringAsFixed(2),
    );
    PriceChangeReason selectedReason = PriceChangeReason.priceHike;

    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (modalCtx, setModalState) {
          return Padding(
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
                  children: [
                    ServiceBrandIcon(
                      serviceName: subscription.serviceName,
                      size: 38,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Price Changed: ${subscription.serviceName}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Previous: ${CurrencyHelper.formatAmount(subscription.amount, currency: subscription.currency)} • ${subscription.billingCycleText}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: controller,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  autofocus: true,
                  decoration: InputDecoration(
                    labelText: 'New Amount (${subscription.currency})',
                    prefixIcon: const Icon(Icons.attach_money),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Reason for change:',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: PriceChangeReason.values.map((reason) {
                    final isSelected = selectedReason == reason;
                    return ChoiceChip(
                      label: Text(reason.label),
                      selected: isSelected,
                      selectedColor: AppColors.primary.withValues(alpha: 0.15),
                      labelStyle: TextStyle(
                        fontSize: 11,
                        color: isSelected ? AppColors.primary : AppColors.textPrimary,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      onSelected: (_) => setModalState(() => selectedReason = reason),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 18),
                FilledButton(
                  onPressed: () {
                    final val = double.tryParse(controller.text.trim());
                    if (val != null && val > 0) {
                      Navigator.pop(ctx, {
                        'amount': val,
                        'reason': selectedReason,
                      });
                    }
                  },
                  child: const Text('Save & Confirm Renewal'),
                ),
              ],
            ),
          );
        },
      ),
    );

    if (result != null && mounted) {
      final newPrice = result['amount'] as double;
      final reason = result['reason'] as PriceChangeReason;

      await ref.read(subscriptionNotifierProvider.notifier).confirmRenewal(
            subscription: subscription,
            newAmount: newPrice,
            priceChangeReason: reason,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '✓ Price updated to \$${newPrice.toStringAsFixed(2)} (${reason.label}) and renewed!',
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(subscriptionNotifierProvider);
    final now = DateTime.now();
    final dueSubscriptions = state.subscriptions
        .where((s) => s.requiresRenewalConfirmation(now))
        .toList();

    if (dueSubscriptions.isEmpty) {
      return const SizedBox.shrink();
    }

    if (_currentIndex >= dueSubscriptions.length) {
      _currentIndex = 0;
    }

    final currentSub = dueSubscriptions[_currentIndex];
    final formattedDue = DateFormat('MMM d, yyyy').format(currentSub.nextBillingDate);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB), // Soft amber tint
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.amber.shade300, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Compact Header Row with Counter
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.notifications_active_outlined,
                      color: Colors.amber.shade900,
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Renewal Check',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber.shade900,
                      ),
                    ),
                  ],
                ),
                if (dueSubscriptions.length > 1)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade200,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${_currentIndex + 1} of ${dueSubscriptions.length}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber.shade900,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),

            // Subscription Overview Card
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.shade100),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      ServiceBrandIcon(
                        serviceName: currentSub.serviceName,
                        size: 36,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              currentSub.serviceName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              'Renewal: $formattedDue • ${currentSub.billingCycleText}',
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        CurrencyHelper.formatAmount(
                          currentSub.amount,
                          currency: currentSub.currency,
                        ),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Divider(height: 1),
                  const SizedBox(height: 10),

                  // Question & 3 Action Buttons
                  const Center(
                    child: Text(
                      'Did this subscription renew as expected?',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: FilledButton.icon(
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.success,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          icon: const Icon(Icons.check, size: 16),
                          label: const Text(
                            '✓ Renewed',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onPressed: () => _handleConfirmRenewal(currentSub),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        flex: 3,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.error,
                            side: BorderSide(color: Colors.red.shade200),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () => _handleDidNotRenew(currentSub),
                          child: const Text(
                            '✕ Didn\'t Renew',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        flex: 2,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.grey.shade700,
                            side: BorderSide(color: Colors.grey.shade300),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () => _handlePriceChanged(currentSub),
                          child: const Text(
                            '✏️ Price',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
