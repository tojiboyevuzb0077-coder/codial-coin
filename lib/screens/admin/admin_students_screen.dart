import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/app_providers.dart';
import '../../theme/app_theme.dart';
import '../../models/user.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/coin_badge.dart';
import '../../widgets/custom_textfield.dart';
import '../../widgets/empty_state_view.dart';
import '../../utils/validators.dart';

class AdminStudentsScreen extends ConsumerStatefulWidget {
  const AdminStudentsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AdminStudentsScreen> createState() => _AdminStudentsScreenState();
}

class _AdminStudentsScreenState extends ConsumerState<AdminStudentsScreen> {
  String _searchQuery = '';

  void _showStudentDialog(BuildContext context, WidgetRef ref, [User? student]) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: student?.name ?? '');
    final loginController = TextEditingController(text: student?.login ?? '');
    final passwordController = TextEditingController(text: student?.password ?? '');
    final phoneController = TextEditingController(text: student?.phone ?? '');
    
    final courses = ref.read(coursesProvider);
    final groups = ref.read(groupsProvider);
    String? selectedCourseId;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setStateSB) => AlertDialog(
          backgroundColor: AppColors.card,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppColors.border),
          ),
          title: Text(
            student == null ? 'O‘quvchi qo‘shish' : 'O‘quvchini tahrirlash',
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
                    if (student == null) ...[
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: selectedCourseId,
                        dropdownColor: AppColors.card,
                        decoration: const InputDecoration(labelText: 'Kursga biriktirish (Ixtiyoriy)'),
                        items: courses.map((c) => DropdownMenuItem(
                          value: c.id,
                          child: Text(c.name, style: const TextStyle(color: AppColors.textPrimary)),
                        )).toList(),
                        onChanged: (v) => setStateSB(() => selectedCourseId = v),
                      ),
                    ],
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
                if (student == null) {
                  String studentId = 'student_${DateTime.now().millisecondsSinceEpoch}';
                  List<String> assignedGroupIds = [];
                  if (selectedCourseId != null) {
                    final matchGroups = groups.where((g) => g.courseId == selectedCourseId).toList();
                    if (matchGroups.isNotEmpty) {
                      var targetGroup = matchGroups.first;
                      assignedGroupIds.add(targetGroup.id);
                      var updatedStudents = List<String>.from(targetGroup.studentIds)..add(studentId);
                      await repo.addOrUpdateGroup(targetGroup.copyWith(studentIds: updatedStudents));
                    }
                  }

                  final newStudent = User(
                    id: studentId,
                    name: nameController.text.trim(),
                    login: loginController.text.trim().toLowerCase(),
                    password: passwordController.text.trim(),
                    role: 'student',
                    phone: phoneController.text.trim(),
                    coins: 50,
                    groupIds: assignedGroupIds,
                  );
                  await repo.registerUser(newStudent);
                } else {
                  final updated = student.copyWith(
                    name: nameController.text.trim(),
                    login: loginController.text.trim().toLowerCase(),
                    password: passwordController.text.trim(),
                    phone: phoneController.text.trim(),
                  );
                  await repo.updateUser(updated);
                }
                ref.read(usersProvider.notifier).refresh();
                ref.read(groupsProvider.notifier).refresh();
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: Text(student == null ? 'Qo‘shish' : 'Saqlash'),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteStudent(BuildContext context, WidgetRef ref, String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.border),
        ),
        title: const Text('O‘quvchini o‘chirish', style: TextStyle(color: AppColors.textPrimary)),
        content: const Text('Haqiqatan ham bu o‘quvchini o‘chirmoqchimisiz?', style: TextStyle(color: AppColors.textSecondary)),
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
    final students = users.where((u) => u.role == 'student' && 
      (u.name.toLowerCase().contains(_searchQuery.toLowerCase()) || 
       u.login.toLowerCase().contains(_searchQuery.toLowerCase()))).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('O‘quvchilarni boshqarish'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showStudentDialog(context, ref),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'O‘quvchilarni qidirish...',
                prefixIcon: Icon(Icons.search, color: AppColors.textSecondary),
              ),
              onChanged: (v) => setState(() => _searchQuery = v),
            ),
          ),
          Expanded(
            child: students.isEmpty
                ? const EmptyStateView(
                    title: 'O‘quvchilar topilmadi',
                    message: 'Kurslar va guruhlarga yozish uchun o‘quvchilar qo‘shing.',
                    icon: Icons.school_outlined,
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: students.length,
                    itemBuilder: (context, index) {
                      final s = students[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: CustomCard(
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: AppColors.success.withOpacity(0.2),
                                child: Text(s.name.isNotEmpty ? s.name[0].toUpperCase() : 'O',
                                    style: const TextStyle(color: AppColors.success, fontWeight: FontWeight.bold)),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(s.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                                    const SizedBox(height: 4),
                                    Text('Login: ${s.login} | Tel: ${s.phone}', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                                  ],
                                ),
                              ),
                              CoinBadge(coins: s.coins),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(Icons.edit, color: AppColors.primaryGold),
                                onPressed: () => _showStudentDialog(context, ref, s),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: AppColors.error),
                                onPressed: () => _deleteStudent(context, ref, s.id),
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
