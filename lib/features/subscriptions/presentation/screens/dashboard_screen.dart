import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:heroicons/heroicons.dart';

import '../../../../core/constants/preset_catalog.dart';
import '../../../../core/layout/responsive_layout.dart';
import '../../../../core/sync/sync_service.dart';
import '../../../../core/sync/sync_status.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/providers/auth_notifier.dart';
import '../../../budget/presentation/widgets/budget_progress_card.dart';
import '../../../monetization/presentation/providers/purchase_notifier.dart';
import '../../../monetization/presentation/widgets/paywall_bottom_sheet.dart';
import '../../../payment_methods/presentation/widgets/payment_shield_card.dart';
import '../../domain/entities/subscription_entity.dart';
import '../providers/subscription_notifier.dart';
import '../widgets/contract_shield_card.dart';
import '../widgets/price_hike_alert_card.dart';
import '../widgets/renewal_confirmation_card.dart';
import '../widgets/stats_card.dart';
import '../widgets/subscription_card.dart';
import '../widgets/subscription_health_card.dart';

enum SubscriptionSortOption {
  nextBillingDate('Next Renewal'),
  priceHighToLow('Price: High to Low'),
  priceLowToHigh('Price: Low to High'),
  nameAZ('Name (A-Z)');

  final String label;
  const SubscriptionSortOption(this.label);
}

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  final _searchController = TextEditingController();
  String _selectedCategory = 'All';
  SubscriptionStatus? _selectedStatus;
  SubscriptionSortOption _sortOption = SubscriptionSortOption.nextBillingDate;

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
      error: (_, _) => const SizedBox.shrink(),
    );
  }

  List<SubscriptionEntity> _getFilteredAndSortedSubscriptions(
    List<SubscriptionEntity> allSubscriptions,
  ) {
    var filtered = List<SubscriptionEntity>.from(allSubscriptions);

    // 1. Text Search Filter
    final query = _searchController.text.trim().toLowerCase();
    if (query.isNotEmpty) {
      filtered = filtered.where((s) {
        return s.serviceName.toLowerCase().contains(query) ||
            (s.category?.toLowerCase().contains(query) ?? false) ||
            (s.description?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    // 2. Category Filter
    if (_selectedCategory != 'All') {
      filtered = filtered.where((s) {
        return (s.category ?? 'Other').toLowerCase() ==
            _selectedCategory.toLowerCase();
      }).toList();
    }

    // 3. Status Filter
    if (_selectedStatus != null) {
      filtered = filtered.where((s) => s.status == _selectedStatus).toList();
    }

    // 4. Sorting
    switch (_sortOption) {
      case SubscriptionSortOption.nextBillingDate:
        filtered.sort((a, b) => a.nextBillingDate.compareTo(b.nextBillingDate));
        break;
      case SubscriptionSortOption.priceHighToLow:
        filtered.sort((a, b) => b.monthlyCost.compareTo(a.monthlyCost));
        break;
      case SubscriptionSortOption.priceLowToHigh:
        filtered.sort((a, b) => a.monthlyCost.compareTo(b.monthlyCost));
        break;
      case SubscriptionSortOption.nameAZ:
        filtered.sort(
          (a, b) => a.serviceName.toLowerCase().compareTo(
            b.serviceName.toLowerCase(),
          ),
        );
        break;
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final subscriptionState = ref.watch(subscriptionNotifierProvider);
    final authState = ref.watch(authNotifierProvider);
    final isTablet = Breakpoints.isTablet(context);

    // Filter and sort the subscriptions
    final visibleSubscriptions = _getFilteredAndSortedSubscriptions(
      subscriptionState.subscriptions,
    );

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
            tooltip: 'Notification Settings',
            onPressed: () => context.push('/settings/notifications'),
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
            : Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: Breakpoints.isDesktop(context)
                        ? 1200
                        : (isTablet ? 960 : double.infinity),
                  ),
                  child: CustomScrollView(
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
                              if (isTablet)
                                Row(
                                  children: [
                                    Expanded(
                                      child: StatsCard(
                                        title: 'Monthly',
                                        amount: subscriptionState
                                            .totalMonthlySpending,
                                        icon: HeroIcons.calendar,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: StatsCard(
                                        title: 'Yearly',
                                        amount: subscriptionState
                                            .totalYearlySpending,
                                        icon: HeroIcons.calendarDays,
                                        color: AppColors.accent,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: StatsCard(
                                        title: 'Active',
                                        count: subscriptionState
                                            .activeSubscriptionCount,
                                        icon: HeroIcons.checkCircle,
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
                                        icon: HeroIcons.exclamationTriangle,
                                        color: AppColors.warning,
                                      ),
                                    ),
                                  ],
                                )
                              else ...[
                                Row(
                                  children: [
                                    Expanded(
                                      child: StatsCard(
                                        title: 'Monthly',
                                        amount: subscriptionState
                                            .totalMonthlySpending,
                                        icon: HeroIcons.calendar,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: StatsCard(
                                        title: 'Yearly',
                                        amount: subscriptionState
                                            .totalYearlySpending,
                                        icon: HeroIcons.calendarDays,
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
                                        count: subscriptionState
                                            .activeSubscriptionCount,
                                        icon: HeroIcons.checkCircle,
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
                                        icon: HeroIcons.exclamationTriangle,
                                        color: AppColors.warning,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),

                      // 0. Monthly Spending Budget & Overspend Guard (Phase 11)
                      const SliverToBoxAdapter(child: BudgetProgressCard()),

                      // 1. Post-Billing Renewal Check-in Card (Phase 10)
                      const SliverToBoxAdapter(
                        child: RenewalConfirmationCard(),
                      ),

                      // 1.5. Annual Contract & Auto-Renew Lock-in Shield (Phase 14)
                      const SliverToBoxAdapter(child: ContractShieldCard()),

                      // 1.6. Payment Method & Card Expiry Shield (Phase 15)
                      const SliverToBoxAdapter(child: PaymentShieldCard()),

                      // 1.7. Price Hike & Unexpected Increase Anomaly Alert (Phase 16)
                      const SliverToBoxAdapter(child: PriceHikeAlertCard()),

                      // 2. Subscription Health & Potentially Unused Audit Card (Phase 10)
                      const SliverToBoxAdapter(child: SubscriptionHealthCard()),

                      // Search & Filter Actions Row
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
                                    suffixIcon:
                                        _searchController.text.isNotEmpty
                                        ? IconButton(
                                            icon: const Icon(Icons.clear),
                                            onPressed: () {
                                              _searchController.clear();
                                              setState(() {});
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
                                    setState(() {});
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),

                              // Sort Menu Button
                              PopupMenuButton<SubscriptionSortOption>(
                                icon: const Icon(Icons.sort),
                                tooltip: 'Sort By',
                                onSelected: (option) {
                                  HapticFeedback.selectionClick();
                                  setState(() => _sortOption = option);
                                },
                                itemBuilder: (context) =>
                                    SubscriptionSortOption.values.map((option) {
                                      return PopupMenuItem(
                                        value: option,
                                        child: Row(
                                          children: [
                                            if (_sortOption == option)
                                              const Icon(
                                                Icons.check,
                                                size: 18,
                                                color: AppColors.primary,
                                              )
                                            else
                                              const SizedBox(width: 18),
                                            const SizedBox(width: 8),
                                            Text(option.label),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                              ),

                              // Status Filter Menu Button
                              PopupMenuButton<SubscriptionStatus?>(
                                icon: Icon(
                                  Icons.filter_list,
                                  color: _selectedStatus != null
                                      ? AppColors.primary
                                      : null,
                                ),
                                tooltip: 'Filter Status',
                                onSelected: (status) {
                                  HapticFeedback.selectionClick();
                                  setState(() => _selectedStatus = status);
                                },
                                itemBuilder: (context) => [
                                  PopupMenuItem(
                                    value: null,
                                    child: Row(
                                      children: [
                                        if (_selectedStatus == null)
                                          const Icon(
                                            Icons.check,
                                            size: 18,
                                            color: AppColors.primary,
                                          )
                                        else
                                          const SizedBox(width: 18),
                                        const SizedBox(width: 8),
                                        const Text('All Statuses'),
                                      ],
                                    ),
                                  ),
                                  ...SubscriptionStatus.values.map((status) {
                                    final isSelected =
                                        _selectedStatus == status;
                                    return PopupMenuItem(
                                      value: status,
                                      child: Row(
                                        children: [
                                          if (isSelected)
                                            const Icon(
                                              Icons.check,
                                              size: 18,
                                              color: AppColors.primary,
                                            )
                                          else
                                            const SizedBox(width: 18),
                                          const SizedBox(width: 8),
                                          Text(status.name.toUpperCase()),
                                        ],
                                      ),
                                    );
                                  }),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Horizontal Category Filter Pills
                      SliverToBoxAdapter(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          child: Row(
                            children: {...PresetCatalog.categories, 'Other'}
                                .map((cat) {
                                  final isSelected = _selectedCategory == cat;
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: FilterChip(
                                      selected: isSelected,
                                      label: Text(cat),
                                      selectedColor: AppColors.primary
                                          .withValues(alpha: 0.15),
                                      checkmarkColor: AppColors.primary,
                                      labelStyle: TextStyle(
                                        color: isSelected
                                            ? AppColors.primary
                                            : AppColors.textSecondary,
                                        fontWeight: isSelected
                                            ? FontWeight.bold
                                            : FontWeight.w500,
                                        fontSize: 13,
                                      ),
                                      onSelected: (_) {
                                        HapticFeedback.selectionClick();
                                        setState(() => _selectedCategory = cat);
                                      },
                                    ),
                                  );
                                })
                                .toList(),
                          ),
                        ),
                      ),
                      const SliverToBoxAdapter(child: SizedBox(height: 6)),

                      // Subscriptions List or Empty State
                      if (subscriptionState.subscriptions.isEmpty)
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.grey.withValues(alpha: 0.15),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.03),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withValues(
                                        alpha: 0.08,
                                      ),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.shield_outlined,
                                      size: 48,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Welcome to SubGuard',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Never get surprised by unexpected renewal charges again.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  const Divider(height: 1),
                                  const SizedBox(height: 16),
                                  Text(
                                    'POPULAR SERVICES',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey.shade500,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    alignment: WrapAlignment.center,
                                    children:
                                        [
                                          'Netflix',
                                          'Spotify',
                                          'ChatGPT',
                                          'Apple One',
                                          'YouTube',
                                          'Amazon Prime',
                                        ].map((name) {
                                          return ActionChip(
                                            avatar: const Icon(
                                              Icons.add,
                                              size: 16,
                                            ),
                                            label: Text(name),
                                            backgroundColor: AppColors.primary
                                                .withValues(alpha: 0.06),
                                            labelStyle: const TextStyle(
                                              color: AppColors.primary,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 13,
                                            ),
                                            onPressed: () {
                                              HapticFeedback.selectionClick();
                                              final isPro = ref
                                                  .read(
                                                    purchaseNotifierProvider,
                                                  )
                                                  .isPro;
                                              final activeCount = ref
                                                  .read(
                                                    subscriptionNotifierProvider,
                                                  )
                                                  .activeSubscriptionCount;

                                              if (!isPro && activeCount >= 5) {
                                                showModalBottomSheet(
                                                  context: context,
                                                  isScrollControlled: true,
                                                  backgroundColor:
                                                      Colors.transparent,
                                                  constraints:
                                                      Breakpoints.isTablet(
                                                        context,
                                                      )
                                                      ? const BoxConstraints(
                                                          maxWidth: 600,
                                                        )
                                                      : null,
                                                  builder: (_) =>
                                                      const PaywallBottomSheet(),
                                                );
                                                return;
                                              }
                                              context.push(
                                                '/subscriptions/add',
                                              );
                                            },
                                          );
                                        }).toList(),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      else if (visibleSubscriptions.isEmpty)
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 32,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.search_off,
                                  size: 48,
                                  color: Colors.grey.shade400,
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  'No matching subscriptions',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Try adjusting your search query or category filter.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                OutlinedButton(
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() {
                                      _selectedCategory = 'All';
                                      _selectedStatus = null;
                                    });
                                  },
                                  child: const Text('Reset Filters'),
                                ),
                              ],
                            ),
                          ),
                        )
                      else if (isTablet)
                        SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          sliver: SliverGrid(
                            gridDelegate:
                                const SliverGridDelegateWithMaxCrossAxisExtent(
                                  maxCrossAxisExtent: 480,
                                  mainAxisSpacing: 12,
                                  crossAxisSpacing: 12,
                                  mainAxisExtent: 185,
                                ),
                            delegate: SliverChildBuilderDelegate((
                              context,
                              index,
                            ) {
                              final subscription = visibleSubscriptions[index];
                              return SubscriptionCard(
                                subscription: subscription,
                                onTap: () => context.push(
                                  '/subscriptions/${subscription.id}',
                                ),
                              );
                            }, childCount: visibleSubscriptions.length),
                          ),
                        )
                      else
                        SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate((
                              context,
                              index,
                            ) {
                              final subscription = visibleSubscriptions[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: SubscriptionCard(
                                  subscription: subscription,
                                  onTap: () => context.push(
                                    '/subscriptions/${subscription.id}',
                                  ),
                                ),
                              );
                            }, childCount: visibleSubscriptions.length),
                          ),
                        ),

                      // Bottom padding
                      const SliverToBoxAdapter(child: SizedBox(height: 80)),
                    ],
                  ),
                ),
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          HapticFeedback.lightImpact();
          final isPro = ref.read(purchaseNotifierProvider).isPro;
          final activeCount = ref
              .read(subscriptionNotifierProvider)
              .activeSubscriptionCount;

          if (!isPro && activeCount >= 5) {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              constraints: isTablet
                  ? const BoxConstraints(maxWidth: 600)
                  : null,
              builder: (_) => const PaywallBottomSheet(),
            );
            return;
          }

          context.push('/subscriptions/add');
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Subscription'),
      ),
    );
  }
}
