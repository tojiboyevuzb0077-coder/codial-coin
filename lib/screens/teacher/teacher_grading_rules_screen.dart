import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class _Rule {
  final String title;
  final int coins;
  final String description;
  final Color color;
  const _Rule(this.title, this.coins, this.description, this.color);
}

// Qoidalarni shu yerdan o'zgartirish mumkin
const List<_Rule> _rules = [
  _Rule('Hulq', 10, 'Dars davomida yaxshi xulq va hurmat uchun', Color(0xFF3B82F6)),
  _Rule('Imtihon', 500, 'Imtihonni muvaffaqiyatli topshirgani uchun', Color(0xFF6366F1)),
  _Rule('Vazifa', 100, 'Uy vazifasini to\'liq bajargani uchun', Color(0xFF10B981)),
  _Rule('Qatnashdi', 25, 'Darsda qatnashgani uchun', Color(0xFFEF4444)),
  _Rule('Vaqtida', 25, 'Darsga o\'z vaqtida kelgani uchun', Color(0xFFF59E0B)),
  _Rule('Faollik', 30, 'Darsda faol ishtirok etgani uchun', Color(0xFF06B6D4)),
  _Rule('O\'rganish', 100, 'Qo\'shimcha mavzuni mustaqil o\'rgangani uchun', Color(0xFF3B82F6)),
  _Rule('Kitob', 100, 'Kitob o\'qib tugatgani uchun', Color(0xFFEC4899)),
  _Rule('Tozalik', 25, 'Joyini toza saqlagani uchun', Color(0xFF0EA5E9)),
  _Rule('Podcast', 50, 'Podcast tinglab, xulosa yozgani uchun', Color(0xFF6366F1)),
];

class TeacherGradingRulesScreen extends StatelessWidget {
  const TeacherGradingRulesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Baholash Nizomi'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'O\'quvchilarga coin berish qoidalari',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          ..._rules.map((r) => _RuleCard(rule: r)),
        ],
      ),
    );
  }
}

class _RuleCard extends StatelessWidget {
  final _Rule rule;
  const _RuleCard({Key? key, required this.rule}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: rule.color.withOpacity(0.35)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: rule.color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '+${rule.coins}',
              style: TextStyle(
                color: rule.color,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  rule.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  rule.description,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}