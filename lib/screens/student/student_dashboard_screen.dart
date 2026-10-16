import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/app_providers.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/coin_badge.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/logout_dialog.dart';

class StudentDashboardScreen extends ConsumerWidget {
  const StudentDashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final users = ref.watch(usersProvider);
    final currentAuthUser = ref.watch(currentUserProvider);
    final currentUser = users.firstWhere((u) => u.id == currentAuthUser?.id, orElse: () => currentAuthUser ?? users.first);

    final books = ref.watch(booksProvider);
    final groups = ref.watch(groupsProvider);
    final courses = ref.watch(coursesProvider);

    final myBooks = books.where((b) => b.studentId == currentUser.id).toList();
    final readingCount = myBooks.where((b) => b.status == 'reading').length;
    final myGroups = groups.where((g) => g.studentIds.contains(currentUser.id)).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('O‘quvchi portali'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person, color: AppColors.primaryGold),
            onPressed: () => context.go('/student/profile'),
          ),
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
            // Greeting & Coin Card
            CustomCard(
              backgroundColor: AppColors.card,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: AppColors.primaryGold.withOpacity(0.2),
                    child: Text(
                      currentUser.name.isNotEmpty ? currentUser.name[0].toUpperCase() : 'O',
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primaryGold),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Salom, ${currentUser.name}!',
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Ko‘proq coin topish uchun o‘rganishda va kitob o‘qishda davom eting.',
                          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  CoinBadge(coins: currentUser.coins, fontSize: 16),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // History & Shop buttons
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'Mening coinlarim va tarix',
                    icon: Icons.history,
                    isOutlined: true,
                    onPressed: () => context.go('/student/coins'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomButton(
                    text: 'Sovg‘alar do‘koni',
                    icon: Icons.card_giftcard,
                    onPressed: () => context.go('/student/shop'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Portal Sections Grid
            const Text(
              'Portal bo‘limlari',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 12),

            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 1.4,
              children: [
                _buildPortalCard(context, 'Reyting va peshqadamlar', Icons.leaderboard, AppColors.warning, () => context.go('/student/rating')),
                _buildPortalCard(context, 'Mening kitoblarim ($readingCount o‘qilmoqda)', Icons.menu_book, AppColors.success, () => context.go('/student/books')),
                _buildPortalCard(context, 'So‘nggi yangiliklar', Icons.announcement, AppColors.info, () => context.go('/student/news')),
                _buildPortalCard(context, 'Qoidalar va coin qo‘llanmasi', Icons.rule, AppColors.primaryGold, () => context.go('/student/rules')),
              ],
            ),
            const SizedBox(height: 24),

            // My Lessons / Groups
            const Text(
              'Mening darslarim',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 12),

            myGroups.isEmpty
                ? const CustomCard(
                    child: Center(
                      child: Text('Siz hali hech qanday guruhga a’zo emassiz.', style: TextStyle(color: AppColors.textSecondary)),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: myGroups.length,
                    itemBuilder: (context, index) {
                      final g = myGroups[index];
                      final course = courses.firstWhere((c) => c.id == g.courseId, orElse: () => courses.first);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: CustomCard(
                          child: Row(
                            children: [
                              const Icon(Icons.school, color: AppColors.primaryGold, size: 28),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(g.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                                    const SizedBox(height: 4),
                                    Text('${course.name} • ${g.days.join(", ")} soat ${g.time}', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                                  ],
                                ),
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

  Widget _buildPortalCard(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap) {
    return CustomCard(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const Spacer(),
          Text(
            title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }
}
