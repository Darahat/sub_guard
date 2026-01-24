import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/insight_entity.dart';
import '../repositories/insight_repository.dart';

class GetCategoryBreakdownUseCase {
  final InsightRepository repository;

  GetCategoryBreakdownUseCase(this.repository);

  Future<Either<Failure, List<CategorySpending>>> call({
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return repository.getCategoryBreakdown(
      startDate: startDate,
      endDate: endDate,
    );
  }
}
