import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_helper.dart';
import '../../domain/entities/subscription_entity.dart';

class PaymentConfirmationDialog extends StatelessWidget {
  final SubscriptionEntity subscription;
  final VoidCallback onConfirmedCharge;
  final VoidCallback onOpenCancellation;

  const PaymentConfirmationDialog({
    super.key,
    required this.subscription,
    required this.onConfirmedCharge,
    required this.onOpenCancellation,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.payment, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Renewal Check-in',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Did your scheduled charge for ${subscription.serviceName} occur?',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            'Amount: ${CurrencyHelper.formatAmount(subscription.amount, currency: subscription.currency)} (${subscription.billingCycleText})',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            HapticFeedback.lightImpact();
            Navigator.pop(context);
            onOpenCancellation();
          },
          child: const Text(
            'No, Help Cancel',
            style: TextStyle(color: AppColors.error),
          ),
        ),
        FilledButton(
          onPressed: () {
            HapticFeedback.mediumImpact();
            Navigator.pop(context);
            onConfirmedCharge();
          },
          child: const Text('Yes, Charge Occurred'),
        ),
      ],
    );
  }
}
