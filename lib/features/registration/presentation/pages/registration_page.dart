import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/token_storage_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/pages/login_page.dart';
import '../../../home/presentation/pages/home_page.dart';
import '../../domain/entities/user.dart';
import '../providers/registration_provider.dart';
import '../widgets/registration_form.dart';

/// Registration page for new users.
///
/// Collects full name and study group, then saves to Google Sheets.
class RegistrationPage extends ConsumerWidget {
  const RegistrationPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(registrationProvider);

    // Show success dialog and navigate when registration succeeds
    ref.listen<RegistrationState>(registrationProvider, (previous, next) {
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
                  Icons.volunteer_activism,
                  size: 80,
                  color: Colors.blue,
                ),
                const SizedBox(height: 24),
                // Title
                Text(
                  'Добро пожаловать!',
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                // Subtitle
                Text(
                  'Зарегистрируйтесь, чтобы начать помогать',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).textTheme.bodySmall?.color,
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
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.red.shade700),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            state.error!,
                            style: TextStyle(color: Colors.red.shade700),
                          ),
                        ),
                      ],
                    ),
                  ),
                // Registration Form
                RegistrationForm(
                  isLoading: state.isLoading,
                  onSubmit: (email, password, fullName, surname, studyGroup) {
                    ref
                        .read(registrationProvider.notifier)
                        .registerUser(email, password, fullName, surname, studyGroup);
                  },
                ),
                const SizedBox(height: 24),
                // Link to login
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Уже есть аккаунт? ',
                      style: TextStyle(color: AppTheme.textSecondary),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (_) => const LoginPage(),
                          ),
                        );
                      },
                      child: const Text('Войти'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Info text
                const Text(
                  'Регистрация займет всего несколько секунд.\nВаши данные будут использованы только для идентификации пожертвований.',
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

  Future<void> _showSuccessDialog(BuildContext context, User user) async {
    // Generate and save token
    final tokenService = TokenStorageService();
    
    // Generate user ID (using email hash for uniqueness)
    final userId = '${user.email.hashCode}_${user.registrationDate.millisecondsSinceEpoch}';
    
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

