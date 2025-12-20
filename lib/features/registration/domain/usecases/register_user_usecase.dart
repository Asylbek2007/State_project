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
  Future<User> call(String email, String password, String fullName, String surname, String studyGroup) async {
    // Validate inputs
    final trimmedEmail = email.trim().toLowerCase();
    final trimmedName = fullName.trim();
    final trimmedSurname = surname.trim();
    final trimmedGroup = studyGroup.trim();

    if (trimmedEmail.isEmpty) {
      throw const ValidationFailure('Email не может быть пустым');
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(trimmedEmail)) {
      throw const ValidationFailure('Введите корректный email адрес');
    }

    if (password.isEmpty) {
      throw const ValidationFailure('Пароль не может быть пустым');
    }

    if (password.length < 6) {
      throw const ValidationFailure('Пароль должен содержать минимум 6 символов');
    }

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
    return await repository.registerUser(trimmedEmail, password, trimmedName, trimmedSurname, trimmedGroup);
  }
}

