import 'package:flutter_test/flutter_test.dart';
import 'package:sub_guard/features/subscriptions/domain/entities/contract_commitment.dart';

void main() {
  group('ContractCommitment Tests', () {
    test('Accurately computes calendar-date cancellation deadline', () {
      final contract = ContractCommitment(
        endDate: DateTime(2026, 12, 31),
        cancellationNoticeDays: 30,
        autoRenews: true,
      );

      // Dec 31 - 30 days = Dec 1
      expect(contract.cancellationDeadline, equals(DateTime(2026, 12, 1)));
    });

    test('Accurately handles leap-year February boundaries', () {
      // 2028 is a leap year (Feb 29 exists)
      final contractLeap1 = ContractCommitment(
        endDate: DateTime(2028, 3, 31),
        cancellationNoticeDays: 30,
        autoRenews: true,
      );
      // March 31 - 30 days in leap year = March 1
      expect(contractLeap1.cancellationDeadline, equals(DateTime(2028, 3, 1)));

      final contractLeap2 = ContractCommitment(
        endDate: DateTime(2028, 3, 1),
        cancellationNoticeDays: 1,
        autoRenews: true,
      );
      // March 1 - 1 day in leap year = Feb 29
      expect(contractLeap2.cancellationDeadline, equals(DateTime(2028, 2, 29)));
    });

    test('Evaluates risk status deterministically across boundaries', () {
      final contract = ContractCommitment(
        endDate: DateTime(2026, 12, 31),
        cancellationNoticeDays: 30, // Deadline = Dec 1, 2026
        autoRenews: true,
      );

      // 15 days before Dec 1 = Nov 16 -> SAFE
      expect(
        contract.evaluateRisk(DateTime(2026, 11, 16)),
        equals(ContractRiskStatus.safe),
      );

      // 14 days before Dec 1 = Nov 17 -> APPROACHING (upper boundary)
      expect(
        contract.evaluateRisk(DateTime(2026, 11, 17)),
        equals(ContractRiskStatus.approaching),
      );

      // 4 days before Dec 1 = Nov 27 -> APPROACHING (lower boundary)
      expect(
        contract.evaluateRisk(DateTime(2026, 11, 27)),
        equals(ContractRiskStatus.approaching),
      );

      // 3 days before Dec 1 = Nov 28 -> CRITICAL (upper boundary)
      expect(
        contract.evaluateRisk(DateTime(2026, 11, 28)),
        equals(ContractRiskStatus.critical),
      );

      // On Deadline Day Dec 1 = 0 days -> CRITICAL
      expect(
        contract.evaluateRisk(DateTime(2026, 12, 1)),
        equals(ContractRiskStatus.critical),
      );

      // After Deadline (Dec 2) but before Contract End (Dec 31) -> CANCELLATION_WINDOW_PASSED
      expect(
        contract.evaluateRisk(DateTime(2026, 12, 2)),
        equals(ContractRiskStatus.cancellationWindowPassed),
      );

      // After Contract End (Jan 1, 2027) -> EXPIRED
      expect(
        contract.evaluateRisk(DateTime(2027, 1, 1)),
        equals(ContractRiskStatus.expired),
      );
    });

    test('Does not warn if autoRenews is false', () {
      final contract = ContractCommitment(
        endDate: DateTime(2026, 12, 31),
        cancellationNoticeDays: 30,
        autoRenews: false,
      );

      // Even within the critical window, non-auto-renewing contracts are safe
      expect(
        contract.evaluateRisk(DateTime(2026, 11, 30)),
        equals(ContractRiskStatus.noContract),
      );
    });
  });
}
