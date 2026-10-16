import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/app_providers.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/empty_state_view.dart';
import '../../utils/date_formatter.dart';

class TeacherGroupsScreen extends ConsumerWidget {
  const TeacherGroupsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    final groups = ref.watch(groupsProvider);
    final courses = ref.watch(coursesProvider);

    final teacherGroups = groups.where((g) => g.teacherId == currentUser?.id).toList();
    final todayWeekday = DateFormatter.getWeekdayShort(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mening guruhlarim'),
      ),
      body: teacherGroups.isEmpty
          ? const EmptyStateView(
              title: 'Guruhlar biriktirilmagan',
              message: 'Sizga hali hech qanday guruh biriktirilmagan.',
              icon: Icons.group_off,
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: teacherGroups.length,
              itemBuilder: (context, index) {
                final g = teacherGroups[index];
                final course = courses.firstWhere((c) => c.id == g.courseId, orElse: () => courses.isNotEmpty ? courses.first : throw '');
                final bool isToday = g.days.contains(todayWeekday);

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
                            if (isToday)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.success.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: AppColors.success),
                                ),
                                child: const Text('BUGUN', style: TextStyle(color: AppColors.success, fontSize: 12, fontWeight: FontWeight.bold)),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text('Kurs: ${course.name}', style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                        const SizedBox(height: 4),
                        Text('Jadval: ${g.days.join(", ")} soat ${g.time}', style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                        const SizedBox(height: 4),
                        Text('O‘quvchilar: ${g.studentIds.length}', style: const TextStyle(fontSize: 14, color: AppColors.primaryGold)),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: CustomButton(
                                text: 'Davomat',
                                icon: Icons.fact_check,
                                onPressed: () => context.go('/teacher/attendance'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: CustomButton(
                                text: 'O‘quvchilar',
                                icon: Icons.people,
                                isOutlined: true,
                                onPressed: () => context.go('/teacher/group_students', extra: g),
                              ),
                            ),
                          ],
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
