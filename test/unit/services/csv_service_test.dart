import 'package:flutter_test/flutter_test.dart';
import 'package:sub_guard/core/services/csv_service.dart';
import 'package:sub_guard/features/subscriptions/domain/entities/subscription_entity.dart';

void main() {
  late CsvService csvService;

  setUp(() {
    csvService = CsvService();
  });

  group('CsvService - Export', () {
    test('should generate valid RFC 4180 CSV string with headers and escaped commas', () {
      final subscriptions = [
        SubscriptionEntity(
          id: 'sub-1',
          userId: 'user-123',
          serviceName: 'Netflix, 4K Plan',
          amount: 19.99,
          currency: 'USD',
          billingCycle: BillingCycle.monthly,
          nextBillingDate: DateTime(2026, 9, 15),
          category: 'Entertainment',
          status: SubscriptionStatus.active,
          description: 'Includes family sharing, Ultra HD',
          websiteUrl: 'https://netflix.com',
          startDate: DateTime(2025, 1, 1),
          createdAt: DateTime(2026, 1, 1),
        ),
        SubscriptionEntity(
          id: 'sub-2',
          userId: 'user-123',
          serviceName: 'Spotify',
          amount: 10.99,
          currency: 'EUR',
          billingCycle: BillingCycle.monthly,
          nextBillingDate: DateTime(2026, 9, 20),
          category: 'Music',
          status: SubscriptionStatus.active,
        ),
      ];

      final csvString = csvService.generateCsvString(subscriptions);

      expect(csvString, contains('Service Name'));
      expect(csvString, contains('"Netflix, 4K Plan"'));
      expect(csvString, contains('19.99'));
      expect(csvString, contains('USD'));
      expect(csvString, contains('Spotify'));
      expect(csvString, contains('10.99'));
      expect(csvString, contains('EUR'));
    });
  });

  group('CsvService - Import & Parse', () {
    test('should correctly parse standard CSV content into SubscriptionEntity list', () {
      const csvData = '''ID,Service Name,Amount,Currency,Billing Cycle,Next Billing Date,Category,Status,Description,Website URL,Start Date,Created At
sub-1,Netflix,15.49,USD,monthly,2026-09-01,Entertainment,active,Movie streaming,https://netflix.com,2025-01-01,2026-01-01T00:00:00.000
sub-2,Gym Membership,50.00,USD,monthly,2026-09-10,Fitness,active,Downtown gym,,2025-05-01,2026-01-01T00:00:00.000''';

      final result = csvService.parseCsvString(csvData, userId: 'user-123');

      expect(result.validCount, equals(2));
      expect(result.skippedCount, equals(0));
      expect(result.subscriptions.length, equals(2));

      final netflix = result.subscriptions.first;
      expect(netflix.serviceName, equals('Netflix'));
      expect(netflix.amount, equals(15.49));
      expect(netflix.currency, equals('USD'));
      expect(netflix.billingCycle, equals(BillingCycle.monthly));
      expect(netflix.category, equals('Entertainment'));
      expect(netflix.status, equals(SubscriptionStatus.active));
      expect(netflix.nextBillingDate.year, equals(2026));
      expect(netflix.nextBillingDate.month, equals(9));
      expect(netflix.nextBillingDate.day, equals(1));
    });

    test('should sanitize currency symbols and handle mixed date formats', () {
      const csvData = '''Service,Price,Currency,Frequency,Renewal Date
Disney Plus,\$13.99,USD,monthly,09/25/2026
Amazon Prime,€139.00,EUR,yearly,2026-11-15
Adobe Creative Cloud,£54.99,GBP,monthly,15-10-2026''';

      final result = csvService.parseCsvString(csvData, userId: 'user-123');

      expect(result.validCount, equals(3));
      expect(result.subscriptions[0].serviceName, equals('Disney Plus'));
      expect(result.subscriptions[0].amount, equals(13.99));
      expect(result.subscriptions[0].nextBillingDate.month, equals(9));
      expect(result.subscriptions[0].nextBillingDate.day, equals(25));

      expect(result.subscriptions[1].serviceName, equals('Amazon Prime'));
      expect(result.subscriptions[1].amount, equals(139.00));
      expect(result.subscriptions[1].billingCycle, equals(BillingCycle.yearly));

      expect(result.subscriptions[2].serviceName, equals('Adobe Creative Cloud'));
      expect(result.subscriptions[2].amount, equals(54.99));
    });

    test('should gracefully handle corrupt or empty rows', () {
      const csvData = '''Service Name,Amount,Next Billing Date
Valid Sub,10.00,2026-10-01
,20.00,2026-10-01
Corrupt Amount,InvalidPrice,2026-10-01''';

      final result = csvService.parseCsvString(csvData, userId: 'user-123');

      expect(result.validCount, equals(1));
      expect(result.skippedCount, equals(2));
      expect(result.subscriptions.first.serviceName, equals('Valid Sub'));
      expect(result.errorMessages.length, equals(2));
    });

    test('should return empty result for empty string', () {
      final result = csvService.parseCsvString('', userId: 'user-123');
      expect(result.validCount, equals(0));
      expect(result.hasErrors, isTrue);
    });
  });
}
