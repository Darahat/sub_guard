import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/preset_catalog.dart';
import '../../../../core/currency/currency_converter.dart';
import '../../../../core/layout/responsive_layout.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_helper.dart';
import '../../../../core/utils/date_helper.dart';
import '../../../../core/utils/validators.dart';
import '../../../auth/presentation/providers/auth_notifier.dart';
import '../../../budget/domain/services/budget_calculator.dart';
import '../../../budget/presentation/providers/budget_providers.dart';
import '../../../monetization/presentation/providers/purchase_notifier.dart';
import '../../../monetization/presentation/widgets/paywall_bottom_sheet.dart';
import '../../../notifications/presentation/providers/notification_providers.dart';
import '../../../payment_methods/presentation/providers/payment_method_providers.dart';
import '../../domain/entities/contract_commitment.dart';
import '../../domain/entities/price_change_record.dart';
import '../../domain/entities/subscription_entity.dart';
import '../providers/subscription_notifier.dart';

class AddEditSubscriptionScreen extends ConsumerStatefulWidget {
  final String? subscriptionId;

  const AddEditSubscriptionScreen({super.key, this.subscriptionId});

  @override
  ConsumerState<AddEditSubscriptionScreen> createState() =>
      _AddEditSubscriptionScreenState();
}

class _AddEditSubscriptionScreenState
    extends ConsumerState<AddEditSubscriptionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _serviceNameController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _websiteController = TextEditingController();
  final _myShareController = TextEditingController();
  final _contractNotesController = TextEditingController();

  BillingCycle _selectedBillingCycle = BillingCycle.monthly;
  String _selectedCurrency = AppConstants.defaultCurrency;
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 30));
  String? _selectedCategory;
  String? _selectedPaymentMethodId;
  bool _isTrial = false;
  String _selectedPresetCategory = 'All';

  // Family & Shared Plan State
  bool _isSharedPlan = false;
  int _splitCount = 2;
  bool _isCustomShare = false;

  // Annual / Contract Commitment State (Phase 14)
  bool _hasContract = false;
  DateTime _contractEndDate = DateTime.now().add(const Duration(days: 365));
  DateTime? _contractStartDate;
  int _cancellationNoticeDays = 30;
  bool _contractAutoRenews = true;

  final List<String> _categories = [
    'Entertainment',
    'Productivity',
    'Cloud Storage',
    'Music',
    'Video Streaming',
    'Gaming',
    'Education',
    'Health & Fitness',
    'News',
    'Software',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _amountController.addListener(() => setState(() {}));
    _myShareController.addListener(() => setState(() {}));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.subscriptionId != null) {
        final subscriptions = ref
            .read(subscriptionNotifierProvider)
            .subscriptions;
        final existing = subscriptions
            .where((s) => s.id == widget.subscriptionId)
            .firstOrNull;

        if (existing != null) {
          setState(() {
            _serviceNameController.text = existing.serviceName;
            _amountController.text = existing.amount.toString();
            _descriptionController.text = existing.description ?? '';
            _websiteController.text = existing.websiteUrl ?? '';
            _selectedCurrency = existing.currency;
            _selectedBillingCycle = existing.billingCycle;
            _selectedDate = existing.nextBillingDate;
            _selectedCategory = existing.category;
            _selectedPaymentMethodId = existing.paymentMethodId;
            _isSharedPlan = existing.isSharedPlan;
            _splitCount = existing.splitCount ?? 2;
            if (existing.myShareAmount != null) {
              _isCustomShare = true;
              _myShareController.text = existing.myShareAmount!.toStringAsFixed(
                2,
              );
            }

            if (existing.hasContract) {
              _hasContract = true;
              _contractEndDate = existing.contractCommitment!.endDate;
              _contractStartDate = existing.contractCommitment!.startDate;
              _cancellationNoticeDays =
                  existing.contractCommitment!.cancellationNoticeDays;
              _contractAutoRenews = existing.contractCommitment!.autoRenews;
              _contractNotesController.text =
                  existing.contractCommitment!.notes ?? '';
            }
          });
        }
      } else {
        // Auto-select the default payment method for new subscriptions
        final paymentMethods = ref
            .read(paymentMethodNotifierProvider)
            .paymentMethods;
        final defaultMethod = paymentMethods
            .where((m) => m.isDefault)
            .firstOrNull;
        if (defaultMethod != null) {
          setState(() {
            _selectedPaymentMethodId = defaultMethod.id;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _serviceNameController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    _websiteController.dispose();
    _myShareController.dispose();
    _contractNotesController.dispose();
    super.dispose();
  }

  void _applyPresetService(PresetService preset) {
    HapticFeedback.selectionClick();
    setState(() {
      _serviceNameController.text = preset.name;
      if (preset.suggestedAmount > 0) {
        _amountController.text = preset.suggestedAmount.toStringAsFixed(2);
      }
      _selectedCategory = preset.category;
      _selectedBillingCycle = preset.defaultBillingCycle;
      _websiteController.text =
          preset.cancellationGuide.web?.actionUrl ?? preset.websiteUrl ?? '';
    });

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Autofilled ${preset.name} (Suggested price: \$${preset.suggestedAmount.toStringAsFixed(2)}. You can adjust this to your plan).',
        ),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _setTrialDuration(int days) {
    HapticFeedback.selectionClick();
    setState(() {
      _selectedDate = DateTime.now().add(Duration(days: days));
      _selectedCategory = _selectedCategory ?? 'Entertainment';
    });
  }

  double get _calculatedPersonalShare {
    final totalAmount = double.tryParse(_amountController.text.trim()) ?? 0.0;
    if (!_isSharedPlan) return totalAmount;
    if (_isCustomShare) {
      return double.tryParse(_myShareController.text.trim()) ?? totalAmount;
    }
    return _splitCount > 0 ? (totalAmount / _splitCount) : totalAmount;
  }

  void _saveSubscription() async {
    if (!_formKey.currentState!.validate()) return;

    final authState = ref.read(authNotifierProvider);
    final currentUserId = authState.user?.id ?? 'local_user';

    final totalAmount = double.parse(_amountController.text.trim());
    final myShare = _isSharedPlan ? _calculatedPersonalShare : null;

    final contract = _hasContract
        ? ContractCommitment(
            startDate: _contractStartDate,
            endDate: _contractEndDate,
            cancellationNoticeDays: _cancellationNoticeDays,
            autoRenews: _contractAutoRenews,
            notes: _contractNotesController.text.trim().isEmpty
                ? null
                : _contractNotesController.text.trim(),
          )
        : null;

    List<PriceChangeRecord> updatedPriceHistory = const [];
    if (widget.subscriptionId != null) {
      final existing = ref
          .read(subscriptionNotifierProvider)
          .subscriptions
          .where((s) => s.id == widget.subscriptionId)
          .firstOrNull;
      if (existing != null) {
        updatedPriceHistory = List.from(existing.priceHistory);
        if ((existing.amount - totalAmount).abs() > 0.001) {
          updatedPriceHistory.add(
            PriceChangeRecord(
              id: const Uuid().v4(),
              previousAmount: existing.amount,
              newAmount: totalAmount,
              currency: _selectedCurrency,
              changedAt: DateTime.now(),
            ),
          );
        }
      }
    }

    final subscription = SubscriptionEntity(
      id: widget.subscriptionId ?? '',
      userId: currentUserId,
      serviceName: _serviceNameController.text.trim(),
      amount: totalAmount,
      currency: _selectedCurrency,
      billingCycle: _selectedBillingCycle,
      nextBillingDate: _selectedDate,
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      category: _selectedCategory,
      websiteUrl: _websiteController.text.trim().isEmpty
          ? null
          : _websiteController.text.trim(),
      status: SubscriptionStatus.active,
      notificationDays: const ['7', '3', '1'],
      startDate: DateTime.now(),
      isSharedPlan: _isSharedPlan,
      splitCount: _isSharedPlan ? _splitCount : null,
      myShareAmount: myShare,
      contractCommitment: contract,
      paymentMethodId: _selectedPaymentMethodId,
      priceHistory: updatedPriceHistory,
    );

    await ref.read(notificationServiceProvider).requestPermissions();

    if (widget.subscriptionId == null) {
      final isPro = ref.read(purchaseNotifierProvider).isPro;
      final activeCount = ref
          .read(subscriptionNotifierProvider)
          .activeSubscriptionCount;

      if (!isPro && activeCount >= 5) {
        if (mounted) {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            constraints: Breakpoints.isTablet(context)
                ? const BoxConstraints(maxWidth: 600)
                : null,
            builder: (_) => const PaywallBottomSheet(),
          );
        }
        return;
      }

      await ref
          .read(subscriptionNotifierProvider.notifier)
          .addSubscription(subscription);
    } else {
      await ref
          .read(subscriptionNotifierProvider.notifier)
          .updateSubscription(subscription);
    }

    if (mounted) {
      context.pop();
    }
  }

  Future<void> _selectDate() async {
    HapticFeedback.lightImpact();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );

    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _selectContractEndDate() async {
    HapticFeedback.lightImpact();
    final picked = await showDatePicker(
      context: context,
      initialDate: _contractEndDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );

    if (picked != null) {
      setState(() => _contractEndDate = picked);
    }
  }

  Widget _buildBudgetImpactPreview() {
    final budgetEval = ref.watch(budgetEvaluationProvider);
    if (!budgetEval.hasBudget) return const SizedBox.shrink();

    final inputAmount = _calculatedPersonalShare;
    if (inputAmount <= 0) return const SizedBox.shrink();

    final converter = ref.watch(currencyConverterProvider);
    final primaryCurrency = ref.watch(primaryCurrencyProvider);

    final impact = BudgetCalculator.evaluateImpact(
      currentTotalMonthly: budgetEval.totalMonthlySpent,
      newAmount: inputAmount,
      newCycle: _selectedBillingCycle,
      newCurrency: _selectedCurrency,
      budgetLimit: budgetEval.budgetLimit,
      primaryCurrency: primaryCurrency,
      converter: converter,
    );

    final isOver = impact.isOverBudget;
    final bannerColor = isOver ? Colors.red.shade50 : Colors.green.shade50;
    final borderColor = isOver ? Colors.red.shade200 : Colors.green.shade200;
    final textColor = isOver ? AppColors.error : AppColors.success;

    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bannerColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isOver ? Icons.warning_amber_rounded : Icons.savings_outlined,
                size: 16,
                color: textColor,
              ),
              const SizedBox(width: 6),
              Text(
                'Monthly Budget Impact',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Current: ${CurrencyHelper.formatAmount(budgetEval.totalMonthlySpent, currency: primaryCurrency)}'
            '  ➔  +${CurrencyHelper.formatAmount(impact.difference, currency: primaryCurrency)}/mo'
            '  ➔  New: ${CurrencyHelper.formatAmount(impact.newTotal, currency: primaryCurrency)}'
            ' / ${CurrencyHelper.formatAmount(budgetEval.budgetLimit ?? 0, currency: primaryCurrency)}',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            isOver
                ? '⚠️ This subscription will exceed your monthly budget by ${CurrencyHelper.formatAmount(impact.newTotal - (budgetEval.budgetLimit ?? 0), currency: primaryCurrency)}!'
                : '✓ ${CurrencyHelper.formatAmount(impact.remainingAfter, currency: primaryCurrency)} will remain in your monthly budget.',
            style: TextStyle(fontSize: 11, color: textColor),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final subscriptionState = ref.watch(subscriptionNotifierProvider);
    final isEditing = widget.subscriptionId != null;

    final calculatedDeadline = DateHelper.dateOnly(
      _contractEndDate,
    ).subtract(Duration(days: _cancellationNoticeDays));

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Subscription' : 'Add Subscription'),
        centerTitle: true,
      ),
      body: SafeArea(
        bottom: true,
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: Breakpoints.isTablet(context) ? 680 : double.infinity,
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 1. Preset Catalog Quick Selector
                    if (!isEditing) ...[
                      Row(
                        children: [
                          const Icon(
                            Icons.bolt,
                            color: AppColors.primary,
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            'Quick Presets (50+ Top Services)',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Category Filter Pills
                      SizedBox(
                        height: 34,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: PresetCatalog.categories.length,
                          separatorBuilder: (_, _) => const SizedBox(width: 6),
                          itemBuilder: (context, index) {
                            final cat = PresetCatalog.categories[index];
                            final isSelected = _selectedPresetCategory == cat;
                            return ChoiceChip(
                              label: Text(cat),
                              selected: isSelected,
                              showCheckmark: false,
                              labelStyle: TextStyle(
                                fontSize: 12,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: isSelected
                                    ? Colors.white
                                    : AppColors.textSecondary,
                              ),
                              selectedColor: AppColors.primary,
                              backgroundColor: Colors.grey.withValues(
                                alpha: 0.08,
                              ),
                              onSelected: (_) =>
                                  setState(() => _selectedPresetCategory = cat),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Preset services horizontal scroll list
                      SizedBox(
                        height: 40,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: PresetCatalog.services
                              .where(
                                (s) =>
                                    _selectedPresetCategory == 'All' ||
                                    s.category == _selectedPresetCategory,
                              )
                              .map((preset) {
                                final isSelected =
                                    _serviceNameController.text.toLowerCase() ==
                                    preset.name.toLowerCase();
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: ActionChip(
                                    avatar: Container(
                                      width: 18,
                                      height: 18,
                                      decoration: BoxDecoration(
                                        color: preset.brandColor,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: Text(
                                          preset.name[0],
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                    label: Text(preset.name),
                                    backgroundColor: isSelected
                                        ? AppColors.primary
                                        : AppColors.primary.withValues(
                                            alpha: 0.06,
                                          ),
                                    labelStyle: TextStyle(
                                      color: isSelected
                                          ? Colors.white
                                          : AppColors.primary,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                    onPressed: () =>
                                        _applyPresetService(preset),
                                  ),
                                );
                              })
                              .toList(),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // 2. Free Trial Mode Toggle
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _isTrial
                            ? AppColors.warning.withValues(alpha: 0.1)
                            : Colors.grey.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _isTrial
                              ? AppColors.warning.withValues(alpha: 0.3)
                              : Colors.transparent,
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.hourglass_top_rounded,
                                color: _isTrial
                                    ? AppColors.warning
                                    : AppColors.textSecondary,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Free Trial Mode',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'Get cancellation reminders before trial converts',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Switch(
                                value: _isTrial,
                                activeThumbColor: AppColors.warning,
                                onChanged: (val) {
                                  HapticFeedback.selectionClick();
                                  setState(() {
                                    _isTrial = val;
                                    if (val) _setTrialDuration(7);
                                  });
                                },
                              ),
                            ],
                          ),
                          if (_isTrial) ...[
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              alignment: WrapAlignment.center,
                              children: [3, 7, 14, 30].map((days) {
                                return OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 6,
                                    ),
                                    side: BorderSide(
                                      color: AppColors.warning.withValues(
                                        alpha: 0.5,
                                      ),
                                    ),
                                  ),
                                  onPressed: () => _setTrialDuration(days),
                                  child: Text('$days Days'),
                                );
                              }).toList(),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 3. Service Name
                    TextFormField(
                      controller: _serviceNameController,
                      decoration: InputDecoration(
                        labelText: 'Service Name *',
                        hintText: 'e.g., Netflix, Spotify',
                        prefixIcon: const Icon(Icons.subscriptions),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: Validators.required,
                      enabled: !subscriptionState.isLoading,
                    ),
                    const SizedBox(height: 16),

                    // 4. Amount & Currency
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            controller: _amountController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: InputDecoration(
                              labelText: 'Total Amount *',
                              hintText: '0.00',
                              prefixIcon: const Icon(Icons.attach_money),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            validator: Validators.amount,
                            enabled: !subscriptionState.isLoading,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 1,
                          child: DropdownButtonFormField<String>(
                            initialValue: _selectedCurrency,
                            isExpanded: true,
                            decoration: InputDecoration(
                              labelText: 'Currency',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            items: AppConstants.supportedCurrencies
                                .map(
                                  (currency) => DropdownMenuItem(
                                    value: currency,
                                    child: Text(currency),
                                  ),
                                )
                                .toList(),
                            onChanged: subscriptionState.isLoading
                                ? null
                                : (value) => setState(
                                    () => _selectedCurrency = value!,
                                  ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // 5. Shared / Family Plan Cost Splitter
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _isSharedPlan
                            ? Colors.purple.shade50
                            : Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _isSharedPlan
                              ? Colors.purple.shade200
                              : Colors.grey.shade200,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.group_outlined,
                                color: _isSharedPlan
                                    ? Colors.purple
                                    : Colors.grey,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Shared / Family Plan',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'Split costs with family or friends',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Switch(
                                value: _isSharedPlan,
                                activeThumbColor: Colors.purple,
                                onChanged: (val) {
                                  HapticFeedback.selectionClick();
                                  setState(() => _isSharedPlan = val);
                                },
                              ),
                            ],
                          ),
                          if (_isSharedPlan) ...[
                            const SizedBox(height: 10),
                            const Divider(height: 1),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                ChoiceChip(
                                  label: const Text('Equal Split'),
                                  selected: !_isCustomShare,
                                  onSelected: (_) =>
                                      setState(() => _isCustomShare = false),
                                ),
                                const SizedBox(width: 8),
                                ChoiceChip(
                                  label: const Text('Custom Share'),
                                  selected: _isCustomShare,
                                  onSelected: (_) =>
                                      setState(() => _isCustomShare = true),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            if (!_isCustomShare) ...[
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Split between:',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                  const SizedBox(height: 8),
                                  Wrap(
                                    spacing: 6,
                                    runSpacing: 6,
                                    children: [2, 3, 4, 5, 6].map((count) {
                                      final isSel = _splitCount == count;
                                      return ActionChip(
                                        label: Text('$count'),
                                        backgroundColor: isSel
                                            ? Colors.purple
                                            : null,
                                        labelStyle: TextStyle(
                                          color: isSel
                                              ? Colors.white
                                              : Colors.black87,
                                          fontWeight: isSel
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                          fontSize: 11,
                                        ),
                                        onPressed: () =>
                                            setState(() => _splitCount = count),
                                      );
                                    }).toList(),
                                  ),
                                ],
                              ),
                            ] else ...[
                              TextField(
                                controller: _myShareController,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                decoration: InputDecoration(
                                  labelText:
                                      'My Personal Share ($_selectedCurrency)',
                                  prefixIcon: const Icon(Icons.person_outline),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ],
                            const SizedBox(height: 8),
                            Text(
                              '💡 Your monthly & budget calculations will use: ${CurrencyHelper.formatAmount(_calculatedPersonalShare, currency: _selectedCurrency)}',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.purple.shade900,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    // Live Budget Impact Preview
                    _buildBudgetImpactPreview(),
                    const SizedBox(height: 16),

                    // 6. Annual Contract & Auto-Renew Lock-in Shield (Phase 14)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _hasContract
                            ? Colors.amber.shade50
                            : Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _hasContract
                              ? Colors.amber.shade300
                              : Colors.grey.shade200,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.shield_outlined,
                                color: _hasContract
                                    ? Colors.amber.shade800
                                    : Colors.grey,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Annual / Contract Commitment',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'Track cancellation notice deadlines to prevent auto-renew lock-ins',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Switch(
                                value: _hasContract,
                                activeThumbColor: Colors.amber.shade800,
                                onChanged: (val) {
                                  HapticFeedback.selectionClick();
                                  setState(() => _hasContract = val);
                                },
                              ),
                            ],
                          ),
                          if (_hasContract) ...[
                            const SizedBox(height: 10),
                            const Divider(height: 1),
                            const SizedBox(height: 10),

                            // Contract End Date Picker
                            InkWell(
                              onTap: _selectContractEndDate,
                              child: InputDecorator(
                                decoration: InputDecoration(
                                  labelText: 'Current Commitment Ends On *',
                                  prefixIcon: const Icon(
                                    Icons.event_busy_outlined,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: Text(
                                  DateHelper.formatDisplayDate(
                                    _contractEndDate,
                                  ),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Notice Days Selection
                            const Text(
                              'Required Cancellation Notice Period:',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Wrap(
                              spacing: 6,
                              children: [7, 14, 30, 45, 60, 90].map((days) {
                                final isSel = _cancellationNoticeDays == days;
                                return ChoiceChip(
                                  label: Text('$days Days'),
                                  selected: isSel,
                                  selectedColor: Colors.amber.shade800,
                                  labelStyle: TextStyle(
                                    fontSize: 11,
                                    color: isSel
                                        ? Colors.white
                                        : Colors.black87,
                                    fontWeight: isSel
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                  onSelected: (_) {
                                    HapticFeedback.selectionClick();
                                    setState(
                                      () => _cancellationNoticeDays = days,
                                    );
                                  },
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 10),

                            // Auto-renews switch
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Auto-renews for another contract period',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Switch(
                                  value: _contractAutoRenews,
                                  activeThumbColor: Colors.amber.shade800,
                                  onChanged: (val) =>
                                      setState(() => _contractAutoRenews = val),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),

                            // Contract Notes
                            TextField(
                              controller: _contractNotesController,
                              decoration: InputDecoration(
                                labelText:
                                    'Contract Cancellation Notes (Optional)',
                                hintText:
                                    'e.g., Must send cancellation email to support',
                                prefixIcon: const Icon(Icons.note_alt_outlined),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),

                            // Calculated Cancellation Deadline Banner
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Colors.amber.shade200,
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.alarm_on,
                                    size: 18,
                                    color: Colors.amber,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      '⚠️ Cancellation Deadline: ${DateHelper.formatDisplayDate(calculatedDeadline)}\nAdvance alarms will schedule automatically.',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.amber.shade900,
                                        height: 1.3,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 7. Billing Cycle
                    DropdownButtonFormField<BillingCycle>(
                      initialValue: _selectedBillingCycle,
                      decoration: InputDecoration(
                        labelText: 'Billing Cycle *',
                        prefixIcon: const Icon(Icons.repeat),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      items: BillingCycle.values
                          .map(
                            (cycle) => DropdownMenuItem(
                              value: cycle,
                              child: Text(_getBillingCycleText(cycle)),
                            ),
                          )
                          .toList(),
                      onChanged: subscriptionState.isLoading
                          ? null
                          : (value) =>
                                setState(() => _selectedBillingCycle = value!),
                    ),
                    const SizedBox(height: 16),

                    // 7.5. Payment Method Selector (Phase 15)
                    () {
                      final paymentMethods = ref
                          .watch(paymentMethodNotifierProvider)
                          .paymentMethods;
                      return DropdownButtonFormField<String?>(
                        initialValue: _selectedPaymentMethodId,
                        isExpanded: true,
                        decoration: InputDecoration(
                          labelText: 'Payment Method (Optional)',
                          prefixIcon: const Icon(Icons.credit_card_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        items: [
                          const DropdownMenuItem<String?>(
                            value: null,
                            child: Text('None / Not Specified'),
                          ),
                          ...paymentMethods.map((m) {
                            return DropdownMenuItem<String?>(
                              value: m.id,
                              child: Row(
                                children: [
                                  Icon(
                                    m.type.icon,
                                    size: 16,
                                    color: AppColors.primary,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      m.displayLabel,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                        onChanged: subscriptionState.isLoading
                            ? null
                            : (val) => setState(
                                () => _selectedPaymentMethodId = val,
                              ),
                      );
                    }(),
                    const SizedBox(height: 16),

                    // 8. Category
                    DropdownButtonFormField<String>(
                      initialValue: _categories.contains(_selectedCategory)
                          ? _selectedCategory
                          : null,
                      isExpanded: true,
                      decoration: InputDecoration(
                        labelText: 'Category',
                        prefixIcon: const Icon(Icons.category_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      items: _categories
                          .map(
                            (category) => DropdownMenuItem(
                              value: category,
                              child: Text(category),
                            ),
                          )
                          .toList(),
                      onChanged: subscriptionState.isLoading
                          ? null
                          : (value) =>
                                setState(() => _selectedCategory = value),
                    ),
                    const SizedBox(height: 16),

                    // 9. Next Billing Date Picker
                    InkWell(
                      onTap: subscriptionState.isLoading ? null : _selectDate,
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: _isTrial
                              ? 'Trial Ends On *'
                              : 'Next Billing Date *',
                          prefixIcon: const Icon(Icons.calendar_today),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 10. Website / Cancellation URL
                    TextFormField(
                      controller: _websiteController,
                      keyboardType: TextInputType.url,
                      decoration: InputDecoration(
                        labelText: 'Website / Cancellation URL (Optional)',
                        hintText: 'https://example.com/account',
                        prefixIcon: const Icon(Icons.link),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      enabled: !subscriptionState.isLoading,
                    ),
                    const SizedBox(height: 24),

                    // Save Button
                    FilledButton(
                      onPressed: subscriptionState.isLoading
                          ? null
                          : _saveSubscription,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: subscriptionState.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              isEditing
                                  ? 'Update Subscription'
                                  : 'Save Subscription',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getBillingCycleText(BillingCycle cycle) {
    switch (cycle) {
      case BillingCycle.daily:
        return 'Daily';
      case BillingCycle.weekly:
        return 'Weekly';
      case BillingCycle.monthly:
        return 'Monthly';
      case BillingCycle.quarterly:
        return 'Quarterly';
      case BillingCycle.yearly:
        return 'Yearly';
    }
  }
}
