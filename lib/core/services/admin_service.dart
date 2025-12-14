import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Service for admin authentication and permissions.
///
/// Admin is identified by a special admin flag in token.
///
/// ADMIN ACCESS SETUP:
/// Option 1: Hardcoded admin user (for MVP)
/// Option 2: Admin flag in Google Sheets "Users" table
/// Option 3: Server-side admin validation via Cloud Function
///
/// Current: Simple hardcoded approach for MVP
/// Production: Move to server-side validation
class AdminService {
  static const String _adminFlagKey = 'is_admin';
  static const String _adminPasswordKey = 'admin_password';

  // ⚠️ WARNING: For production, validate admin via server!
  // This is a simple client-side check for MVP.
  // TODO: Replace with server-side admin validation for Play Market.
  static const String _hardcodedAdminPassword = 'admin2024';

  // List of admin emails/names (for MVP)
  // TODO: Move to server-side validation
  static const List<String> _adminUsers = [
    'admin@college.kz',
    'Администратор',
  ];

  final FlutterSecureStorage _secureStorage;

  AdminService()
      : _secureStorage = const FlutterSecureStorage(
          aOptions: AndroidOptions(
            encryptedSharedPreferences: true,
          ),
          iOptions: IOSOptions(
            accessibility: KeychainAccessibility.first_unlock,
          ),
        );

  /// Check if current user is admin.
  Future<bool> isAdmin() async {
    try {
      final flag = await _secureStorage.read(key: _adminFlagKey);
      return flag == 'true';
    } catch (e) {
      print('Admin check error: $e');
      return false;
    }
  }

  /// Authenticate as admin with password.
  ///
  /// ⚠️ PRODUCTION WARNING:
  /// This should be validated server-side!
  /// Current implementation is for MVP only.
  Future<bool> authenticateAdmin(String password) async {
    try {
      if (password == _hardcodedAdminPassword) {
        await _secureStorage.write(key: _adminFlagKey, value: 'true');
        await _secureStorage.write(key: _adminPasswordKey, value: password);
        return true;
      }
      return false;
    } catch (e) {
      print('Admin auth error: $e');
      return false;
    }
  }

  /// Check if user name is in admin list.
  bool isAdminUser(String userName) {
    return _adminUsers.any(
      (admin) => userName.toLowerCase().contains(admin.toLowerCase()),
    );
  }

  /// Revoke admin access (logout from admin).
  Future<void> revokeAdmin() async {
    try {
      // Удалить все ключи админа
      await _secureStorage.delete(key: _adminFlagKey);
      await _secureStorage.delete(key: _adminPasswordKey);
      
      // Дополнительная проверка - убедиться, что ключи удалены
      final flag = await _secureStorage.read(key: _adminFlagKey);
      if (flag != null) {
        // Если ключ все еще существует, попробовать удалить еще раз
        await _secureStorage.delete(key: _adminFlagKey);
      }
    } catch (e) {
      print('Error revoking admin: $e');
      // Не бросаем исключение, чтобы не блокировать выход
    }
  }

  /// Get stored admin password (for verification).
  Future<String?> getAdminPassword() async {
    try {
      return await _secureStorage.read(key: _adminPasswordKey);
    } catch (e) {
      print('Failed to get admin password: $e');
      return null;
    }
  }
}
