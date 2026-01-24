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

      // Filter subscriptions within date range
      final filteredSubs = subscriptionEntities.where((sub) {
        final subDate = sub.startDate ?? sub.createdAt ?? DateTime.now();
        return subDate.isAfter(startDate) && subDate.isBefore(endDate);
      }).toList();

      // Group by month and calculate spending
      final Map<DateTime, List<SubscriptionEntity>> monthlyGroups = {};
      for (var sub in filteredSubs) {
        final subDate = sub.startDate ?? sub.createdAt ?? DateTime.now();
        final monthKey = DateTime(subDate.year, subDate.month);
        monthlyGroups.putIfAbsent(monthKey, () => []).add(sub);
      }

      // Create data points
      final dataPoints = monthlyGroups.entries.map((entry) {
        final monthlyTotal = entry.value.fold<double>(
          0.0,
          (sum, sub) => sum + sub.monthlyCost,
        );
        return SpendingDataPoint(
          date: entry.key,
          amount: monthlyTotal,
          subscriptionCount: entry.value.length,
        );
      }).toList()..sort((a, b) => a.date.compareTo(b.date));

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

      // Filter by date if provided
      List<SubscriptionEntity> filteredSubs = subscriptionEntities;
      if (startDate != null && endDate != null) {
        filteredSubs = subscriptionEntities.where((sub) {
          final subDate = sub.startDate ?? sub.createdAt ?? DateTime.now();
          return subDate.isAfter(startDate) && subDate.isBefore(endDate);
        }).toList();
      }

      // Group by category
      final Map<String, List<SubscriptionEntity>> categoryGroups = {};
      for (var sub in filteredSubs) {
        final category = sub.category ?? 'Uncategorized';
        categoryGroups.putIfAbsent(category, () => []).add(sub);
      }

      // Calculate total spending
      final totalSpending = filteredSubs.fold<double>(
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

      // Sort by monthly cost and take top N
      final topSubs = subscriptionEntities
        ..sort((a, b) => b.monthlyCost.compareTo(a.monthlyCost));

      final topList = topSubs.take(limit).map((sub) {
        return TopSubscription(
          serviceName: sub.serviceName,
          monthlyAmount: sub.monthlyCost,
          yearlyAmount: sub.yearlyCost,
          category: sub.category ?? 'Uncategorized',
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
