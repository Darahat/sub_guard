import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heroicons/heroicons.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_helper.dart';
import '../../../budget/presentation/providers/budget_providers.dart';
import '../../../subscriptions/domain/entities/subscription_entity.dart';
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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: _AddEditPaymentMethodDialog(existing: existing),
      ),
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
              ? '"${method.displayLabel}" is linked to $linkedCount active subscription(s).\n\nDeleting it will remove the payment method assignment from those subscriptions.'
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

  void _showActionSheet(
    PaymentMethodEntity method,
    List<SubscriptionEntity> linkedSubs,
  ) {
    HapticFeedback.lightImpact();
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: Text(method.displayLabel),
        message: Text('${linkedSubs.length} linked subscriptions'),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _showAddEditDialog(method);
            },
            child: const Text('Edit Payment Method'),
          ),
          if (linkedSubs.isNotEmpty)
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.pop(context);
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => ReassignPaymentMethodSheet(
                    currentPaymentMethod: method,
                    affectedSubscriptions: linkedSubs,
                  ),
                );
              },
              child: const Text('Reassign Subscriptions'),
            ),
          CupertinoActionSheetAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(context);
              _confirmDelete(method, linkedSubs.length);
            },
            child: const Text('Delete'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          isDefaultAction: true,
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
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
            Tab(
              icon: HeroIcon(HeroIcons.creditCard, size: 20),
              text: 'Payment Methods',
            ),
            Tab(
              icon: HeroIcon(HeroIcons.chartPie, size: 20),
              text: 'Spend Breakdown',
            ),
          ],
        ),
      ),
      floatingActionButton: state.paymentMethods.isEmpty
          ? null
          : FloatingActionButton.extended(
              onPressed: () => _showAddEditDialog(),
              icon: const HeroIcon(HeroIcons.plus, size: 20),
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

                    return AspectRatio(
                      aspectRatio: 1.586,
                      child: InkWell(
                        onTap: () => _showActionSheet(method, linkedSubs),
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                isExpiring
                                    ? (status == PaymentExpiryStatus.expired
                                          ? Colors.red.shade900
                                          : Colors.amber.shade900)
                                    : AppColors.primary,
                                isExpiring
                                    ? (status == PaymentExpiryStatus.expired
                                          ? Colors.red.shade700
                                          : Colors.amber.shade700)
                                    : AppColors.primary.withValues(alpha: 0.8),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    (isExpiring
                                            ? (status ==
                                                      PaymentExpiryStatus
                                                          .expired
                                                  ? Colors.red.shade300
                                                  : Colors.amber.shade300)
                                            : AppColors.primary)
                                        .withValues(alpha: 0.4),
                                blurRadius: 16,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Stack(
                            children: [
                              // Subtle background pattern (shimmer illusion)
                              Positioned(
                                right: -40,
                                top: -40,
                                child: Container(
                                  width: 150,
                                  height: 150,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white.withValues(alpha: 0.1),
                                  ),
                                ),
                              ),
                              Positioned(
                                left: -20,
                                bottom: -20,
                                child: Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white.withValues(alpha: 0.1),
                                  ),
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      HeroIcon(
                                        method.type.heroIcon,
                                        color: Colors.white,
                                        size: 32,
                                      ),
                                      if (method.isDefault)
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withValues(
                                              alpha: 0.2,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: const Text(
                                            'DEFAULT',
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  Text(
                                    method.displayLabel,
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      letterSpacing: 1.2,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        method.formattedExpiry != null
                                            ? 'EXPIRES ${method.formattedExpiry}'
                                            : method.type.label.toUpperCase(),
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.white.withValues(
                                            alpha: 0.8,
                                          ),
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 1.5,
                                        ),
                                      ),
                                      if (linkedSubs.isNotEmpty)
                                        Text(
                                          '${linkedSubs.length} SUBS',
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.white.withValues(
                                              alpha: 0.8,
                                            ),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
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
              final heroIcon =
                  item.paymentMethod?.type.heroIcon ??
                  HeroIcons.questionMarkCircle;

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
                        HeroIcon(heroIcon, size: 18, color: AppColors.primary),
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
              child: const HeroIcon(
                HeroIcons.creditCard,
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
              icon: const HeroIcon(HeroIcons.plus, size: 18),
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
    final isEditing = widget.existing != null;
    final currentYear = DateTime.now().year;

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
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(
              isEditing ? 'Edit Payment Method' : 'Add Payment Method',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Flexible(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Method Name / Nickname *',
                          hintText: 'e.g., Chase Sapphire, Work Amex',
                          prefixIcon: Padding(
                            padding: EdgeInsets.all(12),
                            child: HeroIcon(
                              HeroIcons.pencilSquare,
                              size: 20,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        validator: (val) => val == null || val.trim().isEmpty
                            ? 'Name is required'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<PaymentMethodType>(
                        initialValue: _selectedType,
                        decoration: const InputDecoration(
                          labelText: 'Payment Type',
                          prefixIcon: Padding(
                            padding: EdgeInsets.all(12),
                            child: HeroIcon(
                              HeroIcons.squares2x2,
                              size: 20,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        items: PaymentMethodType.values.map((t) {
                          return DropdownMenuItem(
                            value: t,
                            child: Row(
                              children: [
                                HeroIcon(
                                  t.heroIcon,
                                  size: 18,
                                  color: AppColors.primary,
                                ),
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
                          prefixIcon: Padding(
                            padding: EdgeInsets.all(12),
                            child: HeroIcon(
                              HeroIcons.hashtag,
                              size: 20,
                              color: Colors.grey,
                            ),
                          ),
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
                                onChanged: (v) =>
                                    setState(() => _expiryMonth = v),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: DropdownButtonFormField<int>(
                                initialValue: _expiryYear,
                                decoration: const InputDecoration(
                                  labelText: 'Exp Year',
                                ),
                                items: List.generate(15, (i) => currentYear + i)
                                    .map((y) {
                                      return DropdownMenuItem(
                                        value: y,
                                        child: Text('$y'),
                                      );
                                    })
                                    .toList(),
                                onChanged: (v) =>
                                    setState(() => _expiryYear = v),
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
                        onChanged: (val) {
                          HapticFeedback.lightImpact();
                          setState(() => _isDefault = val);
                        },
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const HeroIcon(
                            HeroIcons.shieldCheck,
                            size: 14,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 6),
                          const Expanded(
                            child: Text(
                              'Non-sensitive metadata only. Never enter CVVs or passwords.',
                              style: TextStyle(
                                fontSize: 10,
                                color: AppColors.textSecondary,
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
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: _save,
                    child: Text(isEditing ? 'Save' : 'Add'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
