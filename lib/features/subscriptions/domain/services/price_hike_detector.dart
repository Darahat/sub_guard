import '../../../../core/currency/currency_converter.dart';
import '../../../../core/utils/date_helper.dart';
import '../entities/price_change_record.dart';
import '../entities/subscription_entity.dart';

/// Represents a detected price hike on a specific subscription
class PriceHikeSummary {
  final SubscriptionEntity subscription;
  final PriceChangeRecord latestChange;
  final double monthlyIncrease; // In primary currency
  final double annualIncrease; // In primary currency
  final double percentageChange;
  final int daysSinceChange;

  const PriceHikeSummary({
    required this.subscription,
    required this.latestChange,
    required this.monthlyIncrease,
    required this.annualIncrease,
    required this.percentageChange,
    required this.daysSinceChange,
  });
}

/// Portfolio-level price inflation and spending creep summary
class PortfolioPriceInflationMetrics {
  final double totalMonthlyCreep; // In primary currency
  final double totalAnnualCreep; // In primary currency
  final int hikedSubscriptionsCount;
  final List<PriceHikeSummary> hikes;
  final double averageInflationRate;

  const PortfolioPriceInflationMetrics({
    required this.totalMonthlyCreep,
    required this.totalAnnualCreep,
    required this.hikedSubscriptionsCount,
    required this.hikes,
    required this.averageInflationRate,
  });

  bool get hasRecentHikes => hikes.isNotEmpty;

  factory PortfolioPriceInflationMetrics.empty() {
    return const PortfolioPriceInflationMetrics(
      totalMonthlyCreep: 0.0,
      totalAnnualCreep: 0.0,
      hikedSubscriptionsCount: 0,
      hikes: [],
      averageInflationRate: 0.0,
    );
  }
}

/// Pure domain service for detecting price hikes and calculating inflation impact
class PriceHikeDetector {
  /// Evaluates active subscriptions for price increases within the lookback window
  static PortfolioPriceInflationMetrics evaluateRecentPriceHikes({
    required List<SubscriptionEntity> subscriptions,
    required String primaryCurrency,
    required CurrencyConverter converter,
    Duration lookback = const Duration(days: 180),
    DateTime? now,
  }) {
    final referenceTime = now ?? DateTime.now();
    final today = DateHelper.dateOnly(referenceTime);
    final activeSubs = subscriptions.where(
      (s) => s.status == SubscriptionStatus.active,
    );

    final List<PriceHikeSummary> hikeSummaries = [];
    double totalMonthlyCreep = 0.0;
    double sumPercentages = 0.0;

    for (final sub in activeSubs) {
      if (sub.priceHistory.isEmpty) continue;

      // Find the most recent price increase within lookback
      final recentHikes = sub.priceHistory.where((record) {
        final changeDate = DateHelper.dateOnly(record.changedAt);
        final daysAgo = today.difference(changeDate).inDays;
        return record.isIncrease && daysAgo >= 0 && daysAgo <= lookback.inDays;
      }).toList();

      if (recentHikes.isEmpty) continue;

      // Sort by newest change first
      recentHikes.sort((a, b) => b.changedAt.compareTo(a.changedAt));
      final latestHike = recentHikes.first;

      final diffInOriginalCurrency = latestHike.difference;

      // Compute monthly delta according to billing cycle
      double monthlyDeltaOriginal;
      switch (sub.billingCycle) {
        case BillingCycle.daily:
          monthlyDeltaOriginal = diffInOriginalCurrency * 30.4375;
          break;
        case BillingCycle.weekly:
          monthlyDeltaOriginal = diffInOriginalCurrency * 4.348;
          break;
        case BillingCycle.monthly:
          monthlyDeltaOriginal = diffInOriginalCurrency;
          break;
        case BillingCycle.quarterly:
          monthlyDeltaOriginal = diffInOriginalCurrency / 3;
          break;
        case BillingCycle.yearly:
          monthlyDeltaOriginal = diffInOriginalCurrency / 12;
          break;
      }

      // Convert to primary display currency
      final monthlyIncreaseNormalized = converter.convert(
        amount: monthlyDeltaOriginal,
        fromCurrency: sub.currency,
        toCurrency: primaryCurrency,
      );

      final daysSince = today
          .difference(DateHelper.dateOnly(latestHike.changedAt))
          .inDays;

      hikeSummaries.add(
        PriceHikeSummary(
          subscription: sub,
          latestChange: latestHike,
          monthlyIncrease: monthlyIncreaseNormalized,
          annualIncrease: monthlyIncreaseNormalized * 12,
          percentageChange: latestHike.percentageChange,
          daysSinceChange: daysSince,
        ),
      );

      totalMonthlyCreep += monthlyIncreaseNormalized;
      sumPercentages += latestHike.percentageChange;
    }

    // Sort by largest monthly increase first
    hikeSummaries.sort(
      (a, b) => b.monthlyIncrease.compareTo(a.monthlyIncrease),
    );

    final avgRate = hikeSummaries.isNotEmpty
        ? sumPercentages / hikeSummaries.length
        : 0.0;

    return PortfolioPriceInflationMetrics(
      totalMonthlyCreep: totalMonthlyCreep,
      totalAnnualCreep: totalMonthlyCreep * 12,
      hikedSubscriptionsCount: hikeSummaries.length,
      hikes: hikeSummaries,
      averageInflationRate: avgRate,
    );
  }
}
