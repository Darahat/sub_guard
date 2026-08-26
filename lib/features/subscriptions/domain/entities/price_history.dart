enum PriceChangeReason {
  priceHike('Service Price Hike'),
  userEdit('Manual User Edit'),
  planUpgrade('Plan Upgrade'),
  planDowngrade('Plan Downgrade'),
  promoEnded('Promotional Period Ended');

  final String label;
  const PriceChangeReason(this.label);
}

/// Represents historical price changes for a subscription
class PriceHistory {
  final String id;
  final String subscriptionId;
  final double oldAmount;
  final double newAmount;
  final String currency;
  final DateTime effectiveDate;
  final PriceChangeReason reason;
  final DateTime detectedAt;

  const PriceHistory({
    required this.id,
    required this.subscriptionId,
    required this.oldAmount,
    required this.newAmount,
    required this.currency,
    required this.effectiveDate,
    required this.reason,
    required this.detectedAt,
  });

  double get difference => newAmount - oldAmount;
  double get monthlyDifference => difference;
  double get annualImpact => difference * 12;
  bool get isIncrease => newAmount > oldAmount;

  Map<String, dynamic> toJson() => {
    'id': id,
    'subscriptionId': subscriptionId,
    'oldAmount': oldAmount,
    'newAmount': newAmount,
    'currency': currency,
    'effectiveDate': effectiveDate.toIso8601String(),
    'reason': reason.name,
    'detectedAt': detectedAt.toIso8601String(),
  };

  factory PriceHistory.fromJson(Map<String, dynamic> json) => PriceHistory(
    id: json['id'] as String,
    subscriptionId: json['subscriptionId'] as String,
    oldAmount: (json['oldAmount'] as num).toDouble(),
    newAmount: (json['newAmount'] as num).toDouble(),
    currency: json['currency'] as String? ?? 'USD',
    effectiveDate: DateTime.parse(json['effectiveDate'] as String),
    reason: PriceChangeReason.values.firstWhere(
      (r) => r.name == json['reason'],
      orElse: () => PriceChangeReason.priceHike,
    ),
    detectedAt: DateTime.parse(json['detectedAt'] as String),
  );
}
