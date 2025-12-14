import 'package:flutter/material.dart';

/// Form widget for user login.
class LoginForm extends StatefulWidget {
  final void Function(String fullName, String surname, String studyGroup) onSubmit;
  final bool isLoading;

  const LoginForm({
    super.key,
    required this.onSubmit,
    required this.isLoading,
  });

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _surnameController = TextEditingController();
  final _studyGroupController = TextEditingController();

  @override
  void dispose() {
    _fullNameController.dispose();
    _surnameController.dispose();
    _studyGroupController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      widget.onSubmit(
        _fullNameController.text,
        _surnameController.text,
        _studyGroupController.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _fullNameController,
            enabled: !widget.isLoading,
            decoration: InputDecoration(
              labelText: 'Имя',
              hintText: 'Введите ваше имя',
              prefixIcon: const Icon(Icons.person),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Пожалуйста, введите ваше имя';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _surnameController,
            enabled: !widget.isLoading,
            decoration: InputDecoration(
              labelText: 'Фамилия',
              hintText: 'Введите вашу фамилию',
              prefixIcon: const Icon(Icons.badge),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Пожалуйста, введите вашу фамилию';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _studyGroupController,
            enabled: !widget.isLoading,
            decoration: InputDecoration(
              labelText: 'Группа',
              hintText: 'Введите вашу учебную группу',
              prefixIcon: const Icon(Icons.school),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Пожалуйста, введите вашу группу';
              }
              return null;
            },
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: widget.isLoading ? null : _handleSubmit,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: widget.isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    'Войти',
                    style: TextStyle(fontSize: 16),
                  ),
          ),
        ],
      ),
    );
  }
}

