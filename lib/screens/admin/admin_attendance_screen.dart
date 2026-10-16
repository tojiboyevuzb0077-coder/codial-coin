import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/app_providers.dart';
import '../../theme/app_theme.dart';
import '../../models/group.dart';
import '../../models/user.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/empty_state_view.dart';
import '../../utils/date_formatter.dart';

class AdminAttendanceScreen extends ConsumerStatefulWidget {
  const AdminAttendanceScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AdminAttendanceScreen> createState() => _AdminAttendanceScreenState();
}

class _AdminAttendanceScreenState extends ConsumerState<AdminAttendanceScreen> with SingleTickerProviderStateMixin {
  Group? _selectedGroup;
  String _selectedDate = DateFormatter.todayString();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateFormatter.parseDate(_selectedDate),
      firstDate: DateTime(2023),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = DateFormatter.formatDate(picked);
      });
    }
  }

  void _markAllPresent() async {
    if (_selectedGroup == null) return;
    final repo = ref.read(appRepositoryProvider);
    final users = ref.read(usersProvider);
    final students = users.where((u) => _selectedGroup!.studentIds.contains(u.id)).toList();

    for (var st in students) {
      await repo.saveAttendanceRecord(
        groupId: _selectedGroup!.id,
        date: _selectedDate,
        studentId: st.id,
        status: 'present',
        isTeacher: false, // Admin attendance awards 0 coins as per specifications
      );
    }
    ref.read(attendancesProvider.notifier).refresh();
    _tabController.animateTo(0); // Switch to 'Present' tab
  }

  void _updateStatus(String studentId, String status) async {
    if (_selectedGroup == null) return;
    final repo = ref.read(appRepositoryProvider);
    await repo.saveAttendanceRecord(
      groupId: _selectedGroup!.id,
      date: _selectedDate,
      studentId: studentId,
      status: status,
      isTeacher: false, // Admin attendance awards 0 coins
    );
    ref.read(attendancesProvider.notifier).refresh();
  }

  @override
  Widget build(BuildContext context) {
    final groups = ref.watch(groupsProvider);
    final users = ref.watch(usersProvider);
    final attendances = ref.watch(attendancesProvider);

    if (_selectedGroup == null && groups.isNotEmpty) {
      _selectedGroup = groups.first;
    }

    final groupStudents = _selectedGroup == null
        ? <User>[]
        : users.where((u) => _selectedGroup!.studentIds.contains(u.id)).toList();

    final groupAttendances = attendances.where(
      (a) => _selectedGroup != null && a.groupId == _selectedGroup!.id && a.date == _selectedDate,
    ).toList();

    Map<String, String> statusMap = {for (var a in groupAttendances) a.studentId: a.status};

    int presentCount = statusMap.values.where((s) => s == 'present').length;
    int absentCount = statusMap.values.where((s) => s == 'absent').length;
    int lateCount = statusMap.values.where((s) => s == 'late').length;
    int bonusCount = statusMap.values.where((s) => s == 'bonus').length;

    List<User> filterStudents(String tabStatus) {
      if (tabStatus == 'all') return groupStudents;
      return groupStudents.where((st) {
        String stStatus = statusMap[st.id] ?? 'absent';
        return stStatus == tabStatus;
      }).toList();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin davomati'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primaryGold,
          labelColor: AppColors.primaryGold,
          unselectedLabelColor: AppColors.textSecondary,
          tabs: [
            Tab(text: 'Kelgan ($presentCount)'),
            Tab(text: 'Kelmagan ($absentCount)'),
            Tab(text: 'Kechikkan ($lateCount)'),
            Tab(text: 'Bonus ($bonusCount)'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Controls header
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: groups.isEmpty
                      ? const Text('Guruhlar mavjud emas', style: TextStyle(color: AppColors.textSecondary))
                      : DropdownButtonFormField<Group>(
                          value: _selectedGroup,
                          dropdownColor: AppColors.card,
                          decoration: const InputDecoration(labelText: 'Guruhni tanlang'),
                          items: groups.map((g) => DropdownMenuItem(
                            value: g,
                            child: Text(g.name, style: const TextStyle(color: AppColors.textPrimary)),
                          )).toList(),
                          onChanged: (g) => setState(() => _selectedGroup = g),
                        ),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: () => _pickDate(context),
                  icon: const Icon(Icons.calendar_today, size: 18),
                  label: Text(_selectedDate),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    side: const BorderSide(color: AppColors.border),
                  ),
                ),
              ],
            ),
          ),
          if (_selectedGroup != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      text: 'Barchasi kelgan',
                      icon: Icons.check_circle,
                      onPressed: _markAllPresent,
                      backgroundColor: AppColors.success,
                      textColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 8),

          // Student list by tabs
          Expanded(
            child: _selectedGroup == null
                ? const EmptyStateView(title: 'Guruhni tanlang', message: 'Davomat olish yoki tekshirish uchun guruhni tanlang.', icon: Icons.fact_check)
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildStudentList(filterStudents('present'), statusMap),
                      _buildStudentList(filterStudents('absent'), statusMap),
                      _buildStudentList(filterStudents('late'), statusMap),
                      _buildStudentList(filterStudents('bonus'), statusMap),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentList(List<User> students, Map<String, String> statusMap) {
    if (students.isEmpty) {
      return const EmptyStateView(
        title: 'Bu filtrda o‘quvchilar yo‘q',
        message: 'Bu statusga mos davomat yozuvlari yo‘q.',
        icon: Icons.people_outline,
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: students.length,
      itemBuilder: (context, index) {
        final st = students[index];
        final currentStatus = statusMap[st.id] ?? 'absent';

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: CustomCard(
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.card,
                  child: Text(st.name[0].toUpperCase(), style: const TextStyle(color: AppColors.primaryGold)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(st.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                      const SizedBox(height: 4),
                      Text('Status: ${currentStatus.toUpperCase()}', style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: currentStatus == 'present' ? AppColors.success :
                               currentStatus == 'absent' ? AppColors.error :
                               currentStatus == 'late' ? AppColors.warning : AppColors.primaryGold,
                      )),
                    ],
                  ),
                ),
                // Action status buttons
                ToggleButtons(
                  isSelected: [
                    currentStatus == 'present',
                    currentStatus == 'absent',
                    currentStatus == 'late',
                    currentStatus == 'bonus',
                  ],
                  onPressed: (idx) {
                    String newStatus = ['present', 'absent', 'late', 'bonus'][idx];
                    _updateStatus(st.id, newStatus);
                  },
                  borderRadius: BorderRadius.circular(8),
                  selectedColor: Colors.white,
                  fillColor: AppColors.primaryGold.withOpacity(0.3),
                  color: AppColors.textSecondary,
                  constraints: const BoxConstraints(minHeight: 36, minWidth: 44),
                  children: const [
                    Text('K', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('Y', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('G', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('B', style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
