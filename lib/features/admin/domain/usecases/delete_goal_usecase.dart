import '../repositories/admin_repository.dart';
import '../../../../core/errors/failures.dart';

/// Use case for deleting a fundraising goal.
class DeleteGoalUseCase {
  final AdminRepository repository;

  const DeleteGoalUseCase(this.repository);

  /// Execute - delete a goal by name.
  /// 
  /// Throws [ValidationFailure] if goal name is empty.
  /// Throws [SheetsFailure] if Google Sheets operation fails.
  Future<void> call(String goalName) async {
    if (goalName.trim().isEmpty) {
      throw const ValidationFailure('Название цели не может быть пустым');
    }

    await repository.deleteGoal(goalName.trim());
  }
}

