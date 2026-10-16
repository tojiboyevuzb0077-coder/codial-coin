import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/app_providers.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';
import '../../widgets/logout_dialog.dart';
import '../../utils/validators.dart';
import '../../models/user.dart';

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> {
  void _showAddUserDialog(BuildContext context, WidgetRef ref, String role) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final loginController = TextEditingController();
    final passwordController = TextEditingController();
    final phoneController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.border),
        ),
        title: Text(
          role == 'student' ? 'Yangi o‘quvchi qo‘shish' : 'Yangi o‘qituvchi qo‘shish',
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
                    label: 'To‘liq ism',
                    validator: (v) => Validators.required(v, 'Ism'),
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    controller: loginController,
                    label: 'Login',
                    validator: (v) => Validators.required(v, 'Login'),
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    controller: passwordController,
                    label: 'Parol',
                    obscureText: true,
                    validator: (v) => Validators.required(v, 'Parol'),
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    controller: phoneController,
                    label: 'Telefon',
                    keyboardType: TextInputType.phone,
                    validator: (v) => Validators.required(v, 'Telefon'),
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
              final newUser = User(
                id: '${role}_${DateTime.now().millisecondsSinceEpoch}',
                name: nameController.text.trim(),
                login: loginController.text.trim().toLowerCase(),
                password: passwordController.text.trim(),
                role: role,
                phone: phoneController.text.trim(),
                coins: role == 'student' ? 50 : 0,
              );
              await repo.registerUser(newUser);
              ref.read(usersProvider.notifier).refresh();
              if (ctx.mounted) Navigator.pop(ctx);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(role == 'student' ? 'O‘quvchi muvaffaqiyatli qo‘shildi!' : 'O‘qituvchi muvaffaqiyatli qo‘shildi!')),
                );
              }
            },
            child: const Text('Qo‘shish'),
          ),
        ],
      ),
    );
  }

  void _showAwardBonusDialog(BuildContext context, WidgetRef ref) {
    final formKey = GlobalKey<FormState>();
    final amountController = TextEditingController();
    final reasonController = TextEditingController();
    String? selectedStudentId;

    final users = ref.read(usersProvider).where((u) => u.role == 'student').toList();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setStateSB) => AlertDialog(
          backgroundColor: AppColors.card,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppColors.border),
          ),
          title: const Text(
            'Bonus coin berish',
            style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
          ),
          content: SizedBox(
            width: 400,
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      value: selectedStudentId,
                      dropdownColor: AppColors.card,
                      decoration: const InputDecoration(labelText: 'O‘quvchini tanlang'),
                      items: users.map((s) => DropdownMenuItem(
                        value: s.id,
                        child: Text(s.name, style: const TextStyle(color: AppColors.textPrimary)),
                      )).toList(),
                      onChanged: (v) => setStateSB(() => selectedStudentId = v),
                      validator: (v) => v == null ? 'Iltimos, o‘quvchini tanlang' : null,
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      controller: amountController,
                      label: 'Coin miqdori',
                      keyboardType: TextInputType.number,
                      validator: (v) => Validators.positiveNumber(v, 'Miqdor'),
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      controller: reasonController,
                      label: 'Sabab',
                      validator: (v) => Validators.required(v, 'Sabab'),
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
                if (!formKey.currentState!.validate() || selectedStudentId == null) return;
                final repo = ref.read(appRepositoryProvider);
                int amount = int.parse(amountController.text.trim());
                await repo.awardBonusCoins(selectedStudentId!, amount, reasonController.text.trim());
                ref.read(usersProvider.notifier).refresh();
                ref.read(transactionsProvider.notifier).refresh();
                if (ctx.mounted) Navigator.pop(ctx);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Bonus coinlar muvaffaqiyatli berildi!')),
                  );
                }
              },
              child: const Text('Berish'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final users = ref.watch(usersProvider);
    final groups = ref.watch(groupsProvider);

    final studentsCount = users.where((u) => u.role == 'student').length;
    final teachersCount = users.where((u) => u.role == 'teacher').length;
    final totalCoins = users.fold<int>(0, (sum, u) => sum + u.coins);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Boshqaruv paneli - Codial Coin'),
        actions: [
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
            // Welcome banner
            CustomCard(
              backgroundColor: AppColors.card,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGold.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.admin_panel_settings, size: 36, color: AppColors.primaryGold),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Administrator portali',
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Foydalanuvchilar, kurslar, guruhlar, davomat va sovg‘alar do‘konini boshqaring.',
                          style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Stats grid
            LayoutBuilder(
              builder: (context, constraints) {
                bool isWide = constraints.maxWidth > 600;
                return GridView.count(
                  crossAxisCount: isWide ? 4 : 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 1.5,
                  children: [
                    _buildStatCard('O‘quvchilar', '$studentsCount', Icons.school, AppColors.success),
                    _buildStatCard('O‘qituvchilar', '$teachersCount', Icons.person, AppColors.info),
                    _buildStatCard('Guruhlar', '${groups.length}', Icons.group, AppColors.warning),
                    _buildStatCard('Jami coinlar', '$totalCoins', Icons.monetization_on, AppColors.primaryGold),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),

            // Quick Actions / Management Sections
            const Text(
              'Boshqaruv',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 16),

            LayoutBuilder(
              builder: (context, constraints) {
                bool isWide = constraints.maxWidth > 700;
                return GridView.count(
                  crossAxisCount: isWide ? 3 : 1,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: isWide ? 2.2 : 3.5,
                  children: [
                    _buildMenuCard(context, 'O‘quvchilar', 'O‘quvchilar va ma’lumotlarni boshqarish', Icons.school, '/admin/students', AppColors.success),
                    _buildMenuCard(context, 'O‘qituvchilar', 'O‘qituvchilarni boshqarish', Icons.person_pin, '/admin/teachers', AppColors.info),
                    _buildMenuCard(context, 'Guruhlar', 'Darslar va jadvalni boshqarish', Icons.group_work, '/admin/groups', AppColors.warning),
                    _buildMenuCard(context, 'Kurslar', 'Kurslar katalogi va narxlarni boshqarish', Icons.book, '/admin/courses', AppColors.primaryGold),
                    _buildMenuCard(context, 'Davomat', 'Davomatni yuritish va tekshirish', Icons.fact_check, '/admin/attendance', Colors.purpleAccent),
                    _buildMenuCard(context, 'Sovg‘alar do‘koni', 'Mukofotlar va do‘kon mahsulotlarini boshqarish', Icons.card_giftcard, '/admin/shop', Colors.tealAccent),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),

            // Action Buttons
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                CustomButton(
                  text: 'O‘quvchi qo‘shish',
                  icon: Icons.person_add,
                  onPressed: () => _showAddUserDialog(context, ref, 'student'),
                ),
                CustomButton(
                  text: 'O‘qituvchi qo‘shish',
                  icon: Icons.person_add_alt_1,
                  onPressed: () => _showAddUserDialog(context, ref, 'teacher'),
                  backgroundColor: AppColors.info,
                  textColor: Colors.white,
                ),
                CustomButton(
                  text: 'Bonus coin berish',
                  icon: Icons.card_giftcard,
                  onPressed: () => _showAwardBonusDialog(context, ref),
                  backgroundColor: AppColors.warning,
                  textColor: Colors.white,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return CustomCard(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
              Icon(icon, color: color, size: 20),
            ],
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context, String title, String subtitle, IconData icon, String route, Color accentColor) {
    return CustomCard(
      onTap: () => context.go(route),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: accentColor, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textSecondary),
        ],
      ),
    );
  }
}
