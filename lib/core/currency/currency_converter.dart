import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'exchange_rate.dart';
import 'offline_exchange_rates.dart';

/// Centralized Currency Converter with offline fallback
class CurrencyConverter {
  final Map<String, ExchangeRate> _cachedRates;

  CurrencyConverter({Map<String, ExchangeRate>? initialRates})
    : _cachedRates = initialRates ?? OfflineExchangeRates.getInitialRates();

  /// Converts an amount from [fromCurrency] to [toCurrency]
  double convert({
    required double amount,
    required String fromCurrency,
    required String toCurrency,
  }) {
    if (fromCurrency.toUpperCase() == toCurrency.toUpperCase()) {
      return amount;
    }

    final fromUpper = fromCurrency.toUpperCase();
    final toUpper = toCurrency.toUpperCase();

    final fromRate = _cachedRates[fromUpper]?.rate ?? 1.0;
    final toRate = _cachedRates[toUpper]?.rate ?? 1.0;

    // Convert to USD first as standard denominator
    final amountInUsd = fromUpper == 'USD' ? amount : (amount / fromRate);

    // Convert from USD to target currency
    final converted = toUpper == 'USD' ? amountInUsd : (amountInUsd * toRate);

    return converted;
  }

  /// Check freshness of rate pair
  RateFreshness getRateFreshness(String currency) {
    final rate = _cachedRates[currency.toUpperCase()];
    if (rate == null) return RateFreshness.expired;
    return rate.freshness;
  }

  /// Get latest rate date for transparency metadata
  DateTime getLatestRatesDate() {
    DateTime latest = DateTime(2020);
    for (final rate in _cachedRates.values) {
      if (rate.fetchedAt.isAfter(latest)) {
        latest = rate.fetchedAt;
      }
    }
    return latest;
  }

  /// Check if currency is supported
  bool isSupported(String currency) {
    return _cachedRates.containsKey(currency.toUpperCase());
  }
}

/// Riverpod provider for CurrencyConverter
final currencyConverterProvider = Provider<CurrencyConverter>((ref) {
  return CurrencyConverter();
});
