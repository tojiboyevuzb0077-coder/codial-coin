import 'package:intl/intl.dart';

class DateFormatter {
  static final List<String> weekdaysShort = ['Du', 'Se', 'Ch', 'Pa', 'Ju', 'Sh', 'Ya'];
  
  static String formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  static String formatDisplayDate(DateTime date) {
    return DateFormat('dd MMM yyyy', 'en_US').format(date);
  }

  static String formatDateTime(DateTime date) {
    return DateFormat('yyyy-MM-dd HH:mm', 'en_US').format(date);
  }

  static String getWeekdayShort(DateTime date) {
    // 1 = Monday, ..., 7 = Sunday
    int weekday = date.weekday; 
    switch (weekday) {
      case 1: return 'Du';
      case 2: return 'Se';
      case 3: return 'Ch';
      case 4: return 'Pa';
      case 5: return 'Ju';
      case 6: return 'Sh';
      case 7: return 'Ya';
      default: return 'Du';
    }
  }

  static int daysBetween(String startDateStr, String endDateStr) {
    try {
      DateTime start = DateTime.parse(startDateStr);
      DateTime end = DateTime.parse(endDateStr);
      return end.difference(start).inDays;
    } catch (_) {
      return 0;
    }
  }

  static String todayString() {
    return formatDate(DateTime.now());
  }

  static DateTime parseDate(String dateStr) {
    try {
      return DateTime.parse(dateStr);
    } catch (_) {
      return DateTime.now();
    }
  }
}
