import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heroicons/heroicons.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_helper.dart';
import '../../../subscriptions/domain/entities/subscription_entity.dart';
import '../../domain/entities/payment_method_entity.dart';
import '../providers/payment_method_providers.dart';

class ReassignPaymentMethodSheet extends ConsumerStatefulWidget {
  final PaymentMethodEntity currentPaymentMethod;
  final List<SubscriptionEntity> affectedSubscriptions;

  const ReassignPaymentMethodSheet({
    super.key,
    required this.currentPaymentMethod,
    required this.affectedSubscriptions,
  });

  @override
  ConsumerState<ReassignPaymentMethodSheet> createState() =>
      _ReassignPaymentMethodSheetState();
}

class _ReassignPaymentMethodSheetState
    extends ConsumerState<ReassignPaymentMethodSheet> {
  late Set<String> _selectedSubscriptionIds;
  String? _targetPaymentMethodId;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _selectedSubscriptionIds = widget.affectedSubscriptions
        .map((s) => s.id)
        .toSet();
  }

  void _selectAll(bool select) {
    setState(() {
      if (select) {
        _selectedSubscriptionIds = widget.affectedSubscriptions
            .map((s) => s.id)
            .toSet();
      } else {
        _selectedSubscriptionIds.clear();
      }
    });
  }

  Future<void> _handleReassign() async {
    if (_selectedSubscriptionIds.isEmpty) return;

    setState(() => _isSaving = true);
    HapticFeedback.mediumImpact();

    await ref
        .read(paymentMethodNotifierProvider.notifier)
        .reassignSubscriptions(
          subscriptionIds: _selectedSubscriptionIds.toList(),
          newPaymentMethodId: _targetPaymentMethodId,
        );

    setState(() => _isSaving = false);

    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${_selectedSubscriptionIds.length} subscription(s) reassigned successfully.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final paymentMethods = ref
        .watch(paymentMethodNotifierProvider)
        .paymentMethods
        .where((m) => m.id != widget.currentPaymentMethod.id)
        .toList();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle Bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const HeroIcon(
                    HeroIcons.arrowsRightLeft,
                    color: AppColors.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Reassign Subscriptions',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Move subscriptions from ${widget.currentPaymentMethod.displayLabel}',
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

            // Target Payment Method Selector (Modern Preview Chip)
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: ListTile(
                onTap: () {
                  HapticFeedback.selectionClick();
                  // In a real app, this would open a smaller modal to pick the target card
                  // For now, cycle to the next payment method for demonstration.
                  if (paymentMethods.isNotEmpty) {
                    setState(() {
                      final currentIdx = paymentMethods.indexWhere(
                        (m) => m.id == _targetPaymentMethodId,
                      );
                      final nextIdx = (currentIdx + 1) % paymentMethods.length;
                      _targetPaymentMethodId = paymentMethods[nextIdx].id;
                    });
                  }
                },
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: HeroIcon(
                    _targetPaymentMethodId == null
                        ? HeroIcons.creditCard
                        : paymentMethods
                              .firstWhere((m) => m.id == _targetPaymentMethodId)
                              .type
                              .heroIcon,
                    size: 20,
                    color: AppColors.primary,
                  ),
                ),
                title: Text(
                  _targetPaymentMethodId == null
                      ? 'Select Target Card'
                      : paymentMethods
                            .firstWhere((m) => m.id == _targetPaymentMethodId)
                            .displayLabel,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                subtitle: const Text(
                  'Move selected subscriptions here',
                  style: TextStyle(fontSize: 12),
                ),
                trailing: const Icon(
                  Icons.keyboard_arrow_down,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Subscription Checklist Header with Pill
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Select Subscriptions (${_selectedSubscriptionIds.length}/${widget.affectedSubscriptions.length})',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                InkWell(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    _selectAll(
                      _selectedSubscriptionIds.length !=
                          widget.affectedSubscriptions.length,
                    );
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color:
                          _selectedSubscriptionIds.length ==
                              widget.affectedSubscriptions.length
                          ? AppColors.primary.withValues(alpha: 0.1)
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _selectedSubscriptionIds.length ==
                              widget.affectedSubscriptions.length
                          ? 'Deselect All'
                          : 'Select All',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color:
                            _selectedSubscriptionIds.length ==
                                widget.affectedSubscriptions.length
                            ? AppColors.primary
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),

            // Subscriptions List
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.35,
              ),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: widget.affectedSubscriptions.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final sub = widget.affectedSubscriptions[index];
                  final isChecked = _selectedSubscriptionIds.contains(sub.id);

                  return CheckboxListTile(
                    value: isChecked,
                    contentPadding: EdgeInsets.zero,
                    activeColor: AppColors.primary,
                    title: Text(
                      sub.serviceName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      '${CurrencyHelper.formatAmount(sub.effectivePersonalAmount, currency: sub.currency)} / ${sub.billingCycleText}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    onChanged: (val) {
                      HapticFeedback.lightImpact();
                      setState(() {
                        if (val == true) {
                          _selectedSubscriptionIds.add(sub.id);
                        } else {
                          _selectedSubscriptionIds.remove(sub.id);
                        }
                      });
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            // Action Button
            FilledButton(
              onPressed: _selectedSubscriptionIds.isEmpty || _isSaving
                  ? null
                  : _handleReassign,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isSaving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      'Move ${_selectedSubscriptionIds.length} Subscription(s)',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
