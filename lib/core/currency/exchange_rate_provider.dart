import 'exchange_rate.dart';

abstract class ExchangeRateProvider {
  /// Fetch current exchange rates against a base currency (default USD)
  Future<Map<String, ExchangeRate>> getRates({String baseCurrency = 'USD'});
}
