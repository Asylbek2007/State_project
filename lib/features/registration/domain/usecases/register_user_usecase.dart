import 'package:donation_app/core/errors/failures.dart';
import '../entities/user.dart';
import '../repositories/registration_repository.dart';

/// Use case for registering a new user.
///
/// Validates input and delegates to repository.
class RegisterUserUseCase {
  final RegistrationRepository repository;

  const RegisterUserUseCase(this.repository);

  /// Execute the registration process.
  ///
  /// Throws [ValidationFailure] if inputs are invalid.
  /// Throws [SheetsFailure] if Google Sheets operation fails.
  Future<User> call(String fullName, String surname, String studyGroup) async {
    // Validate inputs
    final trimmedName = fullName.trim();
    final trimmedSurname = surname.trim();
    final trimmedGroup = studyGroup.trim();

    if (trimmedName.isEmpty) {
      throw const ValidationFailure('Имя не может быть пустым');
    }

    if (trimmedSurname.isEmpty) {
      throw const ValidationFailure('Фамилия не может быть пустой');
    }

    if (trimmedGroup.isEmpty) {
      throw const ValidationFailure('Группа не может быть пустой');
    }

    if (trimmedName.length < 2) {
      throw const ValidationFailure('Имя должно содержать минимум 2 символа');
    }

    if (trimmedSurname.length < 2) {
      throw const ValidationFailure('Фамилия должна содержать минимум 2 символа');
    }

    // Delegate to repository
    return await repository.registerUser(trimmedName, trimmedSurname, trimmedGroup);
  }
}

