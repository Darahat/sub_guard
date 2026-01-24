import 'package:freezed_annotation/freezed_annotation.dart';

part 'insight_entity.freezed.dart';

/// Spending trend data point
@freezed
class SpendingDataPoint with _$SpendingDataPoint {
  const factory SpendingDataPoint({
    required DateTime date,
    required double amount,
    required int subscriptionCount,
  }) = _SpendingDataPoint;
}

/// Category spending breakdown
@freezed
class CategorySpending with _$CategorySpending {
  const factory CategorySpending({
    required String category,
    required double amount,
    required int subscriptionCount,
    required double percentage,
  }) = _CategorySpending;
}

/// Subscription statistics
@freezed
class SubscriptionStats with _$SubscriptionStats {
  const factory SubscriptionStats({
    required int totalSubscriptions,
    required int activeSubscriptions,
    required int pausedSubscriptions,
    required int cancelledSubscriptions,
    required double totalMonthlySpending,
    required double totalYearlySpending,
    required double averageSubscriptionCost,
    required double highestSubscription,
    required double lowestSubscription,
    required int subscriptionsThisMonth,
    required int subscriptionsThisYear,
  }) = _SubscriptionStats;

  const SubscriptionStats._();

  /// Calculate growth rate compared to previous period
  double get monthlyGrowthRate => subscriptionsThisMonth > 0
      ? (subscriptionsThisMonth -
                (totalSubscriptions - subscriptionsThisMonth)) /
            (totalSubscriptions - subscriptionsThisMonth) *
            100
      : 0.0;
}

/// Top subscription by spending
@freezed
class TopSubscription with _$TopSubscription {
  const factory TopSubscription({
    required String serviceName,
    required double monthlyAmount,
    required double yearlyAmount,
    required String category,
    String? logoUrl,
  }) = _TopSubscription;
}

/// Date range for filtering insights
enum InsightDateRange {
  lastWeek,
  lastMonth,
  last3Months,
  last6Months,
  lastYear,
  allTime,
}

extension InsightDateRangeExtension on InsightDateRange {
  String get label {
    switch (this) {
      case InsightDateRange.lastWeek:
        return 'Last Week';
      case InsightDateRange.lastMonth:
        return 'Last Month';
      case InsightDateRange.last3Months:
        return 'Last 3 Months';
      case InsightDateRange.last6Months:
        return 'Last 6 Months';
      case InsightDateRange.lastYear:
        return 'Last Year';
      case InsightDateRange.allTime:
        return 'All Time';
    }
  }

  DateTime get startDate {
    final now = DateTime.now();
    switch (this) {
      case InsightDateRange.lastWeek:
        return now.subtract(const Duration(days: 7));
      case InsightDateRange.lastMonth:
        return DateTime(now.year, now.month - 1, now.day);
      case InsightDateRange.last3Months:
        return DateTime(now.year, now.month - 3, now.day);
      case InsightDateRange.last6Months:
        return DateTime(now.year, now.month - 6, now.day);
      case InsightDateRange.lastYear:
        return DateTime(now.year - 1, now.month, now.day);
      case InsightDateRange.allTime:
        return DateTime(2000, 1, 1); // Far past date
    }
  }
}
