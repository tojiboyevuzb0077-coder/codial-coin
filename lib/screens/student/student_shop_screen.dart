import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/app_providers.dart';
import '../../theme/app_theme.dart';
import '../../models/shop_item.dart';
import '../../models/user.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/coin_badge.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/empty_state_view.dart';

class StudentShopScreen extends ConsumerStatefulWidget {
  const StudentShopScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<StudentShopScreen> createState() => _StudentShopScreenState();
}

class _StudentShopScreenState extends ConsumerState<StudentShopScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showPurchaseDialog(BuildContext context, WidgetRef ref, ShopItem item, User currentUser) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.border),
        ),
        title: const Text('Xaridni tasdiqlash', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
        content: Text('"${item.name}" ni ${item.price} coin evaziga sotib olmoqchimisiz?', style: const TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Bekor qilish', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () async {
              if (currentUser.coins < item.price) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Coinlar balansi yetarli emas!'), backgroundColor: AppColors.error),
                );
                return;
              }

              final repo = ref.read(appRepositoryProvider);
              String? err = await repo.purchaseShopItem(currentUser.id, item.id);
              ref.read(shopItemsProvider.notifier).refresh();
              ref.read(usersProvider.notifier).refresh();
              ref.read(currentUserProvider.notifier).refresh();
              ref.read(transactionsProvider.notifier).refresh();

              if (ctx.mounted) Navigator.pop(ctx);
              if (mounted) {
                if (err == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Buyum muvaffaqiyatli sotib olindi!')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(err), backgroundColor: AppColors.error),
                  );
                }
              }
            },
            child: const Text('Sotib olish'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final users = ref.watch(usersProvider);
    final currentAuthUser = ref.watch(currentUserProvider);
    final currentUser = users.firstWhere((u) => u.id == currentAuthUser?.id, orElse: () => currentAuthUser ?? users.first);

    final items = ref.watch(shopItemsProvider);

    List<ShopItem> getFilteredItems(int tabIndex) {
      if (tabIndex == 0) return items; // All
      if (tabIndex == 1) return items.where((i) => i.price <= currentUser.coins).toList(); // Affordable
      return items.where((i) => i.stock > 0).toList(); // In stock
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sovg‘alar do‘koni'),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: CoinBadge(coins: currentUser.coins, fontSize: 16),
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primaryGold,
          labelColor: AppColors.primaryGold,
          unselectedLabelColor: AppColors.textSecondary,
          tabs: const [
            Tab(text: 'Barcha buyumlar'),
            Tab(text: 'Imkoniyatga mos'),
            Tab(text: 'Omborda bor'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildItemGrid(getFilteredItems(0), currentUser),
          _buildItemGrid(getFilteredItems(1), currentUser),
          _buildItemGrid(getFilteredItems(2), currentUser),
        ],
      ),
    );
  }

  Widget _buildItemGrid(List<ShopItem> items, User currentUser) {
    if (items.isEmpty) {
      return const EmptyStateView(
        title: 'Buyumlar topilmadi',
        message: 'Bu filtr kategoriyasiga mos buyumlar yo‘q.',
        icon: Icons.card_giftcard,
      );
    }
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.7,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        bool canAfford = currentUser.coins >= item.price;
        bool inStock = item.stock > 0;

        return CustomCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                    image: item.imageUrl.isNotEmpty
                        ? DecorationImage(image: NetworkImage(item.imageUrl), fit: BoxFit.cover)
                        : null,
                  ),
                  child: item.imageUrl.isEmpty
                      ? const Center(child: Icon(Icons.card_giftcard, size: 40, color: AppColors.primaryGold))
                      : null,
                ),
              ),
              const SizedBox(height: 8),
              Text(item.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary), maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CoinBadge(coins: item.price, fontSize: 12, padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4)),
                  Text('Omborda: ${item.stock}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: CustomButton(
                  text: inStock ? (canAfford ? 'Sotib olish' : 'Coin yetmaydi') : 'Qolmagan',
                  onPressed: (inStock && canAfford) ? () => _showPurchaseDialog(context, ref, item, currentUser) : () {
                    if (!canAfford) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Coinlar balansi yetarli emas!'), backgroundColor: AppColors.error),
                      );
                    }
                  },
                  backgroundColor: canAfford && inStock ? AppColors.primaryGold : AppColors.border,
                  textColor: canAfford && inStock ? const Color(0xFF0B1220) : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
