import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/sync/sync_service.dart';
import '../../../../core/sync/sync_status.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/providers/auth_notifier.dart';
import '../../domain/entities/subscription_entity.dart';
import '../providers/subscription_notifier.dart';
import '../widgets/stats_card.dart';
import '../widgets/subscription_card.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  final _searchController = TextEditingController();
  // _selectedStatus removed - using state management instead

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Widget _buildSyncStatusIcon() {
    final syncStatusAsync = ref.watch(syncStatusStreamProvider);
    return syncStatusAsync.when(
      data: (status) {
        if (status.isSyncing) {
          return const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Center(
              child: SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        }
        if (status.hasError) {
          return IconButton(
            icon: const Icon(Icons.cloud_off, color: Colors.orange, size: 20),
            tooltip: 'Sync issue. Tap to retry',
            onPressed: () => ref.read(syncServiceProvider).syncAll(),
          );
        }
        if (status.state == SyncState.success) {
          return const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Icon(Icons.cloud_done, color: Colors.green, size: 20),
          );
        }
        return const SizedBox.shrink();
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final subscriptionState = ref.watch(subscriptionNotifierProvider);
    final authState = ref.watch(authNotifierProvider);

    // Listen for messages
    ref.listen<SubscriptionState>(subscriptionNotifierProvider, (
      previous,
      next,
    ) {
      if (next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: AppColors.error,
          ),
        );
        ref.read(subscriptionNotifierProvider.notifier).clearError();
      }
      if (next.successMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.successMessage!),
            backgroundColor: AppColors.success,
          ),
        );
        ref.read(subscriptionNotifierProvider.notifier).clearSuccess();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Subscriptions'),
        actions: [
          _buildSyncStatusIcon(),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => context.push('/notifications'),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.wait([
            ref.read(subscriptionNotifierProvider.notifier).loadSubscriptions(),
            ref.read(syncServiceProvider).syncAll(),
          ]);
        },
        child:
            subscriptionState.isLoading &&
                subscriptionState.subscriptions.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : CustomScrollView(
                slivers: [
                  // Stats Section
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // User Greeting
                          Text(
                            'Hello, ${authState.user?.displayName ?? 'User'}!',
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 16),

                          // Stats Cards
                          Row(
                            children: [
                              Expanded(
                                child: StatsCard(
                                  title: 'Monthly',
                                  amount:
                                      subscriptionState.totalMonthlySpending,
                                  icon: Icons.calendar_today,
                                  color: AppColors.primary,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: StatsCard(
                                  title: 'Yearly',
                                  amount: subscriptionState.totalYearlySpending,
                                  icon: Icons.event_note,
                                  color: AppColors.accent,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: StatsCard(
                                  title: 'Active',
                                  count:
                                      subscriptionState.activeSubscriptionCount,
                                  icon: Icons.check_circle_outline,
                                  color: AppColors.success,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: StatsCard(
                                  title: 'Expiring Soon',
                                  count: subscriptionState
                                      .expiringSoonSubscriptions
                                      .length,
                                  icon: Icons.warning_amber_rounded,
                                  color: AppColors.warning,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Search & Filter
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              decoration: InputDecoration(
                                hintText: 'Search subscriptions...',
                                prefixIcon: const Icon(Icons.search),
                                suffixIcon: _searchController.text.isNotEmpty
                                    ? IconButton(
                                        icon: const Icon(Icons.clear),
                                        onPressed: () {
                                          _searchController.clear();
                                          ref
                                              .read(
                                                subscriptionNotifierProvider
                                                    .notifier,
                                              )
                                              .loadSubscriptions();
                                        },
                                      )
                                    : null,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                              ),
                              onChanged: (value) {
                                ref
                                    .read(subscriptionNotifierProvider.notifier)
                                    .searchSubscriptions(value);
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          PopupMenuButton<SubscriptionStatus?>(
                            icon: const Icon(Icons.filter_list),
                            onSelected: (status) {
                              // Filter is applied directly to state management
                              if (status != null) {
                                ref
                                    .read(subscriptionNotifierProvider.notifier)
                                    .filterByStatus(status);
                              } else {
                                ref
                                    .read(subscriptionNotifierProvider.notifier)
                                    .loadSubscriptions();
                              }
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: null,
                                child: Text('All'),
                              ),
                              const PopupMenuItem(
                                value: SubscriptionStatus.active,
                                child: Text('Active'),
                              ),
                              const PopupMenuItem(
                                value: SubscriptionStatus.paused,
                                child: Text('Paused'),
                              ),
                              const PopupMenuItem(
                                value: SubscriptionStatus.cancelled,
                                child: Text('Cancelled'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 16)),

                  // Subscriptions List
                  if (subscriptionState.subscriptions.isEmpty)
                    SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.subscriptions_outlined,
                              size: 80,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No subscriptions yet',
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(color: AppColors.textSecondary),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Tap + to add your first subscription',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final subscription =
                              subscriptionState.subscriptions[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: SubscriptionCard(
                              subscription: subscription,
                              onTap: () => context.push(
                                '/subscriptions/${subscription.id}',
                              ),
                            ),
                          );
                        }, childCount: subscriptionState.subscriptions.length),
                      ),
                    ),

                  // Bottom padding
                  const SliverToBoxAdapter(child: SizedBox(height: 80)),
                ],
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/subscriptions/add'),
        icon: const Icon(Icons.add),
        label: const Text('Add Subscription'),
      ),
    );
  }
}
