import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/app_providers.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/empty_state_view.dart';
import '../../widgets/logout_dialog.dart';
import '../../utils/date_formatter.dart';
import 'teacher_grading_rules_screen.dart';

class TeacherDashboardScreen extends ConsumerWidget {
  const TeacherDashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    final groups = ref.watch(groupsProvider);
    final courses = ref.watch(coursesProvider);

    final teacherGroups = groups.where((g) => g.teacherId == currentUser?.id).toList();
    final todayWeekday = DateFormatter.getWeekdayShort(DateTime.now());

    final todaysLessons = teacherGroups.where((g) => g.days.contains(todayWeekday)).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('O‘qituvchi portali'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.error),
            onPressed: () => showLogoutDialog(context, ref),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome card
            CustomCard(
              backgroundColor: AppColors.card,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.info.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.person, size: 36, color: AppColors.info),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Xush kelibsiz, ${currentUser?.name ?? 'O‘qituvchi'}!',
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Bugun: ${DateFormatter.formatDisplayDate(DateTime.now())} ($todayWeekday)',
                          style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Navigation buttons to Groups / Grading rules
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'Mening guruhlarim (${teacherGroups.length})',
                    icon: Icons.group,
                    onPressed: () => context.go('/teacher/groups'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'Baholash Nizomi',
                    icon: Icons.fact_check_outlined,
                    isOutlined: true,
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const TeacherGradingRulesScreen()),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            const Text(
              'Bugungi darslar',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 12),

            todaysLessons.isEmpty
                ? const EmptyStateView(
              title: 'Bugun darslar yo‘q',
              message: 'Bugungi haft kuniga to‘g‘ri keladigan rejalashtirilgan darslaringiz yo‘q.',
              icon: Icons.event_available,
            )
                : ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: todaysLessons.length,
              itemBuilder: (context, index) {
                final g = todaysLessons[index];
                final course = courses.firstWhere((c) => c.id == g.courseId, orElse: () => courses.first);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: CustomCard(
                    onTap: () => context.go('/teacher/attendance'),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.success.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.class_, color: AppColors.success),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(g.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                              const SizedBox(height: 4),
                              Text('${course.name} • ${g.time}', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                            ],
                          ),
                        ),
                        CustomButton(
                          text: 'Davomat',
                          onPressed: () => context.go('/teacher/attendance'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}