import 'package:donation_app/core/errors/failures.dart';
import 'package:donation_app/core/services/google_sheets_service.dart';
import 'package:donation_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:donation_app/features/registration/domain/entities/user.dart';
import 'package:donation_app/features/registration/data/models/user_model.dart';

/// Implementation of [AuthRepository] using Google Sheets.
class AuthRepositoryImpl implements AuthRepository {
  final GoogleSheetsService sheetsService;

  const AuthRepositoryImpl(this.sheetsService);

  @override
  Future<User> loginUser(
    String fullName,
    String surname,
    String studyGroup,
  ) async {
    try {
      // Read Users sheet
      final data = await sheetsService.readSheet('Users');

      if (data.isEmpty || data.length < 2) {
        // No users found (only header row or empty)
        throw const AuthFailure('Пользователь не найден. Пожалуйста, зарегистрируйтесь.');
      }

      // Skip header row (index 0)
      // Sheet structure: Full Name | Surname | Study Group | Registration Date
      for (int i = 1; i < data.length; i++) {
        final row = data[i];
        if (row.length < 3) continue;

        final sheetFullName = row[0].toString().trim();
        final sheetSurname = row[1].toString().trim();
        final sheetStudyGroup = row[2].toString().trim();

        // Case-insensitive comparison
        if (sheetFullName.toLowerCase() == fullName.toLowerCase() &&
            sheetSurname.toLowerCase() == surname.toLowerCase() &&
            sheetStudyGroup.toLowerCase() == studyGroup.toLowerCase()) {
          // User found - create User entity
          final registrationDate = row.length > 3
              ? DateTime.tryParse(row[3].toString()) ?? DateTime.now()
              : DateTime.now();

          final user = UserModel(
            fullName: sheetFullName,
            surname: sheetSurname,
            studyGroup: sheetStudyGroup,
            registrationDate: registrationDate,
          );

          return user;
        }
      }

      // User not found
      throw const AuthFailure('Неверные данные. Проверьте имя, фамилию и группу.');
    } on Failure {
      rethrow;
    } catch (e) {
      throw SheetsFailure('Ошибка входа: ${e.toString()}');
    }
  }
}

