import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/app_providers.dart';
import '../../theme/app_theme.dart';
import '../../models/group.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/custom_textfield.dart';
import '../../widgets/empty_state_view.dart';
import '../../utils/validators.dart';
import '../../utils/date_formatter.dart';

class AdminGroupsScreen extends ConsumerStatefulWidget {
  const AdminGroupsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AdminGroupsScreen> createState() => _AdminGroupsScreenState();
}

class _AdminGroupsScreenState extends ConsumerState<AdminGroupsScreen> {
  void _showGroupDialog(BuildContext context, WidgetRef ref, [Group? group]) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: group?.name ?? '');
    final timeController = TextEditingController(text: group?.time ?? '14:00');

    final courses = ref.read(coursesProvider);
    final users = ref.read(usersProvider);
    final teachers = users.where((u) => u.role == 'teacher').toList();
    final students = users.where((u) => u.role == 'student').toList();

    String? selectedCourseId = group?.courseId ?? (courses.isNotEmpty ? courses.first.id : null);
    String? selectedTeacherId = group?.teacherId ?? (teachers.isNotEmpty ? teachers.first.id : null);
    List<String> selectedDays = List<String>.from(group?.days ?? ['Du', 'Ch', 'Ju']);
    Set<String> selectedStudentIds = Set<String>.from(group?.studentIds ?? []);

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
            group == null ? 'Guruh qo‘shish' : 'Guruhni tahrirlash',
            style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
          ),
          content: SizedBox(
            width: 500,
            height: 600,
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomTextField(
                      controller: nameController,
                      label: 'Guruh nomi',
                      validator: (v) => Validators.required(v, 'Nomi'),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedCourseId,
                      dropdownColor: AppColors.card,
                      decoration: const InputDecoration(labelText: 'Kurs'),
                      items: courses.map((c) => DropdownMenuItem(
                        value: c.id,
                        child: Text(c.name, style: const TextStyle(color: AppColors.textPrimary)),
                      )).toList(),
                      onChanged: (v) => setStateSB(() => selectedCourseId = v),
                      validator: (v) => v == null ? 'Kurs kiritilishi shart' : null,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedTeacherId,
                      dropdownColor: AppColors.card,
                      decoration: const InputDecoration(labelText: 'O‘qituvchi'),
                      items: teachers.map((t) => DropdownMenuItem(
                        value: t.id,
                        child: Text(t.name, style: const TextStyle(color: AppColors.textPrimary)),
                      )).toList(),
                      onChanged: (v) => setStateSB(() => selectedTeacherId = v),
                      validator: (v) => v == null ? 'O‘qituvchi kiritilishi shart' : null,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: timeController,
                      label: 'Vaqt (masalan, 14:00)',
                      validator: (v) => Validators.required(v, 'Vaqt'),
                    ),
                    const SizedBox(height: 16),
                    const Text('Kunlar', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: DateFormatter.weekdaysShort.map((day) {
                        bool isSelected = selectedDays.contains(day);
                        return FilterChip(
                          label: Text(day),
                          selected: isSelected,
                          onSelected: (selected) {
                            setStateSB(() {
                              if (selected) {
                                selectedDays.add(day);
                              } else {
                                selectedDays.remove(day);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    const Text('O‘quvchilar', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                    const SizedBox(height: 8),
                    students.isEmpty
                        ? const Text('O‘quvchilar mavjud emas', style: TextStyle(color: AppColors.textSecondary))
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: students.length,
                            itemBuilder: (context, index) {
                              final st = students[index];
                              bool isChecked = selectedStudentIds.contains(st.id);
                              return CheckboxListTile(
                                title: Text(st.name, style: const TextStyle(color: AppColors.textPrimary)),
                                subtitle: Text(st.login, style: const TextStyle(color: AppColors.textSecondary)),
                                value: isChecked,
                                onChanged: (val) {
                                  setStateSB(() {
                                    if (val == true) {
                                      selectedStudentIds.add(st.id);
                                    } else {
                                      selectedStudentIds.remove(st.id);
                                    }
                                  });
                                },
                              );
                            },
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
                final groupId = group?.id ?? 'group_${DateTime.now().millisecondsSinceEpoch}';

                final newGroup = Group(
                  id: groupId,
                  name: nameController.text.trim(),
                  courseId: selectedCourseId ?? '',
                  teacherId: selectedTeacherId ?? '',
                  days: selectedDays,
                  time: timeController.text.trim(),
                  studentIds: selectedStudentIds.toList(),
                );

                await repo.addOrUpdateGroup(newGroup);
                ref.read(groupsProvider.notifier).refresh();
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: Text(group == null ? 'Qo‘shish' : 'Saqlash'),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteGroup(BuildContext context, WidgetRef ref, String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.border),
        ),
        title: const Text('Guruhni o‘chirish', style: TextStyle(color: AppColors.textPrimary)),
        content: const Text('Haqiqatan ham bu guruhni o‘chirmoqchimisiz?', style: TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Bekor qilish', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              final repo = ref.read(appRepositoryProvider);
              await repo.deleteGroup(id);
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
    final groups = ref.watch(groupsProvider);
    final courses = ref.watch(coursesProvider);
    final users = ref.watch(usersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Guruhlarni boshqarish'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showGroupDialog(context, ref),
          ),
        ],
      ),
      body: groups.isEmpty
          ? const EmptyStateView(
              title: 'Guruhlar topilmadi',
              message: 'Darslar va jadvalni tashkil qilish uchun guruhlar yarating.',
              icon: Icons.group_outlined,
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: groups.length,
              itemBuilder: (context, index) {
                final g = groups[index];
                final course = courses.firstWhere((c) => c.id == g.courseId, orElse: () => courses.first);
                final teacher = users.firstWhere((u) => u.id == g.teacherId, orElse: () => users.first);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: CustomCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(g.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: AppColors.primaryGold, size: 20),
                                  onPressed: () => _showGroupDialog(context, ref, g),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: AppColors.error, size: 20),
                                  onPressed: () => _deleteGroup(context, ref, g.id),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text('Kurs: ${course.name}', style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                        const SizedBox(height: 4),
                        Text('O‘qituvchi: ${teacher.name}', style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                        const SizedBox(height: 4),
                        Text('Jadval: ${g.days.join(", ")} soat ${g.time}', style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                        const SizedBox(height: 4),
                        Text('Biriktirilgan o‘quvchilar: ${g.studentIds.length}', style: const TextStyle(fontSize: 14, color: AppColors.primaryGold)),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
