import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_helper.dart';
import '../../../budget/presentation/providers/budget_providers.dart';
import '../../../subscriptions/presentation/providers/subscription_notifier.dart';
import '../../domain/entities/payment_method_entity.dart';
import '../../domain/enums/payment_method_type.dart';
import '../providers/payment_method_providers.dart';
import 'reassign_payment_method_sheet.dart';

class PaymentMethodsScreen extends ConsumerStatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  ConsumerState<PaymentMethodsScreen> createState() =>
      _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends ConsumerState<PaymentMethodsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showAddEditDialog([PaymentMethodEntity? existing]) {
    HapticFeedback.lightImpact();
    showDialog(
      context: context,
      builder: (_) => _AddEditPaymentMethodDialog(existing: existing),
    );
  }

  void _confirmDelete(PaymentMethodEntity method, int linkedCount) {
    HapticFeedback.mediumImpact();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Payment Method?'),
        content: Text(
          linkedCount > 0
              ? '⚠️ "${method.displayLabel}" is linked to $linkedCount active subscription(s).\n\nDeleting it will remove the payment method assignment from those subscriptions.'
              : 'Are you sure you want to remove "${method.displayLabel}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              Navigator.of(ctx).pop();
              await ref
                  .read(paymentMethodNotifierProvider.notifier)
                  .deletePaymentMethod(method.id);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(paymentMethodNotifierProvider);
    final breakdown = ref.watch(paymentMethodSpendBreakdownProvider);
    final primaryCurrency = ref.watch(primaryCurrencyProvider);
    final subscriptions = ref.watch(subscriptionNotifierProvider).subscriptions;
    final now = DateTime.now();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Methods & Shield'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.credit_card), text: 'Payment Methods'),
            Tab(icon: Icon(Icons.pie_chart_outline), text: 'Spend Breakdown'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddEditDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Add Payment Method'),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // 1. Payment Methods List
          state.paymentMethods.isEmpty
              ? _buildEmptyState()
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                  itemCount: state.paymentMethods.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final method = state.paymentMethods[index];
                    final linkedSubs = subscriptions
                        .where((s) => s.paymentMethodId == method.id)
                        .toList();
                    final status = method.evaluateStatus(now);
                    final isExpiring = status.isActionable;

                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isExpiring
                              ? (status == PaymentExpiryStatus.expired
                                    ? Colors.red.shade300
                                    : Colors.amber.shade300)
                              : Colors.grey.withValues(alpha: 0.15),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.1,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  method.type.icon,
                                  color: AppColors.primary,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Flexible(
                                          child: Text(
                                            method.displayLabel,
                                            style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        if (method.isDefault) ...[
                                          const SizedBox(width: 6),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: AppColors.primary
                                                  .withValues(alpha: 0.1),
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: const Text(
                                              'Default',
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.primary,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      method.formattedExpiry != null
                                          ? 'Expires ${method.formattedExpiry}'
                                          : method.type.label,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isExpiring
                                            ? (status ==
                                                      PaymentExpiryStatus
                                                          .expired
                                                  ? AppColors.error
                                                  : Colors.amber.shade900)
                                            : AppColors.textSecondary,
                                        fontWeight: isExpiring
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              PopupMenuButton<String>(
                                icon: const Icon(Icons.more_vert, size: 20),
                                onSelected: (val) {
                                  if (val == 'edit') {
                                    _showAddEditDialog(method);
                                  } else if (val == 'reassign') {
                                    showModalBottomSheet(
                                      context: context,
                                      isScrollControlled: true,
                                      backgroundColor: Colors.transparent,
                                      builder: (_) =>
                                          ReassignPaymentMethodSheet(
                                            currentPaymentMethod: method,
                                            affectedSubscriptions: linkedSubs,
                                          ),
                                    );
                                  } else if (val == 'delete') {
                                    _confirmDelete(method, linkedSubs.length);
                                  }
                                },
                                itemBuilder: (_) => [
                                  const PopupMenuItem(
                                    value: 'edit',
                                    child: Row(
                                      children: [
                                        Icon(Icons.edit_outlined, size: 16),
                                        SizedBox(width: 8),
                                        Text('Edit Method'),
                                      ],
                                    ),
                                  ),
                                  if (linkedSubs.isNotEmpty)
                                    const PopupMenuItem(
                                      value: 'reassign',
                                      child: Row(
                                        children: [
                                          Icon(Icons.swap_horiz, size: 16),
                                          SizedBox(width: 8),
                                          Text('Reassign Subscriptions'),
                                        ],
                                      ),
                                    ),
                                  const PopupMenuItem(
                                    value: 'delete',
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.delete_outline,
                                          color: AppColors.error,
                                          size: 16,
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          'Delete',
                                          style: TextStyle(
                                            color: AppColors.error,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Divider(height: 1),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${linkedSubs.length} linked subscription(s)',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              if (linkedSubs.isNotEmpty)
                                Text(
                                  '${CurrencyHelper.formatAmount(linkedSubs.fold(0.0, (sum, s) => sum + s.monthlyCost), currency: primaryCurrency)}/mo',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),

          // 2. Spending Breakdown
          ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: breakdown.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = breakdown[index];
              final label = item.paymentMethod?.displayLabel ?? 'Unassigned';
              final icon = item.paymentMethod?.type.icon ?? Icons.help_outline;

              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.grey.withValues(alpha: 0.15),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(icon, size: 18, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            label,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Text(
                          CurrencyHelper.formatAmount(
                            item.totalMonthlySpend,
                            currency: primaryCurrency,
                          ),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: item.percentageOfTotal / 100,
                      backgroundColor: Colors.grey.shade100,
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(4),
                      minHeight: 6,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${item.subscriptions.length} subscription(s)',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          '${item.percentageOfTotal.toStringAsFixed(1)}% of total',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.credit_card_outlined,
                size: 48,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'No Payment Methods Added',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Add your payment cards or wallets to track expirations and prevent subscription disruptions.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: () => _showAddEditDialog(),
              icon: const Icon(Icons.add),
              label: const Text('Add Payment Method'),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddEditPaymentMethodDialog extends ConsumerStatefulWidget {
  final PaymentMethodEntity? existing;

  const _AddEditPaymentMethodDialog({this.existing});

  @override
  ConsumerState<_AddEditPaymentMethodDialog> createState() =>
      _AddEditPaymentMethodDialogState();
}

class _AddEditPaymentMethodDialogState
    extends ConsumerState<_AddEditPaymentMethodDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _last4Controller = TextEditingController();

  PaymentMethodType _selectedType = PaymentMethodType.creditCard;
  int? _expiryMonth;
  int? _expiryYear;
  bool _isDefault = false;

  @override
  void initState() {
    super.initState();
    if (widget.existing != null) {
      final e = widget.existing!;
      _nameController.text = e.name;
      _last4Controller.text = e.last4 ?? '';
      _selectedType = e.type;
      _expiryMonth = e.expiryMonth;
      _expiryYear = e.expiryYear;
      _isDefault = e.isDefault;
    } else {
      _expiryMonth = DateTime.now().month;
      _expiryYear = DateTime.now().year + 3;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _last4Controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final now = DateTime.now();
    final isEditing = widget.existing != null;
    final method = PaymentMethodEntity(
      id: widget.existing?.id ?? const Uuid().v4(),
      name: _nameController.text.trim(),
      type: _selectedType,
      last4: _last4Controller.text.trim().isEmpty
          ? null
          : _last4Controller.text.trim(),
      expiryMonth: _selectedType.supportsExpiry ? _expiryMonth : null,
      expiryYear: _selectedType.supportsExpiry ? _expiryYear : null,
      isDefault: _isDefault,
      createdAt: widget.existing?.createdAt ?? now,
      updatedAt: now,
    );

    if (isEditing) {
      await ref
          .read(paymentMethodNotifierProvider.notifier)
          .updatePaymentMethod(method);
    } else {
      await ref
          .read(paymentMethodNotifierProvider.notifier)
          .addPaymentMethod(method);
    }

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final currentYear = DateTime.now().year;
    final isEditing = widget.existing != null;

    return AlertDialog(
      title: Text(isEditing ? 'Edit Payment Method' : 'Add Payment Method'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Method Name *',
                  hintText: 'e.g. Personal Visa, Work Amex',
                  prefixIcon: Icon(Icons.label_outline),
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Name is required' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<PaymentMethodType>(
                initialValue: _selectedType,
                decoration: const InputDecoration(
                  labelText: 'Payment Type',
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                items: PaymentMethodType.values.map((t) {
                  return DropdownMenuItem(
                    value: t,
                    child: Row(
                      children: [
                        Icon(t.icon, size: 18),
                        const SizedBox(width: 8),
                        Text(t.label),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedType = val);
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _last4Controller,
                keyboardType: TextInputType.number,
                maxLength: 4,
                decoration: const InputDecoration(
                  labelText: 'Last 4 Digits (Optional)',
                  hintText: '4821',
                  prefixIcon: Icon(Icons.pin_outlined),
                  counterText: '',
                ),
              ),
              if (_selectedType.supportsExpiry) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        initialValue: _expiryMonth,
                        decoration: const InputDecoration(
                          labelText: 'Exp Month',
                        ),
                        items: List.generate(12, (i) => i + 1).map((m) {
                          return DropdownMenuItem(
                            value: m,
                            child: Text(m.toString().padLeft(2, '0')),
                          );
                        }).toList(),
                        onChanged: (v) => setState(() => _expiryMonth = v),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        initialValue: _expiryYear,
                        decoration: const InputDecoration(
                          labelText: 'Exp Year',
                        ),
                        items: List.generate(15, (i) => currentYear + i).map((
                          y,
                        ) {
                          return DropdownMenuItem(value: y, child: Text('$y'));
                        }).toList(),
                        onChanged: (v) => setState(() => _expiryYear = v),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 12),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text(
                  'Set as Default Method',
                  style: TextStyle(fontSize: 13),
                ),
                value: _isDefault,
                activeTrackColor: AppColors.primary,
                onChanged: (val) => setState(() => _isDefault = val),
              ),
              const SizedBox(height: 4),
              const Text(
                '🔒 Non-sensitive metadata only. Never enter CVVs or passwords.',
                style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _save, child: Text(isEditing ? 'Save' : 'Add')),
      ],
    );
  }
}
