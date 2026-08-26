/// Spending trend data point
class SpendingDataPoint {
  final DateTime date;
  final double amount;
  final int subscriptionCount;

  const SpendingDataPoint({
    required this.date,
    required this.amount,
    required this.subscriptionCount,
  });

  SpendingDataPoint copyWith({
    DateTime? date,
    double? amount,
    int? subscriptionCount,
  }) {
    return SpendingDataPoint(
      date: date ?? this.date,
      amount: amount ?? this.amount,
      subscriptionCount: subscriptionCount ?? this.subscriptionCount,
    );
  }
}

/// Category spending breakdown
class CategorySpending {
  final String category;
  final double amount;
  final int subscriptionCount;
  final double percentage;

  const CategorySpending({
    required this.category,
    required this.amount,
    required this.subscriptionCount,
    required this.percentage,
  });

  CategorySpending copyWith({
    String? category,
    double? amount,
    int? subscriptionCount,
    double? percentage,
  }) {
    return CategorySpending(
      category: category ?? this.category,
      amount: amount ?? this.amount,
      subscriptionCount: subscriptionCount ?? this.subscriptionCount,
      percentage: percentage ?? this.percentage,
    );
  }
}

/// Subscription statistics
class SubscriptionStats {
  final int totalSubscriptions;
  final int activeSubscriptions;
  final int pausedSubscriptions;
  final int cancelledSubscriptions;
  final double totalMonthlySpending;
  final double totalYearlySpending;
  final double averageSubscriptionCost;
  final double highestSubscription;
  final double lowestSubscription;
  final int subscriptionsThisMonth;
  final int subscriptionsThisYear;

  const SubscriptionStats({
    required this.totalSubscriptions,
    required this.activeSubscriptions,
    required this.pausedSubscriptions,
    required this.cancelledSubscriptions,
    required this.totalMonthlySpending,
    required this.totalYearlySpending,
    required this.averageSubscriptionCost,
    required this.highestSubscription,
    required this.lowestSubscription,
    required this.subscriptionsThisMonth,
    required this.subscriptionsThisYear,
  });

  SubscriptionStats copyWith({
    int? totalSubscriptions,
    int? activeSubscriptions,
    int? pausedSubscriptions,
    int? cancelledSubscriptions,
    double? totalMonthlySpending,
    double? totalYearlySpending,
    double? averageSubscriptionCost,
    double? highestSubscription,
    double? lowestSubscription,
    int? subscriptionsThisMonth,
    int? subscriptionsThisYear,
  }) {
    return SubscriptionStats(
      totalSubscriptions: totalSubscriptions ?? this.totalSubscriptions,
      activeSubscriptions: activeSubscriptions ?? this.activeSubscriptions,
      pausedSubscriptions: pausedSubscriptions ?? this.pausedSubscriptions,
      cancelledSubscriptions: cancelledSubscriptions ?? this.cancelledSubscriptions,
      totalMonthlySpending: totalMonthlySpending ?? this.totalMonthlySpending,
      totalYearlySpending: totalYearlySpending ?? this.totalYearlySpending,
      averageSubscriptionCost: averageSubscriptionCost ?? this.averageSubscriptionCost,
      highestSubscription: highestSubscription ?? this.highestSubscription,
      lowestSubscription: lowestSubscription ?? this.lowestSubscription,
      subscriptionsThisMonth: subscriptionsThisMonth ?? this.subscriptionsThisMonth,
      subscriptionsThisYear: subscriptionsThisYear ?? this.subscriptionsThisYear,
    );
  }

  /// Calculate growth rate compared to previous period
  double get monthlyGrowthRate => subscriptionsThisMonth > 0
      ? (subscriptionsThisMonth -
                (totalSubscriptions - subscriptionsThisMonth)) /
            (totalSubscriptions - subscriptionsThisMonth) *
            100
      : 0.0;
}

/// Top subscription by spending
class TopSubscription {
  final String serviceName;
  final double monthlyAmount;
  final double yearlyAmount;
  final String category;
  final String? logoUrl;

  const TopSubscription({
    required this.serviceName,
    required this.monthlyAmount,
    required this.yearlyAmount,
    required this.category,
    this.logoUrl,
  });

  TopSubscription copyWith({
    String? serviceName,
    double? monthlyAmount,
    double? yearlyAmount,
    String? category,
    String? logoUrl,
  }) {
    return TopSubscription(
      serviceName: serviceName ?? this.serviceName,
      monthlyAmount: monthlyAmount ?? this.monthlyAmount,
      yearlyAmount: yearlyAmount ?? this.yearlyAmount,
      category: category ?? this.category,
      logoUrl: logoUrl ?? this.logoUrl,
    );
  }
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
