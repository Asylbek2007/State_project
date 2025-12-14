import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/admin_service.dart';

/// State for admin authentication.
class AdminAuthState {
  final bool isAdmin;
  final bool isLoading;
  final String? error;

  const AdminAuthState({
    this.isAdmin = false,
    this.isLoading = false,
    this.error,
  });

  AdminAuthState copyWith({
    bool? isAdmin,
    bool? isLoading,
    String? error,
  }) {
    return AdminAuthState(
      isAdmin: isAdmin ?? this.isAdmin,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Notifier for admin authentication.
class AdminAuthNotifier extends StateNotifier<AdminAuthState> {
  final AdminService adminService;

  AdminAuthNotifier(this.adminService) : super(const AdminAuthState()) {
    // Не проверяем статус автоматически при создании
    // Проверка будет выполняться явно при необходимости
  }

  Future<void> _checkAdminStatus() async {
    final isAdmin = await adminService.isAdmin();
    state = state.copyWith(isAdmin: isAdmin);
  }
  
  /// Check admin status explicitly (used in ProfilePage).
  Future<void> checkAdminStatus() async {
    await _checkAdminStatus();
  }
  
  /// Force reset state (for login page).
  void forceReset() {
    state = const AdminAuthState(isAdmin: false, isLoading: false, error: null);
  }

  /// Authenticate as admin.
  Future<void> login(String password) async {
    // Сначала сбросить предыдущее состояние
    state = state.copyWith(isLoading: true, error: null, isAdmin: false);

    try {
      final success = await adminService.authenticateAdmin(password);
      
      if (success) {
        // Успешная авторизация
        state = state.copyWith(isLoading: false, isAdmin: true, error: null);
      } else {
        // Неверный пароль
        state = state.copyWith(
          isLoading: false,
          isAdmin: false,
          error: 'Неверный пароль администратора',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isAdmin: false,
        error: e.toString(),
      );
    }
  }

  /// Logout from admin.
  Future<void> logout() async {
    try {
      // Сначала очистить хранилище
      await adminService.revokeAdmin();
    } catch (e) {
      print('Error revoking admin: $e');
    }
    // Полностью сбросить состояние - важно делать это после очистки хранилища
    state = const AdminAuthState(isAdmin: false, isLoading: false, error: null);
  }

  /// Reset error state (for login page).
  void resetError() {
    if (state.error != null) {
      state = state.copyWith(error: null);
    }
  }
}

/// Provider for admin service.
final adminServiceProvider = Provider<AdminService>((ref) {
  return AdminService();
});

/// Provider for admin authentication.
final adminAuthProvider =
    StateNotifierProvider<AdminAuthNotifier, AdminAuthState>((ref) {
  final adminService = ref.watch(adminServiceProvider);
  return AdminAuthNotifier(adminService);
});

