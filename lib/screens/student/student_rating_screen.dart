import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/app_providers.dart';
import '../../theme/app_theme.dart';
import '../../models/group.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/coin_badge.dart';
import '../../widgets/empty_state_view.dart';

class StudentRatingScreen extends ConsumerStatefulWidget {
  const StudentRatingScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<StudentRatingScreen> createState() => _StudentRatingScreenState();
}

class _StudentRatingScreenState extends ConsumerState<StudentRatingScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  String? _selectedGroupId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final users = ref.watch(usersProvider);
    final currentUser = ref.watch(currentUserProvider);
    final groups = ref.watch(groupsProvider);

    // Students sorted by coins descending
    var students = users.where((u) => u.role == 'student').toList();
    if (_selectedGroupId != null) {
      final g = groups.firstWhere((grp) => grp.id == _selectedGroupId, orElse: () => groups.first);
      students = students.where((s) => g.studentIds.contains(s.id)).toList();
    }
    if (_searchQuery.isNotEmpty) {
      students = students.where((s) => s.name.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    }
    students.sort((a, b) => b.coins.compareTo(a.coins));

    // Groups rating (sum of student coins or average coins)
    var groupRatings = groups.map((g) {
      int totalCoins = 0;
      int count = g.studentIds.length;
      for (var stId in g.studentIds) {
        try {
          var st = users.firstWhere((u) => u.id == stId);
          totalCoins += st.coins;
        } catch (_) {}
      }
      return {'group': g, 'totalCoins': totalCoins, 'avgCoins': count > 0 ? (totalCoins / count).round() : 0};
    }).toList();
    groupRatings.sort((a, b) => (b['totalCoins'] as int).compareTo(a['totalCoins'] as int));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reyting va peshqadamlar'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primaryGold,
          labelColor: AppColors.primaryGold,
          unselectedLabelColor: AppColors.textSecondary,
          tabs: const [
            Tab(text: 'O‘quvchilar'),
            Tab(text: 'Guruhlar'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Students Tab
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(
                          hintText: 'O‘quvchilarni qidirish...',
                          prefixIcon: Icon(Icons.search, color: AppColors.textSecondary),
                        ),
                        onChanged: (v) => setState(() => _searchQuery = v),
                      ),
                    ),
                    const SizedBox(width: 12),
                    DropdownButton<String?>(
                      value: _selectedGroupId,
                      dropdownColor: AppColors.card,
                      hint: const Text('Barcha guruhlar', style: TextStyle(color: AppColors.textSecondary)),
                      items: [
                        const DropdownMenuItem(value: null, child: Text('Barcha guruhlar', style: TextStyle(color: AppColors.textPrimary))),
                        ...groups.map((g) => DropdownMenuItem(value: g.id, child: Text(g.name, style: TextStyle(color: AppColors.textPrimary)))),
                      ],
                      onChanged: (v) => setState(() => _selectedGroupId = v),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: students.isEmpty
                    ? const EmptyStateView(title: 'O‘quvchilar topilmadi', message: 'Qidiruv shartingizga mos o‘quvchilar topilmadi.', icon: Icons.leaderboard)
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: students.length,
                        itemBuilder: (context, index) {
                          final st = students[index];
                          final isMe = st.id == currentUser?.id;
                          String rankBadge = '#${index + 1}';
                          Color rankColor = AppColors.textSecondary;
                          if (index == 0) {
                            rankBadge = '👑 1';
                            rankColor = AppColors.primaryGold;
                          } else if (index == 1) {
                            rankBadge = '🥈 2';
                            rankColor = Colors.grey.shade300;
                          } else if (index == 2) {
                            rankBadge = '🥉 3';
                            rankColor = Colors.brown.shade300;
                          }

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: CustomCard(
                              backgroundColor: isMe ? AppColors.primaryGold.withOpacity(0.1) : AppColors.card,
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 45,
                                    child: Text(
                                      rankBadge,
                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: rankColor),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  CircleAvatar(
                                    backgroundColor: AppColors.card,
                                    child: Text(st.name[0].toUpperCase(), style: const TextStyle(color: AppColors.primaryGold)),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Text(
                                      st.name + (isMe ? ' (Siz)' : ''),
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: isMe ? FontWeight.bold : FontWeight.normal,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ),
                                  CoinBadge(coins: st.coins),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),

          // Groups Tab
          groupRatings.isEmpty
              ? const EmptyStateView(title: 'Guruhlar yo‘q', message: 'Peshqadamlar jadvali uchun guruhlar mavjud emas.', icon: Icons.group)
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: groupRatings.length,
                  itemBuilder: (context, index) {
                    final item = groupRatings[index];
                    final Group g = item['group'] as Group;
                    final int totalCoins = item['totalCoins'] as int;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: CustomCard(
                        child: Row(
                          children: [
                            SizedBox(
                              width: 40,
                              child: Text('#${index + 1}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryGold)),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(g.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                                  const SizedBox(height: 4),
                                  Text('O‘quvchilar soni: ${g.studentIds.length}', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                                ],
                              ),
                            ),
                            CoinBadge(coins: totalCoins),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }
}
