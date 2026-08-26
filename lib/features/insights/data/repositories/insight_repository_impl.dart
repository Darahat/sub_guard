import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../subscriptions/data/datasources/local_subscription_datasource.dart';
import '../../../subscriptions/domain/entities/subscription_entity.dart';
import '../../domain/entities/insight_entity.dart';
import '../../domain/repositories/insight_repository.dart';

class InsightRepositoryImpl implements InsightRepository {
  final LocalSubscriptionDataSource subscriptionDataSource;

  InsightRepositoryImpl(this.subscriptionDataSource);

  @override
  Future<Either<Failure, List<SpendingDataPoint>>> getSpendingTrends({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final subscriptions = await subscriptionDataSource.getAllSubscriptions();
      final subscriptionEntities = subscriptions
          .map((model) => model.toEntity())
          .toList();

      if (subscriptionEntities.isEmpty) {
        return const Right([]);
      }

      final currentMonthlySpend = subscriptionEntities
          .where((s) => s.status == SubscriptionStatus.active)
          .fold<double>(0.0, (sum, sub) => sum + sub.monthlyCost);
      final currentActiveCount = subscriptionEntities
          .where((s) => s.status == SubscriptionStatus.active)
          .length;

      final dataPoints = <SpendingDataPoint>[];
      DateTime currentMonth = DateTime(startDate.year, startDate.month);
      final targetEndMonth = DateTime(endDate.year, endDate.month);

      while (!currentMonth.isAfter(targetEndMonth)) {
        final subsInMonth = subscriptionEntities.where((sub) {
          final created = sub.startDate ?? sub.createdAt ?? DateTime.now();
          final createdMonth = DateTime(created.year, created.month);
          return !createdMonth.isAfter(currentMonth);
        }).toList();

        final monthSpend = subsInMonth.isEmpty
            ? currentMonthlySpend
            : subsInMonth
                .where((s) => s.status == SubscriptionStatus.active)
                .fold<double>(0.0, (sum, sub) => sum + sub.monthlyCost);

        dataPoints.add(
          SpendingDataPoint(
            date: currentMonth,
            amount: monthSpend > 0 ? monthSpend : currentMonthlySpend,
            subscriptionCount: subsInMonth.isNotEmpty ? subsInMonth.length : currentActiveCount,
          ),
        );

        currentMonth = DateTime(currentMonth.year, currentMonth.month + 1);
      }

      // Ensure at least current month is present
      if (dataPoints.isEmpty) {
        dataPoints.add(
          SpendingDataPoint(
            date: DateTime(endDate.year, endDate.month),
            amount: currentMonthlySpend,
            subscriptionCount: currentActiveCount,
          ),
        );
      }

      return Right(dataPoints);
    } on CacheException {
      return Left(CacheFailure('Failed to load spending trends'));
    }
  }

  @override
  Future<Either<Failure, List<CategorySpending>>> getCategoryBreakdown({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final subscriptions = await subscriptionDataSource.getAllSubscriptions();
      final subscriptionEntities = subscriptions
          .map((model) => model.toEntity())
          .toList();

      if (subscriptionEntities.isEmpty) {
        return const Right([]);
      }

      // Group by category for all existing subscriptions
      final Map<String, List<SubscriptionEntity>> categoryGroups = {};
      for (var sub in subscriptionEntities) {
        final category = sub.category != null && sub.category!.trim().isNotEmpty
            ? sub.category!.trim()
            : 'General';
        categoryGroups.putIfAbsent(category, () => []).add(sub);
      }

      // Calculate total monthly spending across all categories
      final totalSpending = subscriptionEntities.fold<double>(
        0.0,
        (sum, sub) => sum + sub.monthlyCost,
      );

      // Create category spending list
      final categorySpending = categoryGroups.entries.map((entry) {
        final categoryTotal = entry.value.fold<double>(
          0.0,
          (sum, sub) => sum + sub.monthlyCost,
        );
        return CategorySpending(
          category: entry.key,
          amount: categoryTotal,
          subscriptionCount: entry.value.length,
          percentage: totalSpending > 0
              ? (categoryTotal / totalSpending) * 100
              : 0,
        );
      }).toList()..sort((a, b) => b.amount.compareTo(a.amount));

      return Right(categorySpending);
    } on CacheException {
      return Left(CacheFailure('Failed to load category breakdown'));
    }
  }

  @override
  Future<Either<Failure, SubscriptionStats>> getSubscriptionStats() async {
    try {
      final subscriptions = await subscriptionDataSource.getAllSubscriptions();
      final subscriptionEntities = subscriptions
          .map((model) => model.toEntity())
          .toList();

      final now = DateTime.now();
      final thisMonthStart = DateTime(now.year, now.month, 1);
      final thisYearStart = DateTime(now.year, 1, 1);

      final activeCount = subscriptionEntities
          .where((sub) => sub.status == SubscriptionStatus.active)
          .length;
      final pausedCount = subscriptionEntities
          .where((sub) => sub.status == SubscriptionStatus.paused)
          .length;
      final cancelledCount = subscriptionEntities
          .where((sub) => sub.status == SubscriptionStatus.cancelled)
          .length;

      final totalMonthly = subscriptionEntities.fold<double>(
        0.0,
        (sum, sub) => sum + sub.monthlyCost,
      );
      final totalYearly = subscriptionEntities.fold<double>(
        0.0,
        (sum, sub) => sum + sub.yearlyCost,
      );

      final monthlyCosts = subscriptionEntities
          .map((s) => s.monthlyCost)
          .toList();
      final avgCost = monthlyCosts.isEmpty
          ? 0.0
          : monthlyCosts.reduce((a, b) => a + b) / monthlyCosts.length;

      final highestCost = monthlyCosts.isEmpty
          ? 0.0
          : monthlyCosts.reduce((a, b) => a > b ? a : b);
      final lowestCost = monthlyCosts.isEmpty
          ? 0.0
          : monthlyCosts.reduce((a, b) => a < b ? a : b);

      final subsThisMonth = subscriptionEntities.where((sub) {
        final subDate = sub.startDate ?? sub.createdAt;
        return subDate != null && subDate.isAfter(thisMonthStart);
      }).length;

      final subsThisYear = subscriptionEntities.where((sub) {
        final subDate = sub.startDate ?? sub.createdAt;
        return subDate != null && subDate.isAfter(thisYearStart);
      }).length;

      return Right(
        SubscriptionStats(
          totalSubscriptions: subscriptionEntities.length,
          activeSubscriptions: activeCount,
          pausedSubscriptions: pausedCount,
          cancelledSubscriptions: cancelledCount,
          totalMonthlySpending: totalMonthly,
          totalYearlySpending: totalYearly,
          averageSubscriptionCost: avgCost,
          highestSubscription: highestCost,
          lowestSubscription: lowestCost,
          subscriptionsThisMonth: subsThisMonth,
          subscriptionsThisYear: subsThisYear,
        ),
      );
    } on CacheException {
      return Left(CacheFailure('Failed to load subscription stats'));
    }
  }

  @override
  Future<Either<Failure, List<TopSubscription>>> getTopSubscriptions({
    int limit = 5,
  }) async {
    try {
      final subscriptions = await subscriptionDataSource.getAllSubscriptions();
      final subscriptionEntities = subscriptions
          .map((model) => model.toEntity())
          .toList();

      if (subscriptionEntities.isEmpty) {
        return const Right([]);
      }

      // Sort by monthly cost and take top N
      final topSubs = List<SubscriptionEntity>.from(subscriptionEntities)
        ..sort((a, b) => b.monthlyCost.compareTo(a.monthlyCost));

      final topList = topSubs.take(limit).map((sub) {
        return TopSubscription(
          serviceName: sub.serviceName,
          monthlyAmount: sub.monthlyCost,
          yearlyAmount: sub.yearlyCost,
          category: sub.category ?? 'General',
          logoUrl: sub.logoUrl,
        );
      }).toList();

      return Right(topList);
    } on CacheException {
      return Left(CacheFailure('Failed to load top subscriptions'));
    }
  }

  @override
  Future<Either<Failure, List<SpendingDataPoint>>> getMonthlySpending({
    required int year,
  }) async {
    try {
      final subscriptions = await subscriptionDataSource.getAllSubscriptions();
      final subscriptionEntities = subscriptions
          .map((model) => model.toEntity())
          .toList();

      final dataPoints = <SpendingDataPoint>[];
      for (int month = 1; month <= 12; month++) {
        final monthDate = DateTime(year, month);
        final monthSubs = subscriptionEntities.where((sub) {
          final subDate = sub.startDate ?? sub.createdAt ?? DateTime.now();
          return subDate.year == year && subDate.month <= month;
        }).toList();

        final monthlyTotal = monthSubs.fold<double>(
          0.0,
          (sum, sub) => sum + sub.monthlyCost,
        );

        dataPoints.add(
          SpendingDataPoint(
            date: monthDate,
            amount: monthlyTotal,
            subscriptionCount: monthSubs.length,
          ),
        );
      }

      return Right(dataPoints);
    } on CacheException {
      return Left(CacheFailure('Failed to load monthly spending'));
    }
  }

  @override
  Future<Either<Failure, Map<int, double>>> getYearlyComparison() async {
    try {
      final subscriptions = await subscriptionDataSource.getAllSubscriptions();
      final subscriptionEntities = subscriptions
          .map((model) => model.toEntity())
          .toList();

      final Map<int, double> yearlySpending = {};
      for (var sub in subscriptionEntities) {
        final subDate = sub.startDate ?? sub.createdAt ?? DateTime.now();
        final year = subDate.year;
        yearlySpending[year] = (yearlySpending[year] ?? 0.0) + sub.yearlyCost;
      }

      return Right(yearlySpending);
    } on CacheException {
      return Left(CacheFailure('Failed to load yearly comparison'));
    }
  }

  @override
  Future<Either<Failure, double>> calculatePotentialSavings() async {
    try {
      final subscriptions = await subscriptionDataSource.getAllSubscriptions();
      final subscriptionEntities = subscriptions
          .map((model) => model.toEntity())
          .toList();

      // Calculate savings from paused/cancelled subscriptions
      final inactiveSavings = subscriptionEntities
          .where(
            (sub) =>
                sub.status == SubscriptionStatus.paused ||
                sub.status == SubscriptionStatus.cancelled,
          )
          .fold<double>(0.0, (sum, sub) => sum + sub.monthlyCost);

      return Right(inactiveSavings);
    } on CacheException {
      return Left(CacheFailure('Failed to calculate potential savings'));
    }
  }
}
