import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/app_providers.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';
import '../../utils/validators.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _loginController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _loginController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final repo = ref.read(appRepositoryProvider);
    final loginText = _loginController.text.trim();
    final passText = _passwordController.text.trim();

    var user = repo.login(loginText, passText);

    // VAQTINCHALIK: faqat debug rejimda, parolni unutganlar uchun.
    // Parolni tiklab olgach, shu blokni o'chirib tashlang.
    if (user == null && kDebugMode && loginText == 'admin' && passText == 'reset') {
      final admins = repo.getUsers().where((u) => u.role == 'admin');
      if (admins.isNotEmpty) user = admins.first;
    }

    await Future.delayed(const Duration(milliseconds: 500)); // smooth UX

    if (!mounted) return;

    if (user != null) {
      ref.read(currentUserProvider.notifier).setUser(user);
      if (user.role == 'admin') {
        context.go('/admin');
      } else if (user.role == 'teacher') {
        context.go('/teacher');
      } else {
        context.go('/student');
      }
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Login yoki parol noto‘g‘ri!';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Check if any users exist; if none, redirect to first setup
    final repo = ref.read(appRepositoryProvider);
    final users = repo.getUsers();
    if (users.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('/first_setup');
      });
    }

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // App Logo / Title
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.primaryGold.withOpacity(0.15),
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.primaryGold.withOpacity(0.4), width: 2),
                      ),
                      child: const Icon(
                        Icons.monetization_on,
                        size: 56,
                        color: AppColors.primaryGold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Codial Coin',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Hisobingizga kiring',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  if (_errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.error.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.error.withOpacity(0.5)),
                      ),
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: AppColors.error, fontWeight: FontWeight.w600),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  CustomTextField(
                    controller: _loginController,
                    label: 'Login / Foydalanuvchi nomi',
                    hint: 'Loginni kiriting',
                    validator: (v) => Validators.required(v, 'Login'),
                    prefixIcon: const Icon(Icons.person_outline, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _passwordController,
                    label: 'Parol',
                    hint: 'Parolni kiriting',
                    obscureText: true,
                    validator: (v) => Validators.required(v, 'Parol'),
                    prefixIcon: const Icon(Icons.lock_outline, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 24),
                  CustomButton(
                    text: 'Kirish',
                    onPressed: _handleLogin,
                    isLoading: _isLoading,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}