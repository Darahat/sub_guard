import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/insight_entity.dart';
import '../repositories/insight_repository.dart';

class GetSpendingTrendsUseCase {
  final InsightRepository repository;

  GetSpendingTrendsUseCase(this.repository);

  Future<Either<Failure, List<SpendingDataPoint>>> call({
    required DateTime startDate,
    required DateTime endDate,
  }) {
    return repository.getSpendingTrends(startDate: startDate, endDate: endDate);
  }
}
