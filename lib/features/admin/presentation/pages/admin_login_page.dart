import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/admin_provider.dart';
import 'admin_dashboard_page.dart';

/// Admin login page with password authentication.
class AdminLoginPage extends ConsumerStatefulWidget {
  const AdminLoginPage({super.key});

  @override
  ConsumerState<AdminLoginPage> createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends ConsumerState<AdminLoginPage> {
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    // При открытии страницы входа - полностью сбросить состояние
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Очистить поле пароля
      _passwordController.clear();
      // Принудительно сбросить состояние (на случай если админ был авторизован)
      ref.read(adminAuthProvider.notifier).forceReset();
    });
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (_formKey.currentState?.validate() ?? false) {
      await ref.read(adminAuthProvider.notifier).login(_passwordController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminAuthProvider);

    // Navigate to dashboard when authenticated
    ref.listen<AdminAuthState>(adminAuthProvider, (previous, next) {
      // Проверяем, что админ успешно авторизовался
      if (next.isAdmin && !next.isLoading && (previous?.isAdmin ?? false) == false) {
        // Очистить поле пароля перед переходом
        _passwordController.clear();
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const AdminDashboardPage()),
          );
        }
      }
    });

    return Scaffold(
      backgroundColor: AppTheme.backgroundMilkWhite,
      appBar: AppBar(
        title: const Text('Вход администратора'),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppTheme.spacing24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Admin icon
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppTheme.primarySkyBlue.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.admin_panel_settings,
                    size: 50,
                    color: AppTheme.primarySkyBlue,
                  ),
                ),
                const SizedBox(height: AppTheme.spacing32),

                // Title
                const Text(
                  'Панель администратора',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppTheme.spacing8),
                
                Text(
                  'Введите пароль для доступа',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: AppTheme.spacing40),

                // Error message
                if (state.error != null)
                  Container(
                    padding: const EdgeInsets.all(AppTheme.spacing12),
                    margin: const EdgeInsets.only(bottom: AppTheme.spacing20),
                    decoration: BoxDecoration(
                      color: AppTheme.errorRed.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                      border: Border.all(
                        color: AppTheme.errorRed.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: AppTheme.errorRed,
                        ),
                        const SizedBox(width: AppTheme.spacing12),
                        Expanded(
                          child: Text(
                            state.error!,
                            style: const TextStyle(color: AppTheme.errorRed),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Password form
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        enabled: !state.isLoading,
                        decoration: InputDecoration(
                          labelText: 'Пароль администратора',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Введите пароль';
                          }
                          return null;
                        },
                        onFieldSubmitted: (_) => _handleLogin(),
                      ),
                      const SizedBox(height: AppTheme.spacing24),
                      
                      // Login button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: state.isLoading ? null : _handleLogin,
                          child: state.isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text('Войти'),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppTheme.spacing32),

                // Info
                Container(
                  padding: const EdgeInsets.all(AppTheme.spacing16),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.amber.shade700,
                        size: 20,
                      ),
                      const SizedBox(width: AppTheme.spacing12),
                      Expanded(
                        child: Text(
                          'Доступ к панели администратора предоставляется только авторизованным сотрудникам',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.amber.shade900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

