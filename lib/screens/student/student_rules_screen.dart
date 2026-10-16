import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_card.dart';

class StudentRulesScreen extends StatelessWidget {
  const StudentRulesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final rulesList = [
      {'title': 'Darsga qatnashish', 'coins': '+10 coin', 'desc': 'O‘qituvchingiz bugungi darsda sizni Kelgan deb belgilaganda beriladi.'},
      {'title': 'Kitob o‘qib tugatish', 'coins': '+50 coin', 'desc': 'Kitobni o‘qib tugatib, profilingizda yakunlangan deb belgilaganingizda beriladi.'},
      {'title': 'Admin bonus mukofoti', 'coins': 'O‘zgaruvchan', 'desc': 'Faolligingiz yoki yutuqlaringiz uchun administratorlar tomonidan beriladigan maxsus bonuslar.'},
      {'title': 'Do‘kondan xarid qilish', 'coins': 'Buyum narxi', 'desc': 'Mehnat qilib topgan coinlaringizni do‘kondagi eksklyuziv sovg‘alar va mahsulotlarga sarflang.'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Qoidalar va coin qo‘llanmasi'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: rulesList.length,
        itemBuilder: (context, index) {
          final rule = rulesList[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
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
                    child: const Icon(Icons.monetization_on, color: AppColors.primaryGold, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(rule['title']!, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.primaryGold.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(rule['coins']!, style: const TextStyle(color: AppColors.primaryGold, fontWeight: FontWeight.bold, fontSize: 12)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(rule['desc']!, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                      ],
                    ),
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
