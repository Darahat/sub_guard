import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/insight_entity.dart';
import '../repositories/insight_repository.dart';

class GetTopSubscriptionsUseCase {
  final InsightRepository repository;

  GetTopSubscriptionsUseCase(this.repository);

  Future<Either<Failure, List<TopSubscription>>> call({int limit = 5}) {
    return repository.getTopSubscriptions(limit: limit);
  }
}
