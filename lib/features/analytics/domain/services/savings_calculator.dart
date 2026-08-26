import '../../../../core/currency/currency_converter.dart';
import '../../../subscriptions/domain/entities/subscription_entity.dart';
import '../models/savings_opportunity.dart';

/// Service to analyze active subscriptions and calculate potential savings opportunities
class SavingsCalculator {
  /// Evaluates active subscriptions for potential savings by linking Phase 10 hygiene signals
  static SavingsOpportunity evaluateSavings({
    required List<SubscriptionEntity> subscriptions,
    required String primaryCurrency,
    required CurrencyConverter converter,
    DateTime? currentDate,
  }) {
    final now = currentDate ?? DateTime.now();

    final activeSubs = subscriptions
        .where((s) => s.status == SubscriptionStatus.active)
        .toList();

    final reviewCandidates = activeSubs.where((sub) {
      final health = sub.evaluateHealth(now);
      if (health.isPotentiallyUnused) return true;

      // Subscriptions unreviewed for over 60 days
      if (sub.lastReviewedAt == null) {
        return sub.startDate != null &&
            now.difference(sub.startDate!).inDays > 60;
      }
      return now.difference(sub.lastReviewedAt!).inDays > 60;
    }).toList();

    double totalMonthlySavings = 0.0;

    for (final sub in reviewCandidates) {
      final monthlyPersonalShare = _normalizeToMonthly(
        sub.effectivePersonalAmount,
        sub.billingCycle,
      );
      final convertedMonthly = converter.convert(
        amount: monthlyPersonalShare,
        fromCurrency: sub.currency,
        toCurrency: primaryCurrency,
      );
      totalMonthlySavings += convertedMonthly;
    }

    return SavingsOpportunity(
      subscriptionsToReview: reviewCandidates,
      potentialMonthlySavings: totalMonthlySavings,
      primaryCurrency: primaryCurrency,
    );
  }

  static double _normalizeToMonthly(double amount, BillingCycle cycle) {
    switch (cycle) {
      case BillingCycle.daily:
        return amount * 30.4375;
      case BillingCycle.weekly:
        return amount * 4.348;
      case BillingCycle.monthly:
        return amount;
      case BillingCycle.quarterly:
        return amount / 3.0;
      case BillingCycle.yearly:
        return amount / 12.0;
    }
  }
}
