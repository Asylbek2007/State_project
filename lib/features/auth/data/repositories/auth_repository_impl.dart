import 'dart:convert';
import 'package:donation_app/core/config/api_config.dart';
import 'package:donation_app/core/errors/failures.dart';
import 'package:donation_app/core/services/google_sheets_service.dart';
import 'package:donation_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:donation_app/features/registration/domain/entities/user.dart';
import 'package:donation_app/features/registration/data/models/user_model.dart';
import 'package:http/http.dart' as http;

/// Implementation of [AuthRepository] using backend API.
class AuthRepositoryImpl implements AuthRepository {
  final GoogleSheetsService sheetsService;

  const AuthRepositoryImpl(this.sheetsService);
  
  String get _baseUrl => ApiConfig.authBaseUrl;

  @override
  Future<User> loginUser(
    String email,
    String password,
  ) async {
    try {
      // Send login request to backend
      final response = await http.post(
        Uri.parse('$_baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final userData = data['user'] as Map<String, dynamic>;
        
        final now = DateTime.parse(userData['registeredAt'] as String);
        final userModel = UserModel(
          email: email,
          fullName: userData['userName'] as String,
          surname: userData['surname'] as String,
          studyGroup: userData['userGroup'] as String,
          registrationDate: now,
        );

        return userModel;
      } else if (response.statusCode == 401) {
        final errorData = jsonDecode(response.body) as Map<String, dynamic>;
        final errorMessage = errorData['error'] as String? ?? 'Неверный email или пароль';
        throw AuthFailure(errorMessage);
      } else {
        final errorData = jsonDecode(response.body) as Map<String, dynamic>;
        final errorMessage = errorData['error'] as String? ?? 'Ошибка входа';
        throw AuthFailure(errorMessage);
      }
    } on AuthFailure {
      rethrow;
    } catch (e) {
      throw AuthFailure('Ошибка входа: ${e.toString()}');
    }
  }
}

