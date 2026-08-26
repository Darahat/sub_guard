import '../../../../core/currency/currency_converter.dart';
import '../../../subscriptions/domain/entities/subscription_entity.dart';
import '../entities/payment_method_entity.dart';

/// Group of subscriptions linked to an expiring or expired payment method
class PaymentShieldRiskGroup {
  final PaymentMethodEntity paymentMethod;
  final PaymentExpiryStatus status;
  final int? daysUntilExpiry;
  final List<SubscriptionEntity> affectedSubscriptions;
  final double monthlySpendAtRisk;
  final double annualSpendAtRisk;

  const PaymentShieldRiskGroup({
    required this.paymentMethod,
    required this.status,
    required this.daysUntilExpiry,
    required this.affectedSubscriptions,
    required this.monthlySpendAtRisk,
    required this.annualSpendAtRisk,
  });

  bool get hasActiveSubscriptions => affectedSubscriptions.isNotEmpty;
}

/// Aggregated spending metrics for a single payment method
class PaymentMethodSpendSummary {
  final PaymentMethodEntity? paymentMethod; // null means unassigned
  final List<SubscriptionEntity> subscriptions;
  final double totalMonthlySpend;
  final double percentageOfTotal;

  const PaymentMethodSpendSummary({
    required this.paymentMethod,
    required this.subscriptions,
    required this.totalMonthlySpend,
    required this.percentageOfTotal,
  });
}

/// Pure domain evaluation service for Payment Shield
class PaymentShieldEvaluator {
  /// Evaluates all payment methods against active subscriptions to identify expiring card risks
  static List<PaymentShieldRiskGroup> evaluate({
    required List<PaymentMethodEntity> paymentMethods,
    required List<SubscriptionEntity> subscriptions,
    required String primaryCurrency,
    required CurrencyConverter converter,
    DateTime? now,
  }) {
    final referenceTime = now ?? DateTime.now();
    final activeSubs = subscriptions
        .where((s) => s.status == SubscriptionStatus.active)
        .toList();

    final List<PaymentShieldRiskGroup> riskGroups = [];

    for (final method in paymentMethods) {
      final status = method.evaluateStatus(referenceTime);
      if (!status.isActionable) continue;

      final linkedSubs = activeSubs
          .where((s) => s.paymentMethodId == method.id)
          .toList();

      double totalMonthlySpend = 0.0;
      for (final sub in linkedSubs) {
        final monthlyCost = sub.monthlyCost;
        final converted = converter.convert(
          amount: monthlyCost,
          fromCurrency: sub.currency,
          toCurrency: primaryCurrency,
        );
        totalMonthlySpend += converted;
      }

      riskGroups.add(
        PaymentShieldRiskGroup(
          paymentMethod: method,
          status: status,
          daysUntilExpiry: method.daysUntilExpiry(referenceTime),
          affectedSubscriptions: linkedSubs,
          monthlySpendAtRisk: totalMonthlySpend,
          annualSpendAtRisk: totalMonthlySpend * 12,
        ),
      );
    }

    // Sort by severity (expired & urgent days remaining first)
    riskGroups.sort((a, b) {
      final daysA = a.daysUntilExpiry ?? 999;
      final daysB = b.daysUntilExpiry ?? 999;
      return daysA.compareTo(daysB);
    });

    return riskGroups;
  }

  /// Calculates spending breakdown across all payment methods
  static List<PaymentMethodSpendSummary> calculateSpendBreakdown({
    required List<PaymentMethodEntity> paymentMethods,
    required List<SubscriptionEntity> subscriptions,
    required String primaryCurrency,
    required CurrencyConverter converter,
  }) {
    final activeSubs = subscriptions
        .where((s) => s.status == SubscriptionStatus.active)
        .toList();

    double totalAppMonthlySpend = 0.0;
    final Map<String?, List<SubscriptionEntity>> grouped = {};

    for (final sub in activeSubs) {
      final monthly = converter.convert(
        amount: sub.monthlyCost,
        fromCurrency: sub.currency,
        toCurrency: primaryCurrency,
      );
      totalAppMonthlySpend += monthly;

      final key = sub.paymentMethodId;
      grouped.putIfAbsent(key, () => []).add(sub);
    }

    final List<PaymentMethodSpendSummary> summaries = [];

    for (final method in paymentMethods) {
      final subs = grouped[method.id] ?? [];
      double spend = 0.0;
      for (final sub in subs) {
        spend += converter.convert(
          amount: sub.monthlyCost,
          fromCurrency: sub.currency,
          toCurrency: primaryCurrency,
        );
      }
      final percentage = totalAppMonthlySpend > 0
          ? (spend / totalAppMonthlySpend) * 100
          : 0.0;

      summaries.add(
        PaymentMethodSpendSummary(
          paymentMethod: method,
          subscriptions: subs,
          totalMonthlySpend: spend,
          percentageOfTotal: percentage,
        ),
      );
    }

    // Unassigned subscriptions
    final unassignedSubs = grouped[null] ?? [];
    if (unassignedSubs.isNotEmpty) {
      double spend = 0.0;
      for (final sub in unassignedSubs) {
        spend += converter.convert(
          amount: sub.monthlyCost,
          fromCurrency: sub.currency,
          toCurrency: primaryCurrency,
        );
      }
      final percentage = totalAppMonthlySpend > 0
          ? (spend / totalAppMonthlySpend) * 100
          : 0.0;

      summaries.add(
        PaymentMethodSpendSummary(
          paymentMethod: null,
          subscriptions: unassignedSubs,
          totalMonthlySpend: spend,
          percentageOfTotal: percentage,
        ),
      );
    }

    summaries.sort(
      (a, b) => b.totalMonthlySpend.compareTo(a.totalMonthlySpend),
    );
    return summaries;
  }
}
