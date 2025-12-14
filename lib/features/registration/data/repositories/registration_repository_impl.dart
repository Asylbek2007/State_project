import 'package:donation_app/core/errors/failures.dart';
import 'package:donation_app/core/services/google_sheets_service.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/registration_repository.dart';
import '../models/user_model.dart';

/// Implementation of [RegistrationRepository] using Google Sheets.
class RegistrationRepositoryImpl implements RegistrationRepository {
  final GoogleSheetsService sheetsService;

  const RegistrationRepositoryImpl(this.sheetsService);

  @override
  Future<User> registerUser(String fullName, String surname, String studyGroup) async {
    try {
      final now = DateTime.now();
      final userModel = UserModel(
        fullName: fullName,
        surname: surname,
        studyGroup: studyGroup,
        registrationDate: now,
      );

      // Append to "Users" sheet
      // Sheet structure: Full Name | Surname | Study Group | Registration Date
      await sheetsService.appendRow(
        'Users',
        userModel.toSheetRow(),
      );

      return userModel;
    } on SheetsFailure {
      rethrow;
    } catch (e) {
      throw SheetsFailure('Ошибка регистрации: ${e.toString()}');
    }
  }
}

