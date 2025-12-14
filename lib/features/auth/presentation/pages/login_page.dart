import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/token_storage_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../home/presentation/pages/home_page.dart';
import '../../../registration/presentation/pages/registration_page.dart';
import '../providers/auth_provider.dart';
import '../widgets/login_form.dart';

/// Login page for existing users.
///
/// Users enter their name, surname, and study group to login.
class LoginPage extends ConsumerWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(authProvider);

    // Show success dialog and navigate when login succeeds
    ref.listen<AuthState>(authProvider, (previous, next) {
      if (next.user != null && previous?.user == null) {
        _showSuccessDialog(context, next.user!);
      }
    });

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                // App Logo/Icon
                const Icon(
                  Icons.login,
                  size: 80,
                  color: AppTheme.primarySkyBlue,
                ),
                const SizedBox(height: 24),
                // Title
                const Text(
                  'Вход',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                // Subtitle
                const Text(
                  'Войдите, используя ваши данные',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppTheme.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                // Error message
                if (state.error != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: AppTheme.errorRed.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.errorRed.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: AppTheme.errorRed),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            state.error!,
                            style: const TextStyle(color: AppTheme.errorRed),
                          ),
                        ),
                      ],
                    ),
                  ),
                // Login Form
                LoginForm(
                  isLoading: state.isLoading,
                  onSubmit: (fullName, surname, studyGroup) {
                    ref
                        .read(authProvider.notifier)
                        .loginUser(fullName, surname, studyGroup);
                  },
                ),
                const SizedBox(height: 24),
                // Link to registration
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Нет аккаунта? ',
                      style: TextStyle(color: AppTheme.textSecondary),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (_) => const RegistrationPage(),
                          ),
                        );
                      },
                      child: const Text('Зарегистрироваться'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Info text
                const Text(
                  'Введите те же данные, которые вы использовали при регистрации.',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showSuccessDialog(BuildContext context, user) async {
    // Generate and save token
    final tokenService = TokenStorageService();
    
    // Generate user ID (using timestamp + name hash for uniqueness)
    final userId = '${user.registrationDate.millisecondsSinceEpoch}_${user.fullName.hashCode}';
    
    // Generate token
    final token = tokenService.generateToken(
      userId: userId,
      userName: user.fullName,
      userGroup: user.studyGroup,
    );
    
    // Save token and user data
    await tokenService.saveToken(
      token: token,
      userId: userId,
      userName: user.fullName,
      userGroup: user.studyGroup,
    );

    if (!context.mounted) return;

    // Сразу переходим на Home без диалога
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => HomePage(
          userName: user.fullName,
          userGroup: user.studyGroup,
          initialIndex: 1, // Start at Main tab
        ),
      ),
    );
  }
}

