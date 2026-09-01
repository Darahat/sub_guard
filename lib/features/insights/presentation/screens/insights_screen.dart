import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heroicons/heroicons.dart';

import '../../../../core/layout/responsive_layout.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/shimmer_loading.dart';
import '../../../analytics/presentation/widgets/opportunity_cost_card.dart';
import '../../../analytics/presentation/widgets/savings_opportunity_card.dart';
import '../../../analytics/presentation/widgets/spending_projection_card.dart';
import '../../../analytics/presentation/widgets/top_cost_services_card.dart';
import '../../../monetization/presentation/providers/purchase_notifier.dart';
import '../../../monetization/presentation/widgets/paywall_bottom_sheet.dart';
import '../../../subscriptions/presentation/providers/subscription_notifier.dart';
import '../../domain/entities/insight_entity.dart';
import '../providers/insight_notifier.dart';
import '../widgets/category_pie_chart.dart';
import '../widgets/spending_trend_chart.dart';
import '../widgets/stats_overview_card.dart';
import '../widgets/top_subscriptions_bar.dart';

class InsightsScreen extends ConsumerStatefulWidget {
  const InsightsScreen({super.key});

  @override
  ConsumerState<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends ConsumerState<InsightsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        HapticFeedback.selectionClick();
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(insightNotifierProvider.notifier).refresh();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(subscriptionNotifierProvider, (previous, next) {
      ref.read(insightNotifierProvider.notifier).refresh();
    });

    final insightState = ref.watch(insightNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Spending Analytics'),
        actions: [
          PopupMenuButton<InsightDateRange>(
            icon: const HeroIcon(HeroIcons.calendar, size: 20),
            onSelected: (range) {
              HapticFeedback.selectionClick();
              ref.read(insightNotifierProvider.notifier).changeDateRange(range);
            },
            itemBuilder: (context) => InsightDateRange.values.map((range) {
              return PopupMenuItem(
                value: range,
                child: Row(
                  children: [
                    if (range == insightState.dateRange)
                      const HeroIcon(
                        HeroIcons.check,
                        size: 16,
                        color: AppColors.primary,
                      )
                    else
                      const SizedBox(width: 16),
                    const SizedBox(width: 8),
                    Text(range.label),
                  ],
                ),
              );
            }).toList(),
          ),
          IconButton(
            icon: const HeroIcon(HeroIcons.arrowPath, size: 20),
            onPressed: () {
              HapticFeedback.lightImpact();
              ref.read(insightNotifierProvider.notifier).refresh();
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Overview', icon: HeroIcon(HeroIcons.chartBar, size: 20)),
            Tab(
              text: 'Outlook',
              icon: HeroIcon(HeroIcons.arrowTrendingUp, size: 20),
            ),
            Tab(
              text: 'Trends',
              icon: HeroIcon(HeroIcons.presentationChartLine, size: 20),
            ),
            Tab(
              text: 'Categories',
              icon: HeroIcon(HeroIcons.chartPie, size: 20),
            ),
          ],
        ),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 240),
        switchInCurve: Curves.easeInOutCubic,
        switchOutCurve: Curves.easeInOutCubic,
        child: insightState.isLoading
            ? const InsightsSkeletonLoader()
            : insightState.error != null
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 48,
                      color: AppColors.error,
                    ),
                    const SizedBox(height: 16),
                    Text(insightState.error!),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () {
                        HapticFeedback.mediumImpact();
                        ref.read(insightNotifierProvider.notifier).refresh();
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              )
            : RefreshIndicator(
                onRefresh: () async {
                  HapticFeedback.mediumImpact();
                  await ref.read(insightNotifierProvider.notifier).refresh();
                },
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: Breakpoints.isDesktop(context)
                          ? 1200
                          : (Breakpoints.isTablet(context)
                                ? 1000
                                : double.infinity),
                    ),
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildOverviewTab(insightState),
                        _buildOutlookTab(insightState),
                        _buildTrendsTab(insightState),
                        _buildCategoriesTab(insightState),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildOverviewTab(InsightState state) {
    if (state.stats == null) {
      return const Center(child: Text('No statistics available'));
    }

    final isTablet = Breakpoints.isTablet(context);

    if (isTablet) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left Column: Intelligence, Stats Overview, Top Subscriptions
            Expanded(
              child: Column(
                children: [
                  _buildWatchdogDigest(state),
                  const SizedBox(height: 16),
                  StatsOverviewCard(stats: state.stats!),
                  const SizedBox(height: 16),
                  _buildTopSubscriptionsCard(state),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // Right Column: Spending Outlook & Potential Savings
            Expanded(
              child: Column(
                children: const [
                  SpendingProjectionCard(),
                  SizedBox(height: 16),
                  SavingsOpportunityCard(),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildWatchdogDigest(state),
          const SizedBox(height: 16),
          StatsOverviewCard(stats: state.stats!),
          const SizedBox(height: 16),
          const SpendingProjectionCard(),
          const SizedBox(height: 16),
          const SavingsOpportunityCard(),
          const SizedBox(height: 16),
          _buildTopSubscriptionsCard(state),
        ],
      ),
    );
  }

  Widget _buildWatchdogDigest(InsightState state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.08),
            AppColors.accent.withValues(alpha: 0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.auto_awesome,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Spending Intelligence',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tracked across ${state.dateRange.label.toLowerCase()}. Projections normalized for monthly budgeting.',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopSubscriptionsCard(InsightState state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Top 5 Subscriptions',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 300,
            child: TopSubscriptionsBar(
              topSubscriptions: state.topSubscriptions,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOutlookTab(InsightState state) {
    final isTablet = Breakpoints.isTablet(context);

    if (isTablet) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                children: const [
                  SpendingProjectionCard(),
                  SizedBox(height: 16),
                  OpportunityCostCard(),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                children: const [
                  SavingsOpportunityCard(),
                  SizedBox(height: 16),
                  TopCostServicesCard(),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: const [
          // 1. Long-term cost projections across 1Y, 3Y, 5Y, 10Y
          SpendingProjectionCard(),
          SizedBox(height: 16),

          // 2. Savings Opportunities linked to hygiene/unused audits
          SavingsOpportunityCard(),
          SizedBox(height: 16),

          // 3. Interactive Compound Growth Opportunity Cost Simulator
          OpportunityCostCard(),
          SizedBox(height: 16),

          // 4. Top 5-Year Lifetime Cost Leaders
          TopCostServicesCard(),
          SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildTrendsTab(InsightState state) {
    final isPro = ref.watch(purchaseNotifierProvider).isPro;

    if (!isPro) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Stack(
          children: [
            Opacity(opacity: 0.15, child: _buildTrendsContent(state)),
            Positioned.fill(
              child: Center(
                child: Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.95),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.2),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.lock_outline,
                          color: AppColors.primary,
                          size: 32,
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'Spending Trends & Forecasts',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Unlock multi-month spending curves, cost trajectory analysis, and forecasting with SubGuard Pro.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 18),
                      FilledButton.icon(
                        onPressed: () {
                          HapticFeedback.mediumImpact();
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            constraints: Breakpoints.isTablet(context)
                                ? const BoxConstraints(maxWidth: 600)
                                : null,
                            builder: (_) => const PaywallBottomSheet(),
                          );
                        },
                        icon: const Icon(Icons.workspace_premium, size: 18),
                        label: const Text('Unlock Pro Insights'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return _buildTrendsContent(state);
  }

  Widget _buildTrendsContent(InsightState state) {
    final isTablet = Breakpoints.isTablet(context);

    if (isTablet) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 6, child: _buildTrendsChartCard(state)),
            const SizedBox(width: 16),
            if (state.spendingTrends.isNotEmpty)
              Expanded(flex: 4, child: _buildTrendsSummaryCard(state)),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildTrendsChartCard(state),
          const SizedBox(height: 16),
          if (state.spendingTrends.isNotEmpty) _buildTrendsSummaryCard(state),
        ],
      ),
    );
  }

  Widget _buildTrendsChartCard(InsightState state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Spending Trends',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  state.dateRange.label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 300,
            child: SpendingTrendChart(dataPoints: state.spendingTrends),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendsSummaryCard(InsightState state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Trend Summary',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 14),
          _buildSummaryRow(
            'Highest Month',
            '\$${state.spendingTrends.map((d) => d.amount).reduce((a, b) => a > b ? a : b).toStringAsFixed(2)}',
          ),
          const Divider(height: 16),
          _buildSummaryRow(
            'Lowest Month',
            '\$${state.spendingTrends.map((d) => d.amount).reduce((a, b) => a < b ? a : b).toStringAsFixed(2)}',
          ),
          const Divider(height: 16),
          _buildSummaryRow(
            'Average Monthly',
            '\$${(state.spendingTrends.map((d) => d.amount).reduce((a, b) => a + b) / state.spendingTrends.length).toStringAsFixed(2)}',
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesTab(InsightState state) {
    final isTablet = Breakpoints.isTablet(context);

    if (isTablet) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 5, child: _buildCategoryPieCard(state)),
            const SizedBox(width: 16),
            if (state.categoryBreakdown.isNotEmpty)
              Expanded(flex: 5, child: _buildCategoryBreakdownCard(state)),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildCategoryPieCard(state),
          const SizedBox(height: 16),
          if (state.categoryBreakdown.isNotEmpty)
            _buildCategoryBreakdownCard(state),
        ],
      ),
    );
  }

  Widget _buildCategoryPieCard(InsightState state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Spending by Category',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 350,
            child: CategoryPieChart(categories: state.categoryBreakdown),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBreakdownCard(InsightState state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Category Breakdown',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 14),
          ...state.categoryBreakdown.map((category) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          category.category,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          '${category.subscriptionCount} subscription${category.subscriptionCount != 1 ? 's' : ''}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '\$${category.amount.toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${category.percentage.toStringAsFixed(1)}%',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textSecondary)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
    );
  }
}
