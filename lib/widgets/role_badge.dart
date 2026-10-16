import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class RoleBadge extends StatelessWidget {
  final String role; // 'admin', 'teacher', 'student'

  const RoleBadge({Key? key, required this.role}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;
    switch (role.toLowerCase()) {
      case 'admin':
        color = AppColors.error;
        label = 'Administrator';
        break;
      case 'teacher':
        color = AppColors.info;
        label = 'O‘qituvchi';
        break;
      case 'student':
      default:
        color = AppColors.success;
        label = 'O‘quvchi';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
