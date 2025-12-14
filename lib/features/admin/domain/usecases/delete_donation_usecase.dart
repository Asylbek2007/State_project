import '../repositories/admin_repository.dart';
import '../../../../core/errors/failures.dart';

/// Use case for deleting a donation.
class DeleteDonationUseCase {
  final AdminRepository repository;

  const DeleteDonationUseCase(this.repository);

  /// Execute - delete a donation by fullName and date.
  /// 
  /// Throws [ValidationFailure] if parameters are invalid.
  /// Throws [SheetsFailure] if Google Sheets operation fails.
  Future<void> call({
    required String fullName,
    required DateTime date,
  }) async {
    if (fullName.trim().isEmpty) {
      throw const ValidationFailure('Имя не может быть пустым');
    }

    await repository.deleteDonation(
      fullName: fullName.trim(),
      date: date,
    );
  }
}

