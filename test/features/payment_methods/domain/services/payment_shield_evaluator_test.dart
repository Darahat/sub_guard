import 'package:flutter_test/flutter_test.dart';
import 'package:sub_guard/core/currency/currency_converter.dart';
import 'package:sub_guard/features/payment_methods/domain/entities/payment_method_entity.dart';
import 'package:sub_guard/features/payment_methods/domain/enums/payment_method_type.dart';
import 'package:sub_guard/features/payment_methods/domain/services/payment_shield_evaluator.dart';
import 'package:sub_guard/features/subscriptions/domain/entities/subscription_entity.dart';

void main() {
  group('PaymentShieldEvaluator Tests', () {
    late CurrencyConverter converter;

    setUp(() {
      converter = CurrencyConverter();
    });

    test(
      'Evaluates spend at risk and groups affected subscriptions correctly',
      () {
        final expiringCard = PaymentMethodEntity(
          id: 'card_1',
          name: 'Personal Visa',
          type: PaymentMethodType.creditCard,
          last4: '4821',
          expiryMonth: 9,
          expiryYear: 2026, // Expires Sep 30, 2026
          createdAt: DateTime(2025, 1, 1),
          updatedAt: DateTime(2025, 1, 1),
        );

        final safeCard = PaymentMethodEntity(
          id: 'card_2',
          name: 'Work Amex',
          type: PaymentMethodType.creditCard,
          last4: '1004',
          expiryMonth: 12,
          expiryYear: 2028,
          createdAt: DateTime(2025, 1, 1),
          updatedAt: DateTime(2025, 1, 1),
        );

        final sub1 = SubscriptionEntity(
          id: 'sub_1',
          userId: 'u1',
          serviceName: 'Netflix',
          amount: 15.0,
          currency: 'USD',
          billingCycle: BillingCycle.monthly,
          nextBillingDate: DateTime(2026, 9, 15),
          paymentMethodId: 'card_1',
        );

        final sub2 = SubscriptionEntity(
          id: 'sub_2',
          userId: 'u1',
          serviceName: 'Spotify',
          amount: 10.0,
          currency: 'USD',
          billingCycle: BillingCycle.monthly,
          nextBillingDate: DateTime(2026, 9, 20),
          paymentMethodId: 'card_1',
        );

        final sub3 = SubscriptionEntity(
          id: 'sub_3',
          userId: 'u1',
          serviceName: 'AWS Cloud',
          amount: 50.0,
          currency: 'USD',
          billingCycle: BillingCycle.monthly,
          nextBillingDate: DateTime(2026, 9, 25),
          paymentMethodId: 'card_2',
        );

        // On Sep 10, 2026 (20 days before expiry -> UPCOMING)
        final referenceDate = DateTime(2026, 9, 10);

        final riskGroups = PaymentShieldEvaluator.evaluate(
          paymentMethods: [expiringCard, safeCard],
          subscriptions: [sub1, sub2, sub3],
          primaryCurrency: 'USD',
          converter: converter,
          now: referenceDate,
        );

        expect(riskGroups.length, equals(1));
        final group = riskGroups.first;
        expect(group.paymentMethod.id, equals('card_1'));
        expect(group.affectedSubscriptions.length, equals(2));
        expect(group.monthlySpendAtRisk, equals(25.0)); // $15 + $10
        expect(group.annualSpendAtRisk, equals(300.0)); // $25 * 12
      },
    );

    test(
      'Calculates spending breakdown across all payment methods properly',
      () {
        final card1 = PaymentMethodEntity(
          id: 'card_1',
          name: 'Personal Card',
          createdAt: DateTime(2025, 1, 1),
          updatedAt: DateTime(2025, 1, 1),
        );

        final card2 = PaymentMethodEntity(
          id: 'card_2',
          name: 'Business Card',
          createdAt: DateTime(2025, 1, 1),
          updatedAt: DateTime(2025, 1, 1),
        );

        final sub1 = SubscriptionEntity(
          id: 's1',
          userId: 'u1',
          serviceName: 'Netflix',
          amount: 20.0,
          currency: 'USD',
          billingCycle: BillingCycle.monthly,
          nextBillingDate: DateTime(2026, 10, 1),
          paymentMethodId: 'card_1',
        );

        final sub2 = SubscriptionEntity(
          id: 's2',
          userId: 'u1',
          serviceName: 'GitHub Copilot',
          amount: 80.0,
          currency: 'USD',
          billingCycle: BillingCycle.monthly,
          nextBillingDate: DateTime(2026, 10, 1),
          paymentMethodId: 'card_2',
        );

        final breakdown = PaymentShieldEvaluator.calculateSpendBreakdown(
          paymentMethods: [card1, card2],
          subscriptions: [sub1, sub2],
          primaryCurrency: 'USD',
          converter: converter,
        );

        expect(breakdown.length, equals(2));
        expect(breakdown.first.paymentMethod?.name, equals('Business Card'));
        expect(breakdown.first.totalMonthlySpend, equals(80.0));
        expect(breakdown.first.percentageOfTotal, equals(80.0));

        expect(breakdown[1].paymentMethod?.name, equals('Personal Card'));
        expect(breakdown[1].totalMonthlySpend, equals(20.0));
        expect(breakdown[1].percentageOfTotal, equals(20.0));
      },
    );
  });
}
