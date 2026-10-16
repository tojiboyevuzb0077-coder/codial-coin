import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_card.dart';

class StudentNewsScreen extends StatelessWidget {
  const StudentNewsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final newsList = [
      {
        'title': 'Yangi qishki kurslar e’lon qilindi!',
        'date': '2026-10-15',
        'badge': 'E’lon',
        'content': 'Kelasi oydan boshlab ilg‘or Flutter va Python kurslarini boshlaymiz. Hozir admin orqali ro‘yxatdan o‘ting!',
      },
      {
        'title': 'Sovg‘alar do‘koni to‘ldirildi!',
        'date': '2026-10-12',
        'badge': 'Do‘kon',
        'content': 'O‘quvchilar do‘koniga yangi mexanik klaviaturalar, brend hudi va aqlli gadjetlar qo‘shildi.',
      },
      {
        'title': 'Dasturlash marafoni - Xakaton',
        'date': '2026-10-05',
        'badge': 'Tadbir',
        'content': 'Dam olish kunlaridagi xakatonda qatnashing va jamoangiz uchun 500 tagacha bonus coin yutib oling!',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('So‘nggi yangiliklar'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: newsList.length,
        itemBuilder: (context, index) {
          final news = newsList[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: CustomCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.info.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.info.withOpacity(0.4)),
                        ),
                        child: Text(news['badge']!, style: const TextStyle(color: AppColors.info, fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                      Text(news['date']!, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(news['title']!, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  const SizedBox(height: 8),
                  Text(news['content']!, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
