import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/app_providers.dart';
import '../../theme/app_theme.dart';
import '../../models/group.dart';
import '../../models/user.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/empty_state_view.dart';
import '../../utils/date_formatter.dart';

class TeacherAttendanceScreen extends ConsumerStatefulWidget {
  const TeacherAttendanceScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<TeacherAttendanceScreen> createState() => _TeacherAttendanceScreenState();
}

class _TeacherAttendanceScreenState extends ConsumerState<TeacherAttendanceScreen> {
  Group? _selectedGroup;

  void _updateStatus(String studentId, String status) async {
    if (_selectedGroup == null) return;
    final repo = ref.read(appRepositoryProvider);
    final today = DateFormatter.todayString();

    await repo.saveAttendanceRecord(
      groupId: _selectedGroup!.id,
      date: today,
      studentId: studentId,
      status: status,
      isTeacher: true, // Teacher attendance awards +10 coins on transition to present
    );
    ref.read(attendancesProvider.notifier).refresh();
    ref.read(usersProvider.notifier).refresh();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Davomat muvaffaqiyatli saqlandi!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    final groups = ref.watch(groupsProvider);
    final users = ref.watch(usersProvider);
    final attendances = ref.watch(attendancesProvider);

    final teacherGroups = groups.where((g) => g.teacherId == currentUser?.id).toList();

    if (_selectedGroup == null && teacherGroups.isNotEmpty) {
      _selectedGroup = teacherGroups.first;
    }

    final today = DateFormatter.todayString();
    final groupStudents = _selectedGroup == null
        ? <User>[]
        : users.where((u) => _selectedGroup!.studentIds.contains(u.id)).toList();

    final groupAttendances = attendances.where(
      (a) => _selectedGroup != null && a.groupId == _selectedGroup!.id && a.date == today,
    ).toList();

    Map<String, String> statusMap = {for (var a in groupAttendances) a.studentId: a.status};

    return Scaffold(
      appBar: AppBar(
        title: const Text('Davomat olish (BUGUN)'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                teacherGroups.isEmpty
                    ? const Text('Guruhlar biriktirilmagan', style: TextStyle(color: AppColors.textSecondary))
                    : DropdownButtonFormField<Group>(
                        value: _selectedGroup,
                        dropdownColor: AppColors.card,
                        decoration: const InputDecoration(labelText: 'Guruhni tanlang'),
                        items: teacherGroups.map((g) => DropdownMenuItem(
                          value: g,
                          child: Text(g.name, style: const TextStyle(color: AppColors.textPrimary)),
                        )).toList(),
                        onChanged: (g) => setState(() => _selectedGroup = g),
                      ),
                const SizedBox(height: 8),
                Text(
                  'Sana: $today (Davomat faqat BUGUN uchun olinishi mumkin)',
                  style: const TextStyle(fontSize: 12, color: AppColors.primaryGold),
                ),
              ],
            ),
          ),
          Expanded(
            child: _selectedGroup == null
                ? const EmptyStateView(title: 'Guruh tanlanmagan', message: 'O‘zingizga biriktirilgan guruhlardan birini tanlang.', icon: Icons.fact_check)
                : groupStudents.isEmpty
                    ? const EmptyStateView(title: 'O‘quvchilar yo‘q', message: 'Bu guruhga o‘quvchilar biriktirilmagan.', icon: Icons.people_outline)
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: groupStudents.length,
                        itemBuilder: (context, index) {
                          final st = groupStudents[index];
                          final currentStatus = statusMap[st.id] ?? 'absent';

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: CustomCard(
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: AppColors.card,
                                    child: Text(st.name[0].toUpperCase(), style: const TextStyle(color: AppColors.primaryGold)),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(st.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                                        const SizedBox(height: 4),
                                        Text('Status: ${currentStatus.toUpperCase()}', style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: currentStatus == 'present' ? AppColors.success :
                                                 currentStatus == 'absent' ? AppColors.error : AppColors.warning,
                                        )),
                                      ],
                                    ),
                                  ),
                                  ToggleButtons(
                                    isSelected: [
                                      currentStatus == 'present',
                                      currentStatus == 'absent',
                                      currentStatus == 'late',
                                    ],
                                    onPressed: (idx) {
                                      String newStatus = ['present', 'absent', 'late'][idx];
                                      _updateStatus(st.id, newStatus);
                                    },
                                    borderRadius: BorderRadius.circular(8),
                                    selectedColor: Colors.white,
                                    fillColor: AppColors.primaryGold.withOpacity(0.3),
                                    color: AppColors.textSecondary,
                                    constraints: const BoxConstraints(minHeight: 36, minWidth: 50),
                                    children: const [
                                      Text('Kelgan (+10)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                      Text('Kelmagan', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                      Text('Kechikkan', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                    ],
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
