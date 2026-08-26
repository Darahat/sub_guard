import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/services/csv_service.dart';
import '../entities/subscription_entity.dart';

/// UseCase to export all subscriptions as an RFC 4180 CSV file and trigger sharing
class ExportSubscriptionsCsvUseCase {
  final CsvService csvService;

  ExportSubscriptionsCsvUseCase(this.csvService);

  Future<Either<Failure, String?>> execute(
    List<SubscriptionEntity> subscriptions, {
    ExportFormat format = ExportFormat.excel,
  }) async {
    try {
      if (subscriptions.isEmpty) {
        return const Left(
          ValidationFailure('No subscriptions available to export.'),
        );
      }
      final filePath = await csvService.exportAndShare(
        subscriptions,
        format: format,
      );
      return Right(filePath);
    } catch (e) {
      return Left(ServerFailure('Failed to export data: ${e.toString()}'));
    }
  }
}
