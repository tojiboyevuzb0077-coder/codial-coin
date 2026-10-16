import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/app_providers.dart';
import '../../theme/app_theme.dart';
import '../../models/course.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/custom_textfield.dart';
import '../../widgets/empty_state_view.dart';
import '../../utils/validators.dart';

class AdminCoursesScreen extends ConsumerStatefulWidget {
  const AdminCoursesScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AdminCoursesScreen> createState() => _AdminCoursesScreenState();
}

class _AdminCoursesScreenState extends ConsumerState<AdminCoursesScreen> {
  void _showCourseDialog(BuildContext context, WidgetRef ref, [Course? course]) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: course?.name ?? '');
    final descController = TextEditingController(text: course?.description ?? '');
    final priceController = TextEditingController(text: course?.uzsPrice != null ? course!.uzsPrice.toString() : '');
    final durationController = TextEditingController(text: course?.durationMonths != null ? course!.durationMonths.toString() : '3');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.border),
        ),
        title: Text(
          course == null ? 'Kurs qo‘shish' : 'Kursni tahrirlash',
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
                    label: 'Kurs nomi',
                    validator: (v) => Validators.required(v, 'Nomi'),
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    controller: descController,
                    label: 'Tavsif',
                    maxLines: 3,
                    validator: (v) => Validators.required(v, 'Tavsif'),
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    controller: priceController,
                    label: 'Narxi (UZS)',
                    keyboardType: TextInputType.number,
                    validator: (v) => Validators.positiveNumber(v, 'Narx'),
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    controller: durationController,
                    label: 'Davomiyligi (oy)',
                    keyboardType: TextInputType.number,
                    validator: (v) => Validators.positiveNumber(v, 'Davomiylik'),
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
              final newCourse = Course(
                id: course?.id ?? 'course_${DateTime.now().millisecondsSinceEpoch}',
                name: nameController.text.trim(),
                description: descController.text.trim(),
                uzsPrice: double.parse(priceController.text.trim()),
                durationMonths: int.parse(durationController.text.trim()),
              );

              await repo.addOrUpdateCourse(newCourse);
              ref.read(coursesProvider.notifier).refresh();
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: Text(course == null ? 'Qo‘shish' : 'Saqlash'),
          ),
        ],
      ),
    );
  }

  void _deleteCourse(BuildContext context, WidgetRef ref, String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.border),
        ),
        title: const Text('Kursni o‘chirish', style: TextStyle(color: AppColors.textPrimary)),
        content: const Text('Haqiqatan ham bu kursni o‘chirmoqchimisiz?', style: TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Bekor qilish', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              final repo = ref.read(appRepositoryProvider);
              await repo.deleteCourse(id);
              ref.read(coursesProvider.notifier).refresh();
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
    final courses = ref.watch(coursesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kurslarni boshqarish'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showCourseDialog(context, ref),
          ),
        ],
      ),
      body: courses.isEmpty
          ? const EmptyStateView(
              title: 'Kurslar topilmadi',
              message: 'Akademiyada taklif qilish uchun kurslar qo‘shing.',
              icon: Icons.book_outlined,
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: courses.length,
              itemBuilder: (context, index) {
                final c = courses[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: CustomCard(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.primaryGold.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.menu_book, color: AppColors.primaryGold, size: 24),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(c.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                              const SizedBox(height: 4),
                              Text(c.description, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Text('${c.uzsPrice} UZS', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primaryGold)),
                                  const SizedBox(width: 16),
                                  Text('${c.durationMonths} oy', style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit, color: AppColors.primaryGold),
                          onPressed: () => _showCourseDialog(context, ref, c),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: AppColors.error),
                          onPressed: () => _deleteCourse(context, ref, c.id),
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
