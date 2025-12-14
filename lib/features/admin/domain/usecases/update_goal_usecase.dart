import '../repositories/admin_repository.dart';
import '../../../../core/errors/failures.dart';

/// Use case for updating an existing fundraising goal.
class UpdateGoalUseCase {
  final AdminRepository repository;

  const UpdateGoalUseCase(this.repository);

  /// Execute - update an existing goal.
  /// 
  /// Throws [ValidationFailure] if validation fails.
  /// Throws [SheetsFailure] if Google Sheets operation fails.
  Future<void> call({
    required String originalName,
    required String name,
    required double targetAmount,
    required double currentAmount,
    required DateTime deadline,
    required String description,
  }) async {
    // Validation
    if (name.trim().isEmpty) {
      throw const ValidationFailure('Название цели не может быть пустым');
    }
    if (targetAmount <= 0) {
      throw const ValidationFailure('Целевая сумма должна быть больше 0');
    }
    if (currentAmount < 0) {
      throw const ValidationFailure('Текущая сумма не может быть отрицательной');
    }
    if (description.trim().isEmpty) {
      throw const ValidationFailure('Описание не может быть пустым');
    }

    // Call repository
    await repository.updateGoal(
      originalName: originalName,
      name: name.trim(),
      targetAmount: targetAmount,
      currentAmount: currentAmount,
      deadline: deadline,
      description: description.trim(),
    );
  }
}

