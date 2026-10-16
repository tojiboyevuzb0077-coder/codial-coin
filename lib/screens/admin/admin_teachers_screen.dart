import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/app_providers.dart';
import '../../theme/app_theme.dart';
import '../../models/user.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/custom_textfield.dart';
import '../../widgets/empty_state_view.dart';
import '../../utils/validators.dart';

class AdminTeachersScreen extends ConsumerStatefulWidget {
  const AdminTeachersScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AdminTeachersScreen> createState() => _AdminTeachersScreenState();
}

class _AdminTeachersScreenState extends ConsumerState<AdminTeachersScreen> {
  String _searchQuery = '';

  void _showTeacherDialog(BuildContext context, WidgetRef ref, [User? teacher]) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: teacher?.name ?? '');
    final loginController = TextEditingController(text: teacher?.login ?? '');
    final passwordController = TextEditingController(text: teacher?.password ?? '');
    final phoneController = TextEditingController(text: teacher?.phone ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.border),
        ),
        title: Text(
          teacher == null ? 'O‘qituvchi qo‘shish' : 'O‘qituvchini tahrirlash',
          style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
        ),
        content: SizedBox(
          width: 400,
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomTextField(
                    controller: nameController,
                    label: 'To‘liq ism',
                    validator: (v) => Validators.required(v, 'Ism'),
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    controller: loginController,
                    label: 'Login',
                    validator: (v) => Validators.required(v, 'Login'),
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    controller: passwordController,
                    label: 'Parol',
                    obscureText: true,
                    validator: (v) => Validators.required(v, 'Parol'),
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    controller: phoneController,
                    label: 'Telefon',
                    keyboardType: TextInputType.phone,
                    validator: (v) => Validators.required(v, 'Telefon'),
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Bekor qilish', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              final repo = ref.read(appRepositoryProvider);
              if (teacher == null) {
                final newTeacher = User(
                  id: 'teacher_${DateTime.now().millisecondsSinceEpoch}',
                  name: nameController.text.trim(),
                  login: loginController.text.trim().toLowerCase(),
                  password: passwordController.text.trim(),
                  role: 'teacher',
                  phone: phoneController.text.trim(),
                );
                await repo.registerUser(newTeacher);
              } else {
                final updated = teacher.copyWith(
                  name: nameController.text.trim(),
                  login: loginController.text.trim().toLowerCase(),
                  password: passwordController.text.trim(),
                  phone: phoneController.text.trim(),
                );
                await repo.updateUser(updated);
              }
              ref.read(usersProvider.notifier).refresh();
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: Text(teacher == null ? 'Qo‘shish' : 'Saqlash'),
          ),
        ],
      ),
    );
  }

  void _deleteTeacher(BuildContext context, WidgetRef ref, String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.border),
        ),
        title: const Text('O‘qituvchini o‘chirish', style: TextStyle(color: AppColors.textPrimary)),
        content: const Text('Haqiqatan ham bu o‘qituvchini o‘chirmoqchimisiz?', style: TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Bekor qilish', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              final repo = ref.read(appRepositoryProvider);
              await repo.deleteUser(id);
              ref.read(usersProvider.notifier).refresh();
              ref.read(groupsProvider.notifier).refresh();
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('O‘chirish', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final users = ref.watch(usersProvider);
    final teachers = users.where((u) => u.role == 'teacher' && 
      (u.name.toLowerCase().contains(_searchQuery.toLowerCase()) || 
       u.login.toLowerCase().contains(_searchQuery.toLowerCase()))).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('O‘qituvchilarni boshqarish'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showTeacherDialog(context, ref),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'O‘qituvchilarni qidirish...',
                prefixIcon: Icon(Icons.search, color: AppColors.textSecondary),
              ),
              onChanged: (v) => setState(() => _searchQuery = v),
            ),
          ),
          Expanded(
            child: teachers.isEmpty
                ? const EmptyStateView(
                    title: 'O‘qituvchilar topilmadi',
                    message: 'Guruhlarga biriktirish uchun o‘qituvchilar qo‘shing.',
                    icon: Icons.person_off,
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: teachers.length,
                    itemBuilder: (context, index) {
                      final t = teachers[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: CustomCard(
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: AppColors.info.withOpacity(0.2),
                                child: Text(t.name.isNotEmpty ? t.name[0].toUpperCase() : 'O',
                                    style: const TextStyle(color: AppColors.info, fontWeight: FontWeight.bold)),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(t.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                                    const SizedBox(height: 4),
                                    Text('Login: ${t.login} | Tel: ${t.phone}', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit, color: AppColors.primaryGold),
                                onPressed: () => _showTeacherDialog(context, ref, t),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: AppColors.error),
                                onPressed: () => _deleteTeacher(context, ref, t.id),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
