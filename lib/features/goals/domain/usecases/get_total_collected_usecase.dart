import '../repositories/goals_repository.dart';

/// Use case for getting total amount collected.
class GetTotalCollectedUseCase {
  final GoalsRepository repository;

  const GetTotalCollectedUseCase(this.repository);

  /// Execute - get total collected amount.
  Future<double> call() async {
    return await repository.getTotalCollected();
  }
}

