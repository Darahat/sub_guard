import 'package:intl/intl.dart';

import '../constants/app_constants.dart';

class CurrencyHelper {
  // Format amount for display
  static String formatAmount(
    double amount, {
    String currency = AppConstants.defaultCurrency,
  }) {
    final formatter = NumberFormat.currency(
      symbol: _getCurrencySymbol(currency),
      decimalDigits: 2,
    );
    return formatter.format(amount);
  }

  // Format amount without symbol
  static String formatAmountWithoutSymbol(double amount) {
    final formatter = NumberFormat.currency(symbol: '', decimalDigits: 2);
    return formatter.format(amount).trim();
  }

  // Get currency symbol
  static String _getCurrencySymbol(String currency) {
    switch (currency.toUpperCase()) {
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      case 'JPY':
        return '¥';
      case 'INR':
        return '₹';
      case 'AUD':
        return 'A\$';
      case 'CAD':
        return 'C\$';
      default:
        return '\$';
    }
  }

  // Parse amount string to double
  static double? parseAmount(String? amountString) {
    if (amountString == null || amountString.isEmpty) return null;

    // Remove currency symbols and spaces
    final cleaned = amountString.replaceAll(RegExp(r'[^\d.]'), '').trim();

    return double.tryParse(cleaned);
  }

  // Calculate monthly amount from yearly
  static double yearlyToMonthly(double yearlyAmount) {
    return yearlyAmount / 12;
  }

  // Calculate yearly amount from monthly
  static double monthlyToYearly(double monthlyAmount) {
    return monthlyAmount * 12;
  }

  // Calculate savings
  static double calculateSavings(double total, double used) {
    return total - used;
  }

  // Calculate percentage
  static double calculatePercentage(double part, double whole) {
    if (whole == 0) return 0;
    return (part / whole) * 100;
  }

  // Format percentage
  static String formatPercentage(double percentage) {
    return '${percentage.toStringAsFixed(1)}%';
  }

  // Convert currency (basic - would need API for real conversion)
  static double convertCurrency(
    double amount,
    String fromCurrency,
    String toCurrency, {
    Map<String, double>? exchangeRates,
  }) {
    // This is a placeholder. In production, use an exchange rate API
    if (fromCurrency == toCurrency) return amount;

    // Use provided exchange rates or default to 1:1
    if (exchangeRates != null) {
      final rate = exchangeRates['$fromCurrency-$toCurrency'] ?? 1.0;
      return amount * rate;
    }

    return amount; // Default: no conversion
  }
}
