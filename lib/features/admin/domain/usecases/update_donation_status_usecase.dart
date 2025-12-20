import '../repositories/admin_repository.dart';
import '../../../../core/errors/failures.dart';

/// Use case for updating donation payment status.
class UpdateDonationStatusUseCase {
  final AdminRepository repository;

  const UpdateDonationStatusUseCase(this.repository);

  /// Execute - update donation payment status.
  /// 
  /// Throws [ValidationFailure] if parameters are invalid.
  /// Throws [SheetsFailure] if Google Sheets operation fails.
  Future<void> call({
    required String fullName,
    required DateTime date,
    required String status, // 'pending', 'confirmed', 'rejected'
  }) async {
    if (fullName.trim().isEmpty) {
      throw const ValidationFailure('Имя не может быть пустым');
    }

    final validStatuses = ['pending', 'confirmed', 'rejected'];
    if (!validStatuses.contains(status)) {
      throw ValidationFailure('Неверный статус: $status');
    }

    await repository.updateDonationPaymentStatus(
      fullName: fullName.trim(),
      date: date,
      status: status,
    );
  }
}

