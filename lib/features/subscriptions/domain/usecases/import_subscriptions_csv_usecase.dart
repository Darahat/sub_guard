import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/services/csv_service.dart';
import '../repositories/subscription_repository.dart';

/// UseCase to pick a CSV file, parse subscriptions, and batch insert into repository
class ImportSubscriptionsCsvUseCase {
  final CsvService csvService;
  final SubscriptionRepository repository;

  ImportSubscriptionsCsvUseCase({
    required this.csvService,
    required this.repository,
  });

  Future<Either<Failure, CsvImportResult?>> execute({
    required String userId,
  }) async {
    try {
      final parseResult = await csvService.pickAndParseCsv(userId: userId);
      if (parseResult == null) {
        // User cancelled file picking
        return const Right(null);
      }

      // Batch insert valid subscriptions
      int successfullyAdded = 0;
      for (final sub in parseResult.subscriptions) {
        final result = await repository.addSubscription(sub);
        if (result.isRight()) {
          successfullyAdded++;
        }
      }

      final finalResult = CsvImportResult(
        subscriptions: parseResult.subscriptions,
        totalRowsFound: parseResult.totalRowsFound,
        validCount: successfullyAdded,
        skippedCount: parseResult.skippedCount + (parseResult.subscriptions.length - successfullyAdded),
        errorMessages: parseResult.errorMessages,
      );

      return Right(finalResult);
    } catch (e) {
      return Left(ServerFailure('Failed to import CSV: ${e.toString()}'));
    }
  }
}
