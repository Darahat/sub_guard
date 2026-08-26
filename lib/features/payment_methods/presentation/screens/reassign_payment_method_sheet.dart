import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
                  child: const Icon(
                    Icons.swap_horiz_rounded,
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

            // Target Payment Method Selector
            DropdownButtonFormField<String?>(
              initialValue: _targetPaymentMethodId,
              decoration: InputDecoration(
                labelText: 'Move to New Payment Method',
                prefixIcon: const Icon(Icons.credit_card),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: [
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text('Unassign (No payment method)'),
                ),
                ...paymentMethods.map((m) {
                  return DropdownMenuItem<String?>(
                    value: m.id,
                    child: Text(m.displayLabel),
                  );
                }),
              ],
              onChanged: (val) => setState(() => _targetPaymentMethodId = val),
            ),
            const SizedBox(height: 16),

            // Subscription Checklist Header
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
                TextButton(
                  onPressed: () => _selectAll(
                    _selectedSubscriptionIds.length !=
                        widget.affectedSubscriptions.length,
                  ),
                  child: Text(
                    _selectedSubscriptionIds.length ==
                            widget.affectedSubscriptions.length
                        ? 'Deselect All'
                        : 'Select All',
                    style: const TextStyle(fontSize: 12),
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
