import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/app_repository.dart';
import '../models/user.dart';
import '../models/course.dart';
import '../models/group.dart';
import '../models/attendance.dart';
import '../models/book.dart';
import '../models/shop_item.dart';
import '../models/coin_transaction.dart';

final appRepositoryProvider = Provider<AppRepository>((ref) {
  throw UnimplementedError('Initialize AppRepository in ProviderScope override or main');
});

class CurrentUserNotifier extends StateNotifier<User?> {
  final AppRepository repository;
  CurrentUserNotifier(this.repository) : super(repository.getCurrentUser());

  void refresh() {
    state = repository.getCurrentUser();
  }

  void setUser(User? user) {
    state = user;
    repository.setCurrentUserId(user?.id);
  }
}

final currentUserProvider = StateNotifierProvider<CurrentUserNotifier, User?>((ref) {
  final repo = ref.watch(appRepositoryProvider);
  return CurrentUserNotifier(repo);
});

final usersProvider = StateNotifierProvider<UsersNotifier, List<User>>((ref) {
  final repo = ref.watch(appRepositoryProvider);
  return UsersNotifier(repo);
});

class UsersNotifier extends StateNotifier<List<User>> {
  final AppRepository repo;
  UsersNotifier(this.repo) : super(repo.getUsers());

  void refresh() {
    state = repo.getUsers();
  }
}

final coursesProvider = StateNotifierProvider<CoursesNotifier, List<Course>>((ref) {
  final repo = ref.watch(appRepositoryProvider);
  return CoursesNotifier(repo);
});

class CoursesNotifier extends StateNotifier<List<Course>> {
  final AppRepository repo;
  CoursesNotifier(this.repo) : super(repo.getCourses());

  void refresh() {
    state = repo.getCourses();
  }
}

final groupsProvider = StateNotifierProvider<GroupsNotifier, List<Group>>((ref) {
  final repo = ref.watch(appRepositoryProvider);
  return GroupsNotifier(repo);
});

class GroupsNotifier extends StateNotifier<List<Group>> {
  final AppRepository repo;
  GroupsNotifier(this.repo) : super(repo.getGroups());

  void refresh() {
    state = repo.getGroups();
  }
}

final attendancesProvider = StateNotifierProvider<AttendancesNotifier, List<Attendance>>((ref) {
  final repo = ref.watch(appRepositoryProvider);
  return AttendancesNotifier(repo);
});

class AttendancesNotifier extends StateNotifier<List<Attendance>> {
  final AppRepository repo;
  AttendancesNotifier(this.repo) : super(repo.getAttendances());

  void refresh() {
    state = repo.getAttendances();
  }
}

final booksProvider = StateNotifierProvider<BooksNotifier, List<Book>>((ref) {
  final repo = ref.watch(appRepositoryProvider);
  return BooksNotifier(repo);
});

class BooksNotifier extends StateNotifier<List<Book>> {
  final AppRepository repo;
  BooksNotifier(this.repo) : super(repo.getBooks());

  void refresh() {
    state = repo.getBooks();
  }
}

final shopItemsProvider = StateNotifierProvider<ShopItemsNotifier, List<ShopItem>>((ref) {
  final repo = ref.watch(appRepositoryProvider);
  return ShopItemsNotifier(repo);
});

class ShopItemsNotifier extends StateNotifier<List<ShopItem>> {
  final AppRepository repo;
  ShopItemsNotifier(this.repo) : super(repo.getShopItems());

  void refresh() {
    state = repo.getShopItems();
  }
}

final transactionsProvider = StateNotifierProvider<TransactionsNotifier, List<CoinTransaction>>((ref) {
  final repo = ref.watch(appRepositoryProvider);
  return TransactionsNotifier(repo);
});

class TransactionsNotifier extends StateNotifier<List<CoinTransaction>> {
  final AppRepository repo;
  TransactionsNotifier(this.repo) : super(repo.getTransactions());

  void refresh() {
    state = repo.getTransactions();
  }
}
