/// Represents a single historical price change record for a subscription
class PriceChangeRecord {
  final String id;
  final double previousAmount;
  final double newAmount;
  final String currency;
  final DateTime changedAt;
  final String? notes;

  const PriceChangeRecord({
    required this.id,
    required this.previousAmount,
    required this.newAmount,
    required this.currency,
    required this.changedAt,
    this.notes,
  });

  /// The difference in price (positive means increase, negative means decrease)
  double get difference => newAmount - previousAmount;

  /// Absolute price difference
  double get absoluteDifference => (newAmount - previousAmount).abs();

  /// Percentage increase or decrease
  double get percentageChange {
    if (previousAmount <= 0) return 0.0;
    return ((newAmount - previousAmount) / previousAmount) * 100;
  }

  /// Whether this change represents a price hike
  bool get isIncrease => newAmount > previousAmount;

  /// Whether this change represents a discount or price reduction
  bool get isDecrease => newAmount < previousAmount;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'previousAmount': previousAmount,
      'newAmount': newAmount,
      'currency': currency,
      'changedAt': changedAt.toIso8601String(),
      'notes': notes,
    };
  }

  factory PriceChangeRecord.fromJson(Map<String, dynamic> json) {
    return PriceChangeRecord(
      id: json['id'] as String? ?? '',
      previousAmount: (json['previousAmount'] as num?)?.toDouble() ?? 0.0,
      newAmount: (json['newAmount'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] as String? ?? 'USD',
      changedAt: json['changedAt'] != null
          ? DateTime.parse(json['changedAt'] as String)
          : DateTime.now(),
      notes: json['notes'] as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PriceChangeRecord &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
