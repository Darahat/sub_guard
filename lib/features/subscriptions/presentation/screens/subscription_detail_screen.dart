import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/currency_helper.dart';
import '../../domain/entities/subscription_entity.dart';
import '../providers/subscription_notifier.dart';

class SubscriptionDetailScreen extends ConsumerWidget {
  final String subscriptionId;

  const SubscriptionDetailScreen({super.key, required this.subscriptionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscriptionState = ref.watch(subscriptionNotifierProvider);
    final subscription = subscriptionState.subscriptions
        .where((s) => s.id == subscriptionId)
        .firstOrNull;

    if (subscription == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Subscription Details')),
        body: const Center(child: Text('Subscription not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(subscription.serviceName),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              context.push('/subscriptions/edit/$subscriptionId');
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'cancel') {
                _showCancelDialog(context, ref, subscription);
              } else if (value == 'delete') {
                _showDeleteDialog(context, ref, subscription);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'cancel',
                child: Row(
                  children: [
                    Icon(Icons.pause_circle_outline),
                    SizedBox(width: 8),
                    Text('Cancel Subscription'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Delete', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Theme.of(context).colorScheme.primaryContainer,
                    Theme.of(context).colorScheme.secondaryContainer,
                  ],
                ),
              ),
              child: Column(
                children: [
                  // Logo or Icon
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: subscription.logoUrl != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.network(
                              subscription.logoUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  const Icon(Icons.subscriptions, size: 40),
                            ),
                          )
                        : const Icon(Icons.subscriptions, size: 40),
                  ),
                  const SizedBox(height: 16),

                  // Service Name
                  Text(
                    subscription.serviceName,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),

                  // Category
                  if (subscription.category != null)
                    Chip(
                      label: Text(subscription.category!),
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest,
                    ),
                ],
              ),
            ),

            // Billing Info
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Billing Information',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Amount Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Amount',
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              Text(
                                CurrencyHelper.formatAmount(
                                  subscription.amount,
                                  currency: subscription.currency,
                                ),
                                style: Theme.of(context).textTheme.headlineSmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                    ),
                              ),
                            ],
                          ),
                          const Divider(height: 24),
                          _buildInfoRow(
                            context,
                            'Billing Cycle',
                            subscription.billingCycleText,
                          ),
                          const SizedBox(height: 12),
                          _buildInfoRow(
                            context,
                            'Next Billing Date',
                            _formatDate(subscription.nextBillingDate),
                          ),
                          const SizedBox(height: 12),
                          _buildInfoRow(
                            context,
                            'Days Until Billing',
                            '${subscription.daysUntilBilling} days',
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Cost Breakdown
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Cost Breakdown',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 12),
                          _buildInfoRow(
                            context,
                            'Monthly Cost',
                            CurrencyHelper.formatAmount(
                              subscription.monthlyCost,
                              currency: subscription.currency,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildInfoRow(
                            context,
                            'Yearly Cost',
                            CurrencyHelper.formatAmount(
                              subscription.yearlyCost,
                              currency: subscription.currency,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Additional Details
                  Text(
                    'Details',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Details Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInfoRow(
                            context,
                            'Status',
                            subscription.statusText,
                          ),
                          if (subscription.description != null) ...[
                            const Divider(height: 24),
                            Text(
                              'Description',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Text(subscription.description!),
                          ],
                          if (subscription.websiteUrl != null) ...[
                            const Divider(height: 24),
                            _buildInfoRow(
                              context,
                              'Website',
                              subscription.websiteUrl!,
                            ),
                          ],
                          const Divider(height: 24),
                          _buildInfoRow(
                            context,
                            'Start Date',
                            _formatDate(
                              subscription.startDate ?? DateTime.now(),
                            ),
                          ),
                          if (subscription.cancelledDate != null) ...[
                            const SizedBox(height: 12),
                            _buildInfoRow(
                              context,
                              'Cancelled Date',
                              _formatDate(subscription.cancelledDate!),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  void _showCancelDialog(
    BuildContext context,
    WidgetRef ref,
    SubscriptionEntity subscription,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Subscription?'),
        content: Text(
          'Are you sure you want to cancel "${subscription.serviceName}"? You can reactivate it later.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No, Keep It'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref
                  .read(subscriptionNotifierProvider.notifier)
                  .cancelSubscription(subscription.id);
            },
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    WidgetRef ref,
    SubscriptionEntity subscription,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Subscription?'),
        content: Text(
          'Are you sure you want to delete "${subscription.serviceName}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () async {
              Navigator.pop(context);
              await ref
                  .read(subscriptionNotifierProvider.notifier)
                  .deleteSubscription(subscription.id);
              if (context.mounted) {
                context.pop(); // Go back to dashboard
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
