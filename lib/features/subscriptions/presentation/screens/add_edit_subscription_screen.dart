import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/validators.dart';
import '../../../auth/presentation/providers/auth_notifier.dart';
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

  BillingCycle _selectedBillingCycle = BillingCycle.monthly;
  String _selectedCurrency = AppConstants.defaultCurrency;
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 30));
  String? _selectedCategory;

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
    // TODO: Load subscription if editing
  }

  @override
  void dispose() {
    _serviceNameController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    _websiteController.dispose();
    super.dispose();
  }

  Future<void> _saveSubscription() async {
    if (!_formKey.currentState!.validate()) return;

    final authState = ref.read(authNotifierProvider);
    if (authState.user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in to continue')),
      );
      return;
    }

    final subscription = SubscriptionEntity(
      id: widget.subscriptionId ?? '',
      userId: authState.user!.id,
      serviceName: _serviceNameController.text.trim(),
      amount: double.parse(_amountController.text),
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
      notificationDays: const ['7', '3', '1'], // Default notification days
      startDate: DateTime.now(),
    );

    if (widget.subscriptionId == null) {
      await ref
          .read(subscriptionNotifierProvider.notifier)
          .addSubscription(subscription);
    } else {
      await ref
          .read(subscriptionNotifierProvider.notifier)
          .updateSubscription(subscription);
    }

    if (mounted) context.pop();
  }

  Future<void> _selectDate() async {
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

  @override
  Widget build(BuildContext context) {
    final subscriptionState = ref.watch(subscriptionNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.subscriptionId == null
              ? 'Add Subscription'
              : 'Edit Subscription',
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Service Name
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

              // Amount
              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: 'Amount *',
                  hintText: '0.00',
                  prefixIcon: const Icon(Icons.attach_money),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: Validators.amount,
                enabled: !subscriptionState.isLoading,
              ),
              const SizedBox(height: 16),

              // Currency & Billing Cycle
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedCurrency,
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
                          : (value) =>
                                setState(() => _selectedCurrency = value!),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<BillingCycle>(
                      value: _selectedBillingCycle,
                      decoration: InputDecoration(
                        labelText: 'Billing Cycle',
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
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Category
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: InputDecoration(
                  labelText: 'Category',
                  prefixIcon: const Icon(Icons.category),
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
                    : (value) => setState(() => _selectedCategory = value),
              ),
              const SizedBox(height: 16),

              // Next Billing Date
              InkWell(
                onTap: subscriptionState.isLoading ? null : _selectDate,
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Next Billing Date *',
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

              // Description
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Description (Optional)',
                  hintText: 'Add notes about this subscription',
                  prefixIcon: const Icon(Icons.description),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                enabled: !subscriptionState.isLoading,
              ),
              const SizedBox(height: 16),

              // Website URL
              TextFormField(
                controller: _websiteController,
                keyboardType: TextInputType.url,
                decoration: InputDecoration(
                  labelText: 'Website (Optional)',
                  hintText: 'https://example.com',
                  prefixIcon: const Icon(Icons.link),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    return Validators.url(value);
                  }
                  return null;
                },
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
                        widget.subscriptionId == null
                            ? 'Add Subscription'
                            : 'Update Subscription',
                        style: const TextStyle(fontSize: 16),
                      ),
              ),
            ],
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
