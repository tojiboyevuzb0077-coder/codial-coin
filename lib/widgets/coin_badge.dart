import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CoinBadge extends StatelessWidget {
  final int coins;
  final double fontSize;
  final EdgeInsetsGeometry padding;

  const CoinBadge({
    Key? key,
    required this.coins,
    this.fontSize = 14,
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.primaryGold.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primaryGold.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.monetization_on,
            color: AppColors.primaryGold,
            size: 18,
          ),
          const SizedBox(width: 6),
          Text(
            '$coins',
            style: TextStyle(
              color: AppColors.primaryGold,
              fontWeight: FontWeight.bold,
              fontSize: fontSize,
            ),
          ),
        ],
      ),
    );
  }
}
