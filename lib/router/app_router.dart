import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/app_providers.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/first_setup_screen.dart';
import '../screens/admin/admin_dashboard_screen.dart';
import '../screens/admin/admin_teachers_screen.dart';
import '../screens/admin/admin_students_screen.dart';
import '../screens/admin/admin_groups_screen.dart';
import '../screens/admin/admin_courses_screen.dart';
import '../screens/admin/admin_attendance_screen.dart';
import '../screens/admin/admin_shop_screen.dart';
import '../screens/teacher/teacher_dashboard_screen.dart';
import '../screens/teacher/teacher_groups_screen.dart';
import '../screens/teacher/teacher_attendance_screen.dart';
import '../screens/teacher/teacher_group_students_screen.dart';
import '../screens/student/student_dashboard_screen.dart';
import '../screens/student/student_rating_screen.dart';
import '../screens/student/student_books_screen.dart';
import '../screens/student/student_shop_screen.dart';
import '../screens/student/student_coins_screen.dart';
import '../screens/student/student_profile_screen.dart';
import '../screens/student/student_news_screen.dart';
import '../screens/student/student_rules_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final repo = ref.watch(appRepositoryProvider);

  return GoRouter(
    initialLocation: '/admin',
    redirect: (context, state) {
      final users = repo.getUsers();
      final currentUser = repo.getCurrentUser();
      final isAuthRoute = state.uri.path == '/login' || state.uri.path == '/first_setup';

      if (users.isEmpty) {
        return state.uri.path == '/first_setup' ? null : '/first_setup';
      }

      if (currentUser == null) {
        return isAuthRoute ? null : '/login';
      }

      if (isAuthRoute) {
        if (currentUser.role == 'admin') return '/admin';
        if (currentUser.role == 'teacher') return '/teacher';
        return '/student';
      }

      // Role based route protection
      if (state.uri.path.startsWith('/admin') && currentUser.role != 'admin') {
        if (currentUser.role == 'teacher') return '/teacher';
        return '/student';
      }
      if (state.uri.path.startsWith('/teacher') && currentUser.role != 'teacher') {
        if (currentUser.role == 'admin') return '/admin';
        return '/student';
      }
      if (state.uri.path.startsWith('/student') && currentUser.role != 'student') {
        if (currentUser.role == 'admin') return '/admin';
        return '/teacher';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/first_setup',
        builder: (context, state) => const FirstSetupScreen(),
      ),
      // Admin routes
      GoRoute(
        path: '/admin',
        builder: (context, state) => const AdminDashboardScreen(),
      ),
      GoRoute(
        path: '/admin/teachers',
        builder: (context, state) => const AdminTeachersScreen(),
      ),
      GoRoute(
        path: '/admin/students',
        builder: (context, state) => const AdminStudentsScreen(),
      ),
      GoRoute(
        path: '/admin/groups',
        builder: (context, state) => const AdminGroupsScreen(),
      ),
      GoRoute(
        path: '/admin/courses',
        builder: (context, state) => const AdminCoursesScreen(),
      ),
      GoRoute(
        path: '/admin/attendance',
        builder: (context, state) => const AdminAttendanceScreen(),
      ),
      GoRoute(
        path: '/admin/shop',
        builder: (context, state) => const AdminShopScreen(),
      ),

      // Teacher routes
      GoRoute(
        path: '/teacher',
        builder: (context, state) => const TeacherDashboardScreen(),
      ),
      GoRoute(
        path: '/teacher/groups',
        builder: (context, state) => const TeacherGroupsScreen(),
      ),
      GoRoute(
        path: '/teacher/attendance',
        builder: (context, state) => const TeacherAttendanceScreen(),
      ),
      GoRoute(
        path: '/teacher/group_students',
        builder: (context, state) => const TeacherGroupStudentsScreen(),
      ),

      // Student routes
      GoRoute(
        path: '/student',
        builder: (context, state) => const StudentDashboardScreen(),
      ),
      GoRoute(
        path: '/student/rating',
        builder: (context, state) => const StudentRatingScreen(),
      ),
      GoRoute(
        path: '/student/books',
        builder: (context, state) => const StudentBooksScreen(),
      ),
      GoRoute(
        path: '/student/shop',
        builder: (context, state) => const StudentShopScreen(),
      ),
      GoRoute(
        path: '/student/coins',
        builder: (context, state) => const StudentCoinsScreen(),
      ),
      GoRoute(
        path: '/student/profile',
        builder: (context, state) => const StudentProfileScreen(),
      ),
      GoRoute(
        path: '/student/news',
        builder: (context, state) => const StudentNewsScreen(),
      ),
      GoRoute(
        path: '/student/rules',
        builder: (context, state) => const StudentRulesScreen(),
      ),
    ],
  );
});
