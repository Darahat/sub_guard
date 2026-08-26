import '../../../subscriptions/domain/entities/subscription_entity.dart';

/// Aggregates identified review subscriptions and potential recurring savings
class SavingsOpportunity {
  final List<SubscriptionEntity> subscriptionsToReview;
  final double potentialMonthlySavings;
  final String primaryCurrency;

  const SavingsOpportunity({
    required this.subscriptionsToReview,
    required this.potentialMonthlySavings,
    required this.primaryCurrency,
  });

  bool get hasOpportunities =>
      subscriptionsToReview.isNotEmpty && potentialMonthlySavings > 0;

  double get potentialAnnualSavings => potentialMonthlySavings * 12.0;

  double get potentialFiveYearSavings => potentialMonthlySavings * 60.0;
}
