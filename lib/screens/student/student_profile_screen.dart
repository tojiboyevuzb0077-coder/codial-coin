import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/app_providers.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';
import '../../utils/validators.dart';

class StudentProfileScreen extends ConsumerStatefulWidget {
  const StudentProfileScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<StudentProfileScreen> createState() => _StudentProfileScreenState();
}

class _StudentProfileScreenState extends ConsumerState<StudentProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _loginController;
  late TextEditingController _passwordController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final users = ref.read(usersProvider);
    final currentAuthUser = ref.read(currentUserProvider);
    final user = users.firstWhere((u) => u.id == currentAuthUser?.id, orElse: () => currentAuthUser ?? users.first);

    _nameController = TextEditingController(text: user.name);
    _phoneController = TextEditingController(text: user.phone);
    _loginController = TextEditingController(text: user.login);
    _passwordController = TextEditingController(text: user.password);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _loginController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final currentAuthUser = ref.read(currentUserProvider);
    if (currentAuthUser != null) {
      final repo = ref.read(appRepositoryProvider);
      final updated = currentAuthUser.copyWith(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
      );
      await repo.updateUser(updated);
      ref.read(usersProvider.notifier).refresh();
      ref.read(currentUserProvider.notifier).refresh();

      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil muvaffaqiyatli yangilandi!')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mening profilim'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: AppColors.primaryGold.withOpacity(0.2),
                  child: const Icon(Icons.person, size: 50, color: AppColors.primaryGold),
                ),
              ),
              const SizedBox(height: 24),
              CustomTextField(
                controller: _nameController,
                label: 'To‘liq ism',
                validator: (v) => Validators.required(v, 'Ism'),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _phoneController,
                label: 'Telefon raqami',
                keyboardType: TextInputType.phone,
                validator: (v) => Validators.required(v, 'Telefon'),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _loginController,
                label: 'Login (Faqat o‘qish uchun)',
                readOnly: true,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _passwordController,
                label: 'Parol (Faqat o‘qish uchun)',
                readOnly: true,
                obscureText: true,
              ),
              const SizedBox(height: 32),
              CustomButton(
                text: 'O‘zgarishlarni saqlash',
                onPressed: _saveProfile,
                isLoading: _isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
