enum RateFreshness { fresh, stale, expired }

/// Model representing exchange rates against USD baseline
class ExchangeRate {
  final String baseCurrency;
  final String quoteCurrency;
  final double rate;
  final DateTime fetchedAt;

  const ExchangeRate({
    required this.baseCurrency,
    required this.quoteCurrency,
    required this.rate,
    required this.fetchedAt,
  });

  /// Evaluates rate freshness (fresh: <24h, stale: 1–7 days, expired: >7 days)
  RateFreshness get freshness {
    final difference = DateTime.now().difference(fetchedAt);
    if (difference.inHours < 24) return RateFreshness.fresh;
    if (difference.inDays < 7) return RateFreshness.stale;
    return RateFreshness.expired;
  }

  Map<String, dynamic> toJson() => {
    'baseCurrency': baseCurrency,
    'quoteCurrency': quoteCurrency,
    'rate': rate,
    'fetchedAt': fetchedAt.toIso8601String(),
  };

  factory ExchangeRate.fromJson(Map<String, dynamic> json) => ExchangeRate(
    baseCurrency: json['baseCurrency'] as String,
    quoteCurrency: json['quoteCurrency'] as String,
    rate: (json['rate'] as num).toDouble(),
    fetchedAt: DateTime.parse(json['fetchedAt'] as String),
  );
}
