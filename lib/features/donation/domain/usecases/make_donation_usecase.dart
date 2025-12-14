import 'package:donation_app/core/errors/failures.dart';
import '../entities/donation.dart';
import '../repositories/donation_repository.dart';

/// Use case for making a donation.
class MakeDonationUseCase {
  final DonationRepository repository;

  const MakeDonationUseCase(this.repository);

  /// Execute - make a donation with validation.
  Future<Donation> call({
    required String fullName,
    required String studyGroup,
    required double amount,
    String message = '',
    String? goalName,
  }) async {
    // Validate inputs
    final trimmedName = fullName.trim();
    final trimmedGroup = studyGroup.trim();
    final trimmedMessage = message.trim();
    final trimmedGoalName = goalName?.trim();

    if (trimmedName.isEmpty) {
      throw const ValidationFailure('Имя не может быть пустым');
    }

    if (trimmedGroup.isEmpty) {
      throw const ValidationFailure('Группа не может быть пустой');
    }

    if (amount <= 0) {
      throw const ValidationFailure('Сумма должна быть больше нуля');
    }

    if (amount > 1000000) {
      throw const ValidationFailure('Сумма не может превышать 1,000,000 ₸');
    }

    // Delegate to repository
    return await repository.makeDonation(
      fullName: trimmedName,
      studyGroup: trimmedGroup,
      amount: amount,
      message: trimmedMessage,
      goalName: trimmedGoalName?.isEmpty == true ? null : trimmedGoalName,
    );
  }
}
