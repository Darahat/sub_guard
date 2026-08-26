/// Represents a verified historical payment record for a subscription
class PaymentRecord {
  final String id;
  final String subscriptionId;
  final double amount;
  final String currency;
  final DateTime paidAt;
  final DateTime billingPeriodStart;
  final DateTime billingPeriodEnd;
  final String source; // 'user_confirmed', 'auto_renewal', 'import'
  final DateTime createdAt;

  const PaymentRecord({
    required this.id,
    required this.subscriptionId,
    required this.amount,
    required this.currency,
    required this.paidAt,
    required this.billingPeriodStart,
    required this.billingPeriodEnd,
    this.source = 'user_confirmed',
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'subscriptionId': subscriptionId,
    'amount': amount,
    'currency': currency,
    'paidAt': paidAt.toIso8601String(),
    'billingPeriodStart': billingPeriodStart.toIso8601String(),
    'billingPeriodEnd': billingPeriodEnd.toIso8601String(),
    'source': source,
    'createdAt': createdAt.toIso8601String(),
  };

  factory PaymentRecord.fromJson(Map<String, dynamic> json) => PaymentRecord(
    id: json['id'] as String,
    subscriptionId: json['subscriptionId'] as String,
    amount: (json['amount'] as num).toDouble(),
    currency: json['currency'] as String? ?? 'USD',
    paidAt: DateTime.parse(json['paidAt'] as String),
    billingPeriodStart: DateTime.parse(json['billingPeriodStart'] as String),
    billingPeriodEnd: DateTime.parse(json['billingPeriodEnd'] as String),
    source: json['source'] as String? ?? 'user_confirmed',
    createdAt: DateTime.parse(json['createdAt'] as String),
  );
}
