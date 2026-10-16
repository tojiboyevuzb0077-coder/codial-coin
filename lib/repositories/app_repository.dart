import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../models/course.dart';
import '../models/group.dart';
import '../models/attendance.dart';
import '../models/book.dart';
import '../models/shop_item.dart';
import '../models/coin_transaction.dart';
import '../utils/date_formatter.dart';

class AppRepository {
  late SharedPreferences _prefs;

  static const String keyUsers = 'users';
  static const String keyCourses = 'courses';
  static const String keyGroups = 'groups';
  static const String keyAttendances = 'attendances';
  static const String keyBooks = 'books';
  static const String keyShopItems = 'shop_items';
  static const String keyTransactions = 'transactions';
  static const String keyCurrentUserId = 'current_user_id';

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // --- Auth & Users ---
  List<User> getUsers() {
    final String? data = _prefs.getString(keyUsers);
    if (data == null) return [];
    final List list = json.decode(data);
    return list.map((e) => User.fromJson(e)).toList();
  }

  Future<void> saveUsers(List<User> users) async {
    final String data = json.encode(users.map((e) => e.toJson()).toList());
    await _prefs.setString(keyUsers, data);
  }

  User? getCurrentUser() {
    final String? userId = _prefs.getString(keyCurrentUserId);
    if (userId == null) return null;
    final users = getUsers();
    try {
      return users.firstWhere((u) => u.id == userId);
    } catch (_) {
      return null;
    }
  }

  Future<void> setCurrentUserId(String? userId) async {
    if (userId == null) {
      await _prefs.remove(keyCurrentUserId);
    } else {
      await _prefs.setString(keyCurrentUserId, userId);
    }
  }

  User? login(String login, String password) {
    final users = getUsers();
    try {
      final user = users.firstWhere(
        (u) => u.login.trim().toLowerCase() == login.trim().toLowerCase() && u.password == password,
      );
      setCurrentUserId(user.id);
      return user;
    } catch (_) {
      return null;
    }
  }

  Future<void> registerUser(User user) async {
    final users = getUsers();
    users.add(user);
    await saveUsers(users);
  }

  Future<void> updateUser(User updatedUser) async {
    final users = getUsers();
    final index = users.indexWhere((u) => u.id == updatedUser.id);
    if (index != -1) {
      users[index] = updatedUser;
      await saveUsers(users);
    }
  }

  Future<void> deleteUser(String userId) async {
    final users = getUsers();
    users.removeWhere((u) => u.id == userId);
    await saveUsers(users);
    // Also remove from groups studentIds or teacherId
    final groups = getGroups();
    for (int i = 0; i < groups.length; i++) {
      var g = groups[i];
      var newStudents = g.studentIds.where((id) => id != userId).toList();
      String teacherId = g.teacherId == userId ? '' : g.teacherId;
      groups[i] = g.copyWith(studentIds: newStudents, teacherId: teacherId);
    }
    await saveGroups(groups);
  }

  // --- Courses ---
  List<Course> getCourses() {
    final String? data = _prefs.getString(keyCourses);
    if (data == null) return [];
    final List list = json.decode(data);
    return list.map((e) => Course.fromJson(e)).toList();
  }

  Future<void> saveCourses(List<Course> courses) async {
    final String data = json.encode(courses.map((e) => e.toJson()).toList());
    await _prefs.setString(keyCourses, data);
  }

  Future<void> addOrUpdateCourse(Course course) async {
    final courses = getCourses();
    final index = courses.indexWhere((c) => c.id == course.id);
    if (index != -1) {
      courses[index] = course;
    } else {
      courses.add(course);
    }
    await saveCourses(courses);
  }

  Future<void> deleteCourse(String courseId) async {
    final courses = getCourses();
    courses.removeWhere((c) => c.id == courseId);
    await saveCourses(courses);
  }

  // --- Groups ---
  List<Group> getGroups() {
    final String? data = _prefs.getString(keyGroups);
    if (data == null) return [];
    final List list = json.decode(data);
    return list.map((e) => Group.fromJson(e)).toList();
  }

  Future<void> saveGroups(List<Group> groups) async {
    final String data = json.encode(groups.map((e) => e.toJson()).toList());
    await _prefs.setString(keyGroups, data);
  }

  Future<void> addOrUpdateGroup(Group group) async {
    final groups = getGroups();
    final index = groups.indexWhere((g) => g.id == group.id);
    if (index != -1) {
      groups[index] = group;
    } else {
      groups.add(group);
    }
    await saveGroups(groups);
  }

  Future<void> deleteGroup(String groupId) async {
    final groups = getGroups();
    groups.removeWhere((g) => g.id == groupId);
    await saveGroups(groups);
  }

  // --- Attendance ---
  List<Attendance> getAttendances() {
    final String? data = _prefs.getString(keyAttendances);
    if (data == null) return [];
    final List list = json.decode(data);
    return list.map((e) => Attendance.fromJson(e)).toList();
  }

  Future<void> saveAttendances(List<Attendance> attendances) async {
    final String data = json.encode(attendances.map((e) => e.toJson()).toList());
    await _prefs.setString(keyAttendances, data);
  }

  /// Records or updates attendance.
  /// Business logic:
  /// - Teacher marking "Present" -> +10 coins ("Darsga qatnashdi (+10 coin)"), awarded only on first transition to present.
  /// - Admin attendance awards 0.
  Future<void> saveAttendanceRecord({
    required String groupId,
    required String date,
    required String studentId,
    required String status,
    required bool isTeacher,
  }) async {
    final attendances = getAttendances();
    final existingIndex = attendances.indexWhere(
      (a) => a.groupId == groupId && a.date == date && a.studentId == studentId,
    );

    bool wasPresentBefore = false;
    if (existingIndex != -1) {
      wasPresentBefore = attendances[existingIndex].status == 'present' && attendances[existingIndex].awarded;
    }

    bool shouldAward = isTeacher && status == 'present' && !wasPresentBefore;
    bool awarded = wasPresentBefore || (isTeacher && status == 'present');

    if (existingIndex != -1) {
      attendances[existingIndex] = attendances[existingIndex].copyWith(
        status: status,
        awarded: awarded,
      );
    } else {
      attendances.add(Attendance(
        id: DateTime.now().millisecondsSinceEpoch.toString() + '_' + studentId,
        groupId: groupId,
        date: date,
        studentId: studentId,
        status: status,
        awarded: shouldAward,
      ));
    }

    await saveAttendances(attendances);

    if (shouldAward) {
      await addCoinsToUser(
        studentId,
        10,
        'Darsga qatnashdi (+10 coin)',
      );
    }
  }

  // --- Books ---
  List<Book> getBooks() {
    final String? data = _prefs.getString(keyBooks);
    if (data == null) return [];
    final List list = json.decode(data);
    return list.map((e) => Book.fromJson(e)).toList();
  }

  Future<void> saveBooks(List<Book> books) async {
    final String data = json.encode(books.map((e) => e.toJson()).toList());
    await _prefs.setString(keyBooks, data);
  }

  Future<void> addBook(Book book) async {
    final books = getBooks();
    books.add(book);
    await saveBooks(books);
  }

  /// Student marking book "Finished" -> +50 coins, calculates daysCount.
  Future<void> finishBook(String bookId) async {
    final books = getBooks();
    final index = books.indexWhere((b) => b.id == bookId);
    if (index != -1) {
      final book = books[index];
      if (book.status == 'finished') return; // already finished

      final today = DateFormatter.todayString();
      int days = DateFormatter.daysBetween(book.startDate, today);
      if (days < 0) days = 0;

      books[index] = book.copyWith(
        status: 'finished',
        finishDate: today,
        daysCount: days,
        coinsEarned: 50,
      );
      await saveBooks(books);

      await addCoinsToUser(
        book.studentId,
        50,
        'Kitob o‘qib tugatildi: ${book.title} (+50 coin)',
      );
    }
  }

  // --- Shop Items ---
  List<ShopItem> getShopItems() {
    final String? data = _prefs.getString(keyShopItems);
    if (data == null) return [];
    final List list = json.decode(data);
    return list.map((e) => ShopItem.fromJson(e)).toList();
  }

  Future<void> saveShopItems(List<ShopItem> items) async {
    final String data = json.encode(items.map((e) => e.toJson()).toList());
    await _prefs.setString(keyShopItems, data);
  }

  Future<void> addOrUpdateShopItem(ShopItem item) async {
    final items = getShopItems();
    final index = items.indexWhere((i) => i.id == item.id);
    if (index != -1) {
      items[index] = item;
    } else {
      items.add(item);
    }
    await saveShopItems(items);
  }

  Future<void> deleteShopItem(String itemId) async {
    final items = getShopItems();
    items.removeWhere((i) => i.id == itemId);
    await saveShopItems(items);
  }

  // --- Transactions ---
  List<CoinTransaction> getTransactions() {
    final String? data = _prefs.getString(keyTransactions);
    if (data == null) return [];
    final List list = json.decode(data);
    return list.map((e) => CoinTransaction.fromJson(e)).toList();
  }

  Future<void> saveTransactions(List<CoinTransaction> txs) async {
    final String data = json.encode(txs.map((e) => e.toJson()).toList());
    await _prefs.setString(keyTransactions, data);
  }

  Future<void> addCoinsToUser(String userId, int amount, String reason) async {
    final users = getUsers();
    final userIndex = users.indexWhere((u) => u.id == userId);
    if (userIndex != -1) {
      final user = users[userIndex];
      users[userIndex] = user.copyWith(coins: user.coins + amount);
      await saveUsers(users);

      final txs = getTransactions();
      txs.add(CoinTransaction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userId,
        amount: amount,
        reason: reason,
        date: DateFormatter.formatDateTime(DateTime.now()),
        type: 'earn',
      ));
      await saveTransactions(txs);
    }
  }

  /// Shop purchase -> checks balance & stock, deducts coins, reduces stock, creates transaction.
  Future<String?> purchaseShopItem(String userId, String itemId) async {
    final users = getUsers();
    final userIndex = users.indexWhere((u) => u.id == userId);
    if (userIndex == -1) return 'Foydalanuvchi topilmadi';
    final user = users[userIndex];

    final items = getShopItems();
    final itemIndex = items.indexWhere((i) => i.id == itemId);
    if (itemIndex == -1) return 'Buyum topilmadi';
    final item = items[itemIndex];

    if (item.stock <= 0) return 'Buyum omborda qolmagan';
    if (user.coins < item.price) return 'Coinlar balansi yetarli emas';

    // Deduct coins
    users[userIndex] = user.copyWith(coins: user.coins - item.price);
    await saveUsers(users);

    // Reduce stock
    items[itemIndex] = item.copyWith(stock: item.stock - 1);
    await saveShopItems(items);

    // Create transaction
    final txs = getTransactions();
    txs.add(CoinTransaction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      amount: item.price,
      reason: 'Sotib olindi: ${item.name}',
      date: DateFormatter.formatDateTime(DateTime.now()),
      type: 'spend',
    ));
    await saveTransactions(txs);

    return null; // success
  }

  // Admin bonus coins
  Future<void> awardBonusCoins(String userId, int amount, String reason) async {
    await addCoinsToUser(userId, amount, 'Bonus: $reason (+$amount coin)');
  }
}
