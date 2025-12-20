import 'dart:convert';
import 'package:donation_app/core/config/api_config.dart';
import 'package:donation_app/core/errors/failures.dart';
import 'package:donation_app/core/services/google_sheets_service.dart';
import 'package:http/http.dart' as http;
import '../../domain/entities/user.dart';
import '../../domain/repositories/registration_repository.dart';
import '../models/user_model.dart';

/// Implementation of [RegistrationRepository] using backend API.
class RegistrationRepositoryImpl implements RegistrationRepository {
  final GoogleSheetsService sheetsService;

  const RegistrationRepositoryImpl(this.sheetsService);
  
  String get _baseUrl => ApiConfig.authBaseUrl;

  @override
  Future<User> registerUser(String email, String password, String fullName, String surname, String studyGroup) async {
    try {
      // Send registration request to backend
      final response = await http.post(
        Uri.parse('$_baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'fullName': fullName,
          'surname': surname,
          'studyGroup': studyGroup,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final userData = data['user'] as Map<String, dynamic>;
        
        final now = DateTime.parse(userData['registeredAt'] as String);
        final userModel = UserModel(
          email: email,
          fullName: fullName,
          surname: surname,
          studyGroup: studyGroup,
          registrationDate: now,
        );

        return userModel;
      } else {
        final errorData = jsonDecode(response.body) as Map<String, dynamic>;
        final errorMessage = errorData['error'] as String? ?? 'Ошибка регистрации';
        throw SheetsFailure(errorMessage);
      }
    } on SheetsFailure {
      rethrow;
    } catch (e) {
      throw SheetsFailure('Ошибка регистрации: ${e.toString()}');
    }
  }
}

