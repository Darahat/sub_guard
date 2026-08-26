import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../providers/purchase_notifier.dart';

class PaywallBottomSheet extends ConsumerStatefulWidget {
  const PaywallBottomSheet({super.key});

  @override
  ConsumerState<PaywallBottomSheet> createState() => _PaywallBottomSheetState();
}

class _PaywallBottomSheetState extends ConsumerState<PaywallBottomSheet> {
  bool _isAnnual = true;

  @override
  Widget build(BuildContext context) {
    final purchaseState = ref.watch(purchaseNotifierProvider);
    final annualProduct = purchaseState.annualProduct;
    final monthlyProduct = purchaseState.monthlyProduct;

    final annualPriceText = annualProduct?.price ?? '\$19.99 / yr';
    final monthlyPriceText = monthlyProduct?.price ?? '\$2.99 / mo';

    ref.listen<PurchaseState>(purchaseNotifierProvider, (previous, next) {
      if (next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: AppColors.error,
          ),
        );
        ref.read(purchaseNotifierProvider.notifier).clearMessages();
      }
      if (next.successMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.successMessage!),
            backgroundColor: AppColors.success,
          ),
        );
        ref.read(purchaseNotifierProvider.notifier).clearMessages();
        if (next.isPro && mounted) {
          Navigator.pop(context);
        }
      }
    });

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
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

            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.workspace_premium,
                    color: AppColors.primary,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Unlock SubGuard Pro',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Maximum financial peace of mind',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Features Checklist
            _buildFeatureRow('Unlimited Subscriptions (Free tier is up to 5)'),
            _buildFeatureRow('Real-time Cloud Sync & Multi-Device Backup'),
            _buildFeatureRow('Advanced Spending Trends & Monthly Forecasting'),
            _buildFeatureRow('Extended 14-Day & 30-Day Renewal Alarms'),
            const SizedBox(height: 20),

            // Pricing Plans
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _isAnnual = true);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: _isAnnual
                              ? AppColors.primary
                              : Colors.grey.shade300,
                          width: _isAnnual ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        color: _isAnnual
                            ? AppColors.primary.withValues(alpha: 0.05)
                            : Colors.transparent,
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.success,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'SAVE 44%',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Annual',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            annualPriceText,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _isAnnual = false);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: !_isAnnual
                              ? AppColors.primary
                              : Colors.grey.shade300,
                          width: !_isAnnual ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        color: !_isAnnual
                            ? AppColors.primary.withValues(alpha: 0.05)
                            : Colors.transparent,
                      ),
                      child: Column(
                        children: [
                          const SizedBox(height: 18),
                          const Text(
                            'Monthly',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            monthlyPriceText,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Purchase / Action Button
            FilledButton(
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: purchaseState.isLoading
                  ? null
                  : () async {
                      HapticFeedback.mediumImpact();
                      final productToBuy = _isAnnual
                          ? annualProduct
                          : monthlyProduct;

                      if (productToBuy != null) {
                        // Real Google Play Purchase
                        await ref
                            .read(purchaseNotifierProvider.notifier)
                            .purchase(productToBuy);
                      } else {
                        // Fallback / Sandbox activation while keys are being configured in Console
                        await ref
                            .read(purchaseNotifierProvider.notifier)
                            .setMockPro(true);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                '✓ SubGuard Pro unlocked (Sandbox Mode)!',
                              ),
                              backgroundColor: AppColors.success,
                            ),
                          );
                          Navigator.pop(context);
                        }
                      }
                    },
              child: purchaseState.isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      _isAnnual
                          ? 'Start Annual Plan ($annualPriceText)'
                          : 'Start Monthly Plan ($monthlyPriceText)',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
            ),
            const SizedBox(height: 12),

            // Restore Purchases & Terms Links
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: purchaseState.isLoading
                      ? null
                      : () {
                          HapticFeedback.lightImpact();
                          ref
                              .read(purchaseNotifierProvider.notifier)
                              .restorePurchases();
                        },
                  child: const Text(
                    'Restore Purchases',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                const Text(
                  '•',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
                TextButton(
                  onPressed: () {
                    // Terms of service
                  },
                  child: const Text(
                    'Terms & Privacy',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureRow(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: AppColors.success, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
