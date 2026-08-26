import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/services/csv_service.dart';
import '../entities/subscription_entity.dart';
import '../repositories/subscription_repository.dart';

/// UseCase to pick an Excel/CSV file, deduplicate subscriptions, and batch insert into repository while respecting Pro quotas
class ImportSubscriptionsCsvUseCase {
  final CsvService csvService;
  final SubscriptionRepository repository;

  ImportSubscriptionsCsvUseCase({
    required this.csvService,
    required this.repository,
  });

  Future<Either<Failure, CsvImportResult?>> execute({
    required String userId,
    bool isPro = false,
  }) async {
    try {
      final parseResult = await csvService.pickAndParseCsv(userId: userId);
      if (parseResult == null) {
        // User cancelled file picking
        return const Right(null);
      }

      // 1. Fetch existing subscriptions for deduplication
      final existingResult = await repository.getAllSubscriptions();
      final existingSubs = existingResult.getOrElse(() => []);

      int successfullyAdded = 0;
      int updatedCount = 0;
      int skippedDueToLimit = 0;
      final errors = List<String>.from(parseResult.errorMessages);

      // Count current active subscriptions
      int currentActiveCount = existingSubs
          .where((s) => s.status == SubscriptionStatus.active)
          .length;

      for (final candidate in parseResult.subscriptions) {
        // A. Check for existing subscription (Deduplication)
        final existingIndex = existingSubs.indexWhere(
          (s) =>
              s.serviceName.trim().toLowerCase() ==
                  candidate.serviceName.trim().toLowerCase() &&
              s.currency.toUpperCase() == candidate.currency.toUpperCase(),
        );

        if (existingIndex != -1) {
          // Update existing subscription rather than creating a duplicate
          final existing = existingSubs[existingIndex];
          final updated = existing.copyWith(
            amount: candidate.amount,
            billingCycle: candidate.billingCycle,
            nextBillingDate: candidate.nextBillingDate,
            category: candidate.category,
            description: candidate.description ?? existing.description,
            websiteUrl: candidate.websiteUrl ?? existing.websiteUrl,
          );
          await repository.updateSubscription(updated);
          updatedCount++;
          continue;
        }

        // B. Enforce Free Plan Limit (Max 5 active subscriptions)
        if (!isPro &&
            candidate.status == SubscriptionStatus.active &&
            currentActiveCount >= 5) {
          skippedDueToLimit++;
          continue;
        }

        // C. Insert new unique subscription
        final addResult = await repository.addSubscription(candidate);
        if (addResult.isRight()) {
          successfullyAdded++;
          if (candidate.status == SubscriptionStatus.active) {
            currentActiveCount++;
          }
        }
      }

      if (skippedDueToLimit > 0) {
        errors.add(
          '$skippedDueToLimit subscriptions were skipped due to the Free plan limit (up to 5 active). Upgrade to SubGuard Pro to import all without limits.',
        );
      }

      final finalResult = CsvImportResult(
        subscriptions: parseResult.subscriptions,
        totalRowsFound: parseResult.totalRowsFound,
        validCount: successfullyAdded + updatedCount,
        skippedCount: parseResult.skippedCount + skippedDueToLimit,
        errorMessages: errors,
      );

      return Right(finalResult);
    } catch (e) {
      return Left(ServerFailure('Failed to import file: ${e.toString()}'));
    }
  }
}
