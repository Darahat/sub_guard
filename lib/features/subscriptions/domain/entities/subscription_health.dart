enum HealthRiskLevel { low, medium, high }

/// Represents the audit result for a single subscription
class SubscriptionHealth {
  final String subscriptionId;
  final bool isPotentiallyUnused;
  final HealthRiskLevel riskLevel;
  final int daysSinceReview;
  final double potentialAnnualSavings;
  final String explanation;

  const SubscriptionHealth({
    required this.subscriptionId,
    this.isPotentiallyUnused = false,
    this.riskLevel = HealthRiskLevel.low,
    this.daysSinceReview = 0,
    this.potentialAnnualSavings = 0.0,
    this.explanation = '',
  });

  factory SubscriptionHealth.healthy(String subscriptionId) =>
      SubscriptionHealth(
        subscriptionId: subscriptionId,
        isPotentiallyUnused: false,
        riskLevel: HealthRiskLevel.low,
      );

  factory SubscriptionHealth.staleRenewal({
    required String subscriptionId,
    required int daysOverdue,
  }) => SubscriptionHealth(
    subscriptionId: subscriptionId,
    isPotentiallyUnused: true,
    riskLevel: HealthRiskLevel.high,
    daysSinceReview: daysOverdue,
    explanation: 'Renewal is $daysOverdue days overdue for confirmation',
  );

  factory SubscriptionHealth.potentiallyUnused({
    required String subscriptionId,
    required int daysSinceInteraction,
    required String reason,
  }) => SubscriptionHealth(
    subscriptionId: subscriptionId,
    isPotentiallyUnused: true,
    riskLevel: daysSinceInteraction > 90
        ? HealthRiskLevel.high
        : HealthRiskLevel.medium,
    daysSinceReview: daysSinceInteraction,
    explanation: reason,
  );
}
