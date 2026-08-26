import 'package:flutter_test/flutter_test.dart';
import 'package:sub_guard/features/payment_methods/domain/entities/payment_method_entity.dart';
import 'package:sub_guard/features/payment_methods/domain/enums/payment_method_type.dart';

void main() {
  group('PaymentMethodEntity Tests', () {
    test('Accurately computes leap-year and month-end expiration dates', () {
      // 02/2028 is a leap year (Feb 29)
      final leapCard = PaymentMethodEntity(
        id: '1',
        name: 'Visa Leap',
        type: PaymentMethodType.creditCard,
        expiryMonth: 2,
        expiryYear: 2028,
        createdAt: DateTime(2025, 1, 1),
        updatedAt: DateTime(2025, 1, 1),
      );
      expect(
        leapCard.expirationDate,
        equals(DateTime(2028, 2, 29, 23, 59, 59)),
      );

      // 02/2027 is not a leap year (Feb 28)
      final regularFebCard = PaymentMethodEntity(
        id: '2',
        name: 'Visa Regular',
        type: PaymentMethodType.creditCard,
        expiryMonth: 2,
        expiryYear: 2027,
        createdAt: DateTime(2025, 1, 1),
        updatedAt: DateTime(2025, 1, 1),
      );
      expect(
        regularFebCard.expirationDate,
        equals(DateTime(2027, 2, 28, 23, 59, 59)),
      );

      // 09/2026 has 30 days
      final sepCard = PaymentMethodEntity(
        id: '3',
        name: 'Amex Sep',
        type: PaymentMethodType.creditCard,
        expiryMonth: 9,
        expiryYear: 2026,
        createdAt: DateTime(2025, 1, 1),
        updatedAt: DateTime(2025, 1, 1),
      );
      expect(sepCard.expirationDate, equals(DateTime(2026, 9, 30, 23, 59, 59)));
    });

    test('Evaluates risk status deterministically across boundaries', () {
      // Card expires September 30, 2026
      final card = PaymentMethodEntity(
        id: '1',
        name: 'Chase Visa',
        type: PaymentMethodType.creditCard,
        last4: '4821',
        expiryMonth: 9,
        expiryYear: 2026,
        createdAt: DateTime(2025, 1, 1),
        updatedAt: DateTime(2025, 1, 1),
      );

      // 31 days before Sep 30 = Aug 30 -> NORMAL
      expect(
        card.evaluateStatus(DateTime(2026, 8, 30)),
        equals(PaymentExpiryStatus.normal),
      );

      // 30 days before Sep 30 = Aug 31 -> UPCOMING (upper boundary)
      expect(
        card.evaluateStatus(DateTime(2026, 8, 31)),
        equals(PaymentExpiryStatus.upcoming),
      );

      // 15 days before Sep 30 = Sep 15 -> UPCOMING (lower boundary)
      expect(
        card.evaluateStatus(DateTime(2026, 9, 15)),
        equals(PaymentExpiryStatus.upcoming),
      );

      // 14 days before Sep 30 = Sep 16 -> ACTION_SOON (upper boundary)
      expect(
        card.evaluateStatus(DateTime(2026, 9, 16)),
        equals(PaymentExpiryStatus.actionSoon),
      );

      // 1 day before Sep 30 = Sep 29 -> ACTION_SOON (lower boundary)
      expect(
        card.evaluateStatus(DateTime(2026, 9, 29)),
        equals(PaymentExpiryStatus.actionSoon),
      );

      // On Expiration Day Sep 30 -> EXPIRES_TODAY
      expect(
        card.evaluateStatus(DateTime(2026, 9, 30)),
        equals(PaymentExpiryStatus.expiresToday),
      );

      // 1 day after Sep 30 = Oct 1 -> EXPIRED
      expect(
        card.evaluateStatus(DateTime(2026, 10, 1)),
        equals(PaymentExpiryStatus.expired),
      );
    });

    test('Non-expiring types return PaymentExpiryStatus.none', () {
      final paypal = PaymentMethodEntity(
        id: 'p1',
        name: 'Main PayPal',
        type: PaymentMethodType.paypal,
        createdAt: DateTime(2025, 1, 1),
        updatedAt: DateTime(2025, 1, 1),
      );

      expect(paypal.expirationDate, isNull);
      expect(
        paypal.evaluateStatus(DateTime(2026, 9, 30)),
        equals(PaymentExpiryStatus.none),
      );
    });
  });
}
