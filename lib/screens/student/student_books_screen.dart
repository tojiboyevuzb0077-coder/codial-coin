import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/app_providers.dart';
import '../../theme/app_theme.dart';
import '../../models/book.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';
import '../../widgets/empty_state_view.dart';
import '../../utils/validators.dart';
import '../../utils/date_formatter.dart';

class StudentBooksScreen extends ConsumerStatefulWidget {
  const StudentBooksScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<StudentBooksScreen> createState() => _StudentBooksScreenState();
}

class _StudentBooksScreenState extends ConsumerState<StudentBooksScreen> {
  void _addBookDialog(BuildContext context, WidgetRef ref) {
    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController();
    final authorController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.border),
        ),
        title: const Text('O‘qish uchun kitob qo‘shish', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
        content: SizedBox(
          width: 400,
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomTextField(
                    controller: titleController,
                    label: 'Kitob nomi',
                    validator: (v) => Validators.required(v, 'Nomi'),
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    controller: authorController,
                    label: 'Muallif',
                    validator: (v) => Validators.required(v, 'Muallif'),
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
              final currentUser = ref.read(currentUserProvider);
              if (currentUser == null) return;
              final repo = ref.read(appRepositoryProvider);

              final newBook = Book(
                id: 'book_${DateTime.now().millisecondsSinceEpoch}',
                studentId: currentUser.id,
                title: titleController.text.trim(),
                author: authorController.text.trim(),
                startDate: DateFormatter.todayString(),
                status: 'reading',
                daysCount: 0,
                coinsEarned: 0,
              );

              await repo.addBook(newBook);
              ref.read(booksProvider.notifier).refresh();
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Kitob qo‘shish'),
          ),
        ],
      ),
    );
  }

  void _finishBook(BuildContext context, WidgetRef ref, String bookId) async {
    final repo = ref.read(appRepositoryProvider);
    await repo.finishBook(bookId);
    ref.read(booksProvider.notifier).refresh();
    ref.read(usersProvider.notifier).refresh();
    ref.read(transactionsProvider.notifier).refresh();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tabriklaymiz! Kitobni o‘qib tugatganingiz uchun +50 coin oldingiz!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    final books = ref.watch(booksProvider);

    final myBooks = books.where((b) => b.studentId == currentUser?.id).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mening kitoblarim'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _addBookDialog(context, ref),
          ),
        ],
      ),
      body: myBooks.isEmpty
          ? const EmptyStateView(
              title: 'Kitoblar qo‘shilmagan',
              message: 'Jarayonni kuzatish va tugatgandan so‘ng +50 coin olish uchun o‘qiyotgan kitoblaringizni qo‘shing.',
              icon: Icons.menu_book,
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: myBooks.length,
              itemBuilder: (context, index) {
                final b = myBooks[index];
                final isFinished = b.status == 'finished';

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: CustomCard(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isFinished ? AppColors.success.withOpacity(0.15) : AppColors.primaryGold.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            isFinished ? Icons.check_circle : Icons.menu_book,
                            color: isFinished ? AppColors.success : AppColors.primaryGold,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(b.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                              const SizedBox(height: 4),
                              Text('Muallif: ${b.author}', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                              const SizedBox(height: 4),
                              Text(
                                isFinished ? '${b.daysCount} kunda o‘qib tugatildi (+${b.coinsEarned} coin)' : 'Boshlandi: ${b.startDate}',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: isFinished ? AppColors.success : AppColors.primaryGold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (!isFinished)
                          CustomButton(
                            text: 'O‘qib tugatdim (+50 coin)',
                            onPressed: () => _finishBook(context, ref, b.id),
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
