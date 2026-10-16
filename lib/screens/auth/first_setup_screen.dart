import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/app_providers.dart';
import '../../models/user.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';
import '../../utils/validators.dart';

class FirstSetupScreen extends ConsumerStatefulWidget {
  const FirstSetupScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<FirstSetupScreen> createState() => _FirstSetupScreenState();
}

class _FirstSetupScreenState extends ConsumerState<FirstSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _loginController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _loginController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _createAdmin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final repo = ref.read(appRepositoryProvider);
    final adminUser = User(
      id: 'admin_${DateTime.now().millisecondsSinceEpoch}',
      name: _nameController.text.trim(),
      login: _loginController.text.trim().toLowerCase(),
      password: _passwordController.text.trim(),
      role: 'admin',
      phone: _phoneController.text.trim(),
      coins: 1000,
    );

    await repo.registerUser(adminUser);
    ref.read(currentUserProvider.notifier).setUser(adminUser);
    ref.read(usersProvider.notifier).refresh();

    if (!mounted) return;
    context.go('/admin');
  }

  @override
  Widget build(BuildContext context) {
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
                  const Icon(
                    Icons.admin_panel_settings,
                    size: 64,
                    color: AppColors.primaryGold,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Birinchi administratorni yaratish',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Codial Coin tizimini boshqarishni boshlash uchun admin hisobini sozlang.',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  CustomTextField(
                    controller: _nameController,
                    label: 'To‘liq ism',
                    hint: 'Admin ismi',
                    validator: (v) => Validators.required(v, 'Ism'),
                    prefixIcon: const Icon(Icons.badge_outlined, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _loginController,
                    label: 'Login / Foydalanuvchi nomi',
                    hint: 'admin',
                    validator: (v) => Validators.required(v, 'Login'),
                    prefixIcon: const Icon(Icons.person_outline, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _passwordController,
                    label: 'Parol',
                    hint: 'Xavfsiz parol',
                    obscureText: true,
                    validator: (v) => Validators.required(v, 'Parol'),
                    prefixIcon: const Icon(Icons.lock_outline, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _phoneController,
                    label: 'Telefon raqami',
                    hint: '+998 90 123 45 67',
                    keyboardType: TextInputType.phone,
                    validator: (v) => Validators.required(v, 'Telefon'),
                    prefixIcon: const Icon(Icons.phone_outlined, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 24),
                  CustomButton(
                    text: 'Administratorni yaratish',
                    onPressed: _createAdmin,
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
