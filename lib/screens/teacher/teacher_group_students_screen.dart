import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/app_providers.dart';
import '../../theme/app_theme.dart';
import '../../models/group.dart';
import '../../models/user.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/empty_state_view.dart';

class TeacherGroupStudentsScreen extends ConsumerStatefulWidget {
  const TeacherGroupStudentsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<TeacherGroupStudentsScreen> createState() => _TeacherGroupStudentsScreenState();
}

class _TeacherGroupStudentsScreenState extends ConsumerState<TeacherGroupStudentsScreen> {
  Group? _group;

  void _addStudentDialog(BuildContext context, WidgetRef ref) {
    if (_group == null) return;
    final users = ref.read(usersProvider);
    final availableStudents = users.where((u) => u.role == 'student' && !_group!.studentIds.contains(u.id)).toList();

    String? selectedStudentId;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setStateSB) => AlertDialog(
          backgroundColor: AppColors.card,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppColors.border),
          ),
          title: const Text('Guruhga o‘quvchi qo‘shish', style: TextStyle(color: AppColors.textPrimary)),
          content: SizedBox(
            width: 400,
            child: availableStudents.isEmpty
                ? const Text('Bo‘sh o‘quvchilar mavjud emas', style: TextStyle(color: AppColors.textSecondary))
                : DropdownButtonFormField<String>(
                    value: selectedStudentId,
                    dropdownColor: AppColors.card,
                    decoration: const InputDecoration(labelText: 'O‘quvchini tanlang'),
                    items: availableStudents.map((s) => DropdownMenuItem(
                      value: s.id,
                      child: Text(s.name, style: const TextStyle(color: AppColors.textPrimary)),
                    )).toList(),
                    onChanged: (v) => setStateSB(() => selectedStudentId = v),
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Bekor qilish', style: TextStyle(color: AppColors.textSecondary)),
            ),
            if (availableStudents.isNotEmpty)
              ElevatedButton(
                onPressed: () async {
                  if (selectedStudentId == null) return;
                  final repo = ref.read(appRepositoryProvider);
                  final newStudents = List<String>.from(_group!.studentIds)..add(selectedStudentId!);
                  final updatedGroup = _group!.copyWith(studentIds: newStudents);
                  await repo.addOrUpdateGroup(updatedGroup);
                  ref.read(groupsProvider.notifier).refresh();
                  setState(() => _group = updatedGroup);
                  if (ctx.mounted) Navigator.pop(ctx);
                },
                child: const Text('Qo‘shish'),
              ),
          ],
        ),
      ),
    );
  }

  void _moveStudentDialog(BuildContext context, WidgetRef ref, User student) {
    final currentUser = ref.read(currentUserProvider);
    final groups = ref.read(groupsProvider);
    final otherGroups = groups.where((g) => g.teacherId == currentUser?.id && g.id != _group?.id).toList();

    String? targetGroupId;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setStateSB) => AlertDialog(
          backgroundColor: AppColors.card,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppColors.border),
          ),
          title: Text('${student.name} ni boshqa guruhga ko‘chirish', style: const TextStyle(color: AppColors.textPrimary)),
          content: SizedBox(
            width: 400,
            child: otherGroups.isEmpty
                ? const Text('Bu o‘quvchini ko‘chirish uchun boshqa guruhlaringiz yo‘q.', style: TextStyle(color: AppColors.textSecondary))
                : DropdownButtonFormField<String>(
                    value: targetGroupId,
                    dropdownColor: AppColors.card,
                    decoration: const InputDecoration(labelText: 'Maqsadli guruhni tanlang'),
                    items: otherGroups.map((g) => DropdownMenuItem(
                      value: g.id,
                      child: Text(g.name, style: const TextStyle(color: AppColors.textPrimary)),
                    )).toList(),
                    onChanged: (v) => setStateSB(() => targetGroupId = v),
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Bekor qilish', style: TextStyle(color: AppColors.textSecondary)),
            ),
            if (otherGroups.isNotEmpty)
              ElevatedButton(
                onPressed: () async {
                  if (targetGroupId == null) return;
                  final repo = ref.read(appRepositoryProvider);

                  final currentStudents = List<String>.from(_group!.studentIds)..remove(student.id);
                  final updatedCurrentGroup = _group!.copyWith(studentIds: currentStudents);
                  await repo.addOrUpdateGroup(updatedCurrentGroup);

                  final targetGroup = otherGroups.firstWhere((g) => g.id == targetGroupId);
                  final targetStudents = List<String>.from(targetGroup.studentIds)..add(student.id);
                  await repo.addOrUpdateGroup(targetGroup.copyWith(studentIds: targetStudents));

                  ref.read(groupsProvider.notifier).refresh();
                  setState(() => _group = updatedCurrentGroup);
                  if (ctx.mounted) Navigator.pop(ctx);
                },
                child: const Text('Ko‘chirish'),
              ),
          ],
        ),
      ),
    );
  }

  void _removeStudent(BuildContext context, WidgetRef ref, String studentId) async {
    if (_group == null) return;
    final repo = ref.read(appRepositoryProvider);
    final newStudents = List<String>.from(_group!.studentIds)..remove(studentId);
    final updatedGroup = _group!.copyWith(studentIds: newStudents);
    await repo.addOrUpdateGroup(updatedGroup);
    ref.read(groupsProvider.notifier).refresh();
    setState(() => _group = updatedGroup);
  }

  @override
  Widget build(BuildContext context) {
    if (_group == null) {
      final groups = ref.watch(groupsProvider);
      final currentUser = ref.watch(currentUserProvider);
      final teacherGroups = groups.where((g) => g.teacherId == currentUser?.id).toList();
      if (teacherGroups.isNotEmpty) {
        _group = teacherGroups.first;
      }
    }

    final users = ref.watch(usersProvider);
    final groupStudents = _group == null
        ? <User>[]
        : users.where((u) => _group!.studentIds.contains(u.id)).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('${_group?.name ?? "Guruh"} o‘quvchilari'),
        actions: [
          if (_group != null)
            IconButton(
              icon: const Icon(Icons.person_add),
              onPressed: () => _addStudentDialog(context, ref),
            ),
        ],
      ),
      body: _group == null
          ? const EmptyStateView(title: 'Guruh yo‘q', message: 'Guruh tanlanmagan.', icon: Icons.group)
          : groupStudents.isEmpty
              ? const EmptyStateView(title: 'O‘quvchilar yo‘q', message: 'Bu guruhga o‘quvchilar qo‘shing.', icon: Icons.people_outline)
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: groupStudents.length,
                  itemBuilder: (context, index) {
                    final st = groupStudents[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: CustomCard(
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: AppColors.success.withOpacity(0.2),
                              child: Text(st.name[0].toUpperCase(), style: const TextStyle(color: AppColors.success)),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(st.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                                  const SizedBox(height: 4),
                                  Text('Login: ${st.login} | Tel: ${st.phone}', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.swap_horiz, color: AppColors.primaryGold),
                              tooltip: 'Boshqa guruhga ko‘chirish',
                              onPressed: () => _moveStudentDialog(context, ref, st),
                            ),
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline, color: AppColors.error),
                              tooltip: 'Guruhdan chiqarish',
                              onPressed: () => _removeStudent(context, ref, st.id),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
