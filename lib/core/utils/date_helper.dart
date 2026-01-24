import 'package:intl/intl.dart';

import '../constants/app_constants.dart';

class DateHelper {
  // Format date for display
  static String formatDisplayDate(DateTime date) {
    return DateFormat(AppConstants.displayDateFormat).format(date);
  }

  // Format date for API
  static String formatApiDate(DateTime date) {
    return DateFormat(AppConstants.apiDateFormat).format(date);
  }

  // Format date time for display
  static String formatDisplayDateTime(DateTime dateTime) {
    return DateFormat(AppConstants.displayDateTimeFormat).format(dateTime);
  }

  // Parse API date string
  static DateTime? parseApiDate(String? dateString) {
    if (dateString == null) return null;
    try {
      return DateTime.parse(dateString);
    } catch (e) {
      return null;
    }
  }

  // Get days until date
  static int daysUntil(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(DateTime(now.year, now.month, now.day));
    return difference.inDays;
  }

  // Get days between dates
  static int daysBetween(DateTime from, DateTime to) {
    from = DateTime(from.year, from.month, from.day);
    to = DateTime(to.year, to.month, to.day);
    return to.difference(from).inDays;
  }

  // Check if date is today
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  // Check if date is tomorrow
  static bool isTomorrow(DateTime date) {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return date.year == tomorrow.year &&
        date.month == tomorrow.month &&
        date.day == tomorrow.day;
  }

  // Check if date is within range
  static bool isWithinDays(DateTime date, int days) {
    final daysRemaining = daysUntil(date);
    return daysRemaining >= 0 && daysRemaining <= days;
  }

  // Get relative time string (e.g., "in 7 days", "tomorrow")
  static String getRelativeTimeString(DateTime date) {
    final days = daysUntil(date);

    if (days < 0) {
      final absDays = days.abs();
      if (absDays == 1) return 'Yesterday';
      return '$absDays days ago';
    } else if (days == 0) {
      return 'Today';
    } else if (days == 1) {
      return 'Tomorrow';
    } else if (days <= 7) {
      return 'In $days days';
    } else if (days <= 30) {
      final weeks = (days / 7).floor();
      return 'In $weeks ${weeks == 1 ? 'week' : 'weeks'}';
    } else if (days <= 365) {
      final months = (days / 30).floor();
      return 'In $months ${months == 1 ? 'month' : 'months'}';
    } else {
      final years = (days / 365).floor();
      return 'In $years ${years == 1 ? 'year' : 'years'}';
    }
  }

  // Get month name
  static String getMonthName(int month) {
    return DateFormat('MMMM').format(DateTime(2000, month));
  }

  // Get short month name
  static String getShortMonthName(int month) {
    return DateFormat('MMM').format(DateTime(2000, month));
  }

  // Add months to date
  static DateTime addMonths(DateTime date, int months) {
    return DateTime(
      date.year,
      date.month + months,
      date.day,
      date.hour,
      date.minute,
      date.second,
    );
  }

  // Add years to date
  static DateTime addYears(DateTime date, int years) {
    return DateTime(
      date.year + years,
      date.month,
      date.day,
      date.hour,
      date.minute,
      date.second,
    );
  }

  // Get start of month
  static DateTime startOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }

  // Get end of month
  static DateTime endOfMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0, 23, 59, 59);
  }

  // Get start of year
  static DateTime startOfYear(DateTime date) {
    return DateTime(date.year, 1, 1);
  }

  // Get end of year
  static DateTime endOfYear(DateTime date) {
    return DateTime(date.year, 12, 31, 23, 59, 59);
  }
}
