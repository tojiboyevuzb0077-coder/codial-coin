import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/app_providers.dart';
import '../../theme/app_theme.dart';
import '../../models/shop_item.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/coin_badge.dart';
import '../../widgets/custom_textfield.dart';
import '../../widgets/empty_state_view.dart';
import '../../utils/validators.dart';

class AdminShopScreen extends ConsumerStatefulWidget {
  const AdminShopScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AdminShopScreen> createState() => _AdminShopScreenState();
}

class _AdminShopScreenState extends ConsumerState<AdminShopScreen> {
  void _showItemDialog(BuildContext context, WidgetRef ref, [ShopItem? item]) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: item?.name ?? '');
    final descController = TextEditingController(text: item?.description ?? '');
    final priceController = TextEditingController(text: item?.price != null ? item!.price.toString() : '');
    final stockController = TextEditingController(text: item?.stock != null ? item!.stock.toString() : '10');
    final imageController = TextEditingController(text: item?.imageUrl ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.border),
        ),
        title: Text(
          item == null ? 'Sovg‘a qo‘shish' : 'Sovg‘ani tahrirlash',
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
                    label: 'Buyum nomi',
                    validator: (v) => Validators.required(v, 'Nomi'),
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    controller: descController,
                    label: 'Tavsif',
                    maxLines: 2,
                    validator: (v) => Validators.required(v, 'Tavsif'),
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    controller: priceController,
                    label: 'Narxi (coinlarda)',
                    keyboardType: TextInputType.number,
                    validator: (v) => Validators.positiveNumber(v, 'Narx'),
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    controller: stockController,
                    label: 'Ombordagi miqdori',
                    keyboardType: TextInputType.number,
                    validator: (v) => Validators.positiveNumber(v, 'Miqdor'),
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    controller: imageController,
                    label: 'Rasm havolasi (ixtiyoriy)',
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
              final newItem = ShopItem(
                id: item?.id ?? 'shop_${DateTime.now().millisecondsSinceEpoch}',
                name: nameController.text.trim(),
                description: descController.text.trim(),
                price: int.parse(priceController.text.trim()),
                stock: int.parse(stockController.text.trim()),
                imageUrl: imageController.text.trim(),
              );

              await repo.addOrUpdateShopItem(newItem);
              ref.read(shopItemsProvider.notifier).refresh();
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: Text(item == null ? 'Qo‘shish' : 'Saqlash'),
          ),
        ],
      ),
    );
  }

  void _deleteItem(BuildContext context, WidgetRef ref, String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.border),
        ),
        title: const Text('Sovg‘ani o‘chirish', style: TextStyle(color: AppColors.textPrimary)),
        content: const Text('Haqiqatan ham bu sovg‘ani do‘kondan o‘chirmoqchimisiz?', style: TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Bekor qilish', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              final repo = ref.read(appRepositoryProvider);
              await repo.deleteShopItem(id);
              ref.read(shopItemsProvider.notifier).refresh();
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
    final items = ref.watch(shopItemsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sovg‘alar do‘konini boshqarish'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showItemDialog(context, ref),
          ),
        ],
      ),
      body: items.isEmpty
          ? const EmptyStateView(
              title: 'Sovg‘a buyumlari yo‘q',
              message: 'O‘quvchilar o‘z coinlariga sotib olishlari uchun do‘konga buyumlar qo‘shing.',
              icon: Icons.card_giftcard,
            )
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.75,
              ),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
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
                      Text(item.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary), maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CoinBadge(coins: item.price, fontSize: 12, padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4)),
                          Text('Omborda: ${item.stock}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: AppColors.primaryGold, size: 20),
                            onPressed: () => _showItemDialog(context, ref, item),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: AppColors.error, size: 20),
                            onPressed: () => _deleteItem(context, ref, item.id),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
