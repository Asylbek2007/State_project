import '../repositories/admin_repository.dart';
import '../../../../core/errors/failures.dart';

/// Use case for creating a new fundraising goal.
class CreateGoalUseCase {
  final AdminRepository repository;

  const CreateGoalUseCase(this.repository);

  /// Execute - create a new goal.
  /// 
  /// Throws [ValidationFailure] if validation fails.
  /// Throws [SheetsFailure] if Google Sheets operation fails.
  Future<void> call({
    required String name,
    required double targetAmount,
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
    if (description.trim().isEmpty) {
      throw const ValidationFailure('Описание не может быть пустым');
    }
    if (deadline.isBefore(DateTime.now())) {
      throw const ValidationFailure('Дедлайн не может быть в прошлом');
    }

    // Call repository
    await repository.createGoal(
      name: name.trim(),
      targetAmount: targetAmount,
      deadline: deadline,
      description: description.trim(),
    );
  }
}

