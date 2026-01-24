import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/insight_entity.dart';
import '../repositories/insight_repository.dart';

class GetSubscriptionStatsUseCase {
  final InsightRepository repository;

  GetSubscriptionStatsUseCase(this.repository);

  Future<Either<Failure, SubscriptionStats>> call() {
    return repository.getSubscriptionStats();
  }
}
