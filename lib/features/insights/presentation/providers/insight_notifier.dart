import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/insight_entity.dart';
import '../../domain/usecases/get_category_breakdown_usecase.dart';
import '../../domain/usecases/get_spending_trends_usecase.dart';
import '../../domain/usecases/get_subscription_stats_usecase.dart';
import '../../domain/usecases/get_top_subscriptions_usecase.dart';
import 'insight_providers.dart';

/// Insights state
class InsightState {
  final List<SpendingDataPoint> spendingTrends;
  final List<CategorySpending> categoryBreakdown;
  final SubscriptionStats? stats;
  final List<TopSubscription> topSubscriptions;
  final InsightDateRange dateRange;
  final bool isLoading;
  final String? error;

  InsightState({
    this.spendingTrends = const [],
    this.categoryBreakdown = const [],
    this.stats,
    this.topSubscriptions = const [],
    this.dateRange = InsightDateRange.lastMonth,
    this.isLoading = false,
    this.error,
  });

  InsightState copyWith({
    List<SpendingDataPoint>? spendingTrends,
    List<CategorySpending>? categoryBreakdown,
    SubscriptionStats? stats,
    List<TopSubscription>? topSubscriptions,
    InsightDateRange? dateRange,
    bool? isLoading,
    String? error,
  }) {
    return InsightState(
      spendingTrends: spendingTrends ?? this.spendingTrends,
      categoryBreakdown: categoryBreakdown ?? this.categoryBreakdown,
      stats: stats ?? this.stats,
      topSubscriptions: topSubscriptions ?? this.topSubscriptions,
      dateRange: dateRange ?? this.dateRange,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Insights notifier
class InsightNotifier extends StateNotifier<InsightState> {
  final GetSpendingTrendsUseCase getSpendingTrendsUseCase;
  final GetCategoryBreakdownUseCase getCategoryBreakdownUseCase;
  final GetSubscriptionStatsUseCase getSubscriptionStatsUseCase;
  final GetTopSubscriptionsUseCase getTopSubscriptionsUseCase;

  InsightNotifier({
    required this.getSpendingTrendsUseCase,
    required this.getCategoryBreakdownUseCase,
    required this.getSubscriptionStatsUseCase,
    required this.getTopSubscriptionsUseCase,
  }) : super(InsightState()) {
    loadInsights();
  }

  /// Load all insights
  Future<void> loadInsights() async {
    state = state.copyWith(isLoading: true, error: null);

    final now = DateTime.now();
    final startDate = state.dateRange.startDate;
    final endDate = now;

    // Load all insights in parallel
    final results = await Future.wait<dynamic>([
      getSpendingTrendsUseCase(startDate: startDate, endDate: endDate),
      getCategoryBreakdownUseCase(startDate: startDate, endDate: endDate),
      getSubscriptionStatsUseCase(),
      getTopSubscriptionsUseCase(limit: 5),
    ]);

    state = state.copyWith(isLoading: false);

    // Process spending trends
    results[0].fold(
      (failure) => state = state.copyWith(error: failure.message),
      (trends) => state = state.copyWith(
        spendingTrends: trends as List<SpendingDataPoint>,
      ),
    );

    // Process category breakdown
    results[1].fold(
      (failure) => state = state.copyWith(error: failure.message),
      (categories) => state = state.copyWith(
        categoryBreakdown: categories as List<CategorySpending>,
      ),
    );

    // Process stats
    results[2].fold(
      (failure) => state = state.copyWith(error: failure.message),
      (stats) => state = state.copyWith(stats: stats as SubscriptionStats),
    );

    // Process top subscriptions
    results[3].fold(
      (failure) => state = state.copyWith(error: failure.message),
      (topSubs) => state = state.copyWith(
        topSubscriptions: topSubs as List<TopSubscription>,
      ),
    );
  }

  /// Change date range and reload
  Future<void> changeDateRange(InsightDateRange newRange) async {
    state = state.copyWith(dateRange: newRange);
    await loadInsights();
  }

  /// Refresh insights
  Future<void> refresh() async {
    await loadInsights();
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Notifier provider
final insightNotifierProvider =
    StateNotifierProvider<InsightNotifier, InsightState>((ref) {
      return InsightNotifier(
        getSpendingTrendsUseCase: ref.watch(getSpendingTrendsUseCaseProvider),
        getCategoryBreakdownUseCase: ref.watch(
          getCategoryBreakdownUseCaseProvider,
        ),
        getSubscriptionStatsUseCase: ref.watch(
          getSubscriptionStatsUseCaseProvider,
        ),
        getTopSubscriptionsUseCase: ref.watch(
          getTopSubscriptionsUseCaseProvider,
        ),
      );
    });
