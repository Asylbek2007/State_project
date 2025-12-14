import '../entities/goal.dart';
import '../repositories/goals_repository.dart';

/// Use case for fetching all fundraising goals.
class GetGoalsUseCase {
  final GoalsRepository repository;

  const GetGoalsUseCase(this.repository);

  /// Execute - get all goals from repository.
  Future<List<Goal>> call() async {
    final goals = await repository.getGoals();
    
    // Sort by deadline (closest first)
    goals.sort((a, b) => a.deadline.compareTo(b.deadline));
    
    return goals;
  }
}

