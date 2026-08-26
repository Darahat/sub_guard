import 'package:flutter_test/flutter_test.dart';
import 'package:sub_guard/core/currency/currency_converter.dart';
import 'package:sub_guard/features/subscriptions/domain/entities/price_change_record.dart';
import 'package:sub_guard/features/subscriptions/domain/entities/subscription_entity.dart';
import 'package:sub_guard/features/subscriptions/domain/services/price_hike_detector.dart';

void main() {
  group('PriceHikeDetector Tests', () {
    late CurrencyConverter converter;

    setUp(() {
      converter = CurrencyConverter();
    });

    test(
      'Accurately detects recent price increases and calculates monthly and annual creep',
      () {
        final now = DateTime(2026, 8, 20);

        // Sub 1: Monthly sub increased from $15.49 to $17.99 10 days ago (+$2.50/mo)
        final sub1 = SubscriptionEntity(
          id: 'sub_1',
          userId: 'u1',
          serviceName: 'Netflix',
          amount: 17.99,
          currency: 'USD',
          billingCycle: BillingCycle.monthly,
          nextBillingDate: DateTime(2026, 9, 1),
          priceHistory: [
            PriceChangeRecord(
              id: 'ph_1',
              previousAmount: 15.49,
              newAmount: 17.99,
              currency: 'USD',
              changedAt: DateTime(2026, 8, 10),
            ),
          ],
        );

        // Sub 2: Annual sub increased from $120 to $144 30 days ago (+$24/yr = +$2.00/mo)
        final sub2 = SubscriptionEntity(
          id: 'sub_2',
          userId: 'u1',
          serviceName: 'Amazon Prime',
          amount: 144.0,
          currency: 'USD',
          billingCycle: BillingCycle.yearly,
          nextBillingDate: DateTime(2026, 12, 1),
          priceHistory: [
            PriceChangeRecord(
              id: 'ph_2',
              previousAmount: 120.0,
              newAmount: 144.0,
              currency: 'USD',
              changedAt: DateTime(2026, 7, 21),
            ),
          ],
        );

        // Sub 3: Price decrease (discount) -> Should NOT be counted as a hike
        final sub3 = SubscriptionEntity(
          id: 'sub_3',
          userId: 'u1',
          serviceName: 'Spotify',
          amount: 5.99,
          currency: 'USD',
          billingCycle: BillingCycle.monthly,
          nextBillingDate: DateTime(2026, 9, 5),
          priceHistory: [
            PriceChangeRecord(
              id: 'ph_3',
              previousAmount: 10.99,
              newAmount: 5.99,
              currency: 'USD',
              changedAt: DateTime(2026, 8, 1),
            ),
          ],
        );

        // Sub 4: Hike older than lookback window (e.g. 200 days ago) -> Ignored
        final sub4 = SubscriptionEntity(
          id: 'sub_4',
          userId: 'u1',
          serviceName: 'iCloud',
          amount: 2.99,
          currency: 'USD',
          billingCycle: BillingCycle.monthly,
          nextBillingDate: DateTime(2026, 9, 10),
          priceHistory: [
            PriceChangeRecord(
              id: 'ph_4',
              previousAmount: 0.99,
              newAmount: 2.99,
              currency: 'USD',
              changedAt: DateTime(2025, 12, 1), // > 180 days ago
            ),
          ],
        );

        final metrics = PriceHikeDetector.evaluateRecentPriceHikes(
          subscriptions: [sub1, sub2, sub3, sub4],
          primaryCurrency: 'USD',
          converter: converter,
          lookback: const Duration(days: 180),
          now: now,
        );

        expect(metrics.hikedSubscriptionsCount, equals(2));
        expect(metrics.hikes.length, equals(2));

        // Sub 1: +$2.50/mo, Sub 2: +$2.00/mo => Total: $4.50/mo
        expect(metrics.totalMonthlyCreep, closeTo(4.50, 0.01));
        expect(metrics.totalAnnualCreep, closeTo(54.00, 0.1));

        // Sorted by largest monthly increase first (Netflix $2.50 > Prime $2.00)
        expect(metrics.hikes.first.subscription.serviceName, equals('Netflix'));
        expect(metrics.hikes.first.monthlyIncrease, closeTo(2.50, 0.01));
        expect(metrics.hikes.first.daysSinceChange, equals(10));

        expect(
          metrics.hikes[1].subscription.serviceName,
          equals('Amazon Prime'),
        );
        expect(metrics.hikes[1].monthlyIncrease, closeTo(2.00, 0.01));
        expect(metrics.hikes[1].daysSinceChange, equals(30));
      },
    );

    test('Handles empty subscriptions or no price changes gracefully', () {
      final metrics = PriceHikeDetector.evaluateRecentPriceHikes(
        subscriptions: [],
        primaryCurrency: 'USD',
        converter: converter,
      );

      expect(metrics.hasRecentHikes, isFalse);
      expect(metrics.totalMonthlyCreep, equals(0.0));
      expect(metrics.totalAnnualCreep, equals(0.0));
      expect(metrics.hikedSubscriptionsCount, equals(0));
    });
  });
}
