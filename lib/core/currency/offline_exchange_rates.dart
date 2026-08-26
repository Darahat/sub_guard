import 'exchange_rate.dart';

/// Pre-cached offline exchange rate table against USD
/// Updated baseline rates for reliable offline conversion
class OfflineExchangeRates {
  static final DateTime baselineDate = DateTime(2026, 8, 26);

  static final Map<String, double> usdRates = {
    'USD': 1.0,
    'EUR': 0.918,
    'GBP': 0.768,
    'JPY': 144.50,
    'CAD': 1.355,
    'AUD': 1.485,
    'CHF': 0.852,
    'CNY': 7.125,
    'INR': 83.95,
    'BDT': 119.50,
    'BRL': 5.58,
    'KRW': 1335.0,
    'SGD': 1.305,
    'MXN': 19.35,
    'SEK': 10.22,
    'NZD': 1.615,
    'TRY': 33.95,
    'AED': 3.672,
    'SAR': 3.751,
    'PLN': 3.865,
    'ZAR': 17.75,
    'THB': 34.10,
    'IDR': 15450.0,
    'MYR': 4.35,
    'PHP': 56.25,
    'VND': 24850.0,
    'PKR': 278.50,
    'EGP': 48.65,
    'NGN': 1585.0,
    'NOK': 10.55,
    'DKK': 6.85,
    'HKD': 7.79,
  };

  static Map<String, ExchangeRate> getInitialRates() {
    return usdRates.map(
      (curr, rate) => MapEntry(
        curr,
        ExchangeRate(
          baseCurrency: 'USD',
          quoteCurrency: curr,
          rate: rate,
          fetchedAt: baselineDate,
        ),
      ),
    );
  }
}
