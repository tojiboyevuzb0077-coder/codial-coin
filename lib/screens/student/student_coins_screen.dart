import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/app_providers.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/coin_badge.dart';
import '../../widgets/empty_state_view.dart';

class StudentCoinsScreen extends ConsumerWidget {
  const StudentCoinsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final users = ref.watch(usersProvider);
    final currentAuthUser = ref.watch(currentUserProvider);
    final currentUser = users.firstWhere((u) => u.id == currentAuthUser?.id, orElse: () => currentAuthUser ?? users.first);

    final txs = ref.watch(transactionsProvider);
    final myTxs = txs.where((t) => t.userId == currentUser.id).toList().reversed.toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mening coinlarim va tarix'),
      ),
      body: Column(
        children: [
          // Balance Card
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: CustomCard(
              backgroundColor: AppColors.card,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  children: [
                    const Text('Jami coinlar balansi', style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                    const SizedBox(height: 8),
                    CoinBadge(coins: currentUser.coins, fontSize: 24, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10)),
                  ],
                ),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('Tranzaksiyalar tarixi', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            ),
          ),
          const SizedBox(height: 8),

          Expanded(
            child: myTxs.isEmpty
                ? const EmptyStateView(
                    title: 'Hali tranzaksiyalar yo‘q',
                    message: 'Coin topish uchun darslarga qatnashing, kitob o‘qing va bonuslar oling.',
                    icon: Icons.history,
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: myTxs.length,
                    itemBuilder: (context, index) {
                      final tx = myTxs[index];
                      bool isEarn = tx.type == 'earn';

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: CustomCard(
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: (isEarn ? AppColors.success : AppColors.error).withOpacity(0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  isEarn ? Icons.add : Icons.remove,
                                  color: isEarn ? AppColors.success : AppColors.error,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(tx.reason, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                                    const SizedBox(height: 4),
                                    Text(tx.date, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                                  ],
                                ),
                              ),
                              Text(
                                '${isEarn ? "+" : "-"}${tx.amount}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: isEarn ? AppColors.success : AppColors.error,
                                ),
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
