import 'package:intl/intl.dart';

class AppDateUtils {
  static String formatDate(DateTime date) =>
      DateFormat('dd/MM/yyyy', 'fr_FR').format(date);

  static String formatDateTime(DateTime date) =>
      DateFormat('dd/MM/yyyy HH:mm', 'fr_FR').format(date);

  static String formatTime(DateTime date) =>
      DateFormat('HH:mm', 'fr_FR').format(date);

  static String formatDayMonth(DateTime date) =>
      DateFormat('EEE d MMM', 'fr_FR').format(date);

  static String relativeTime(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'À l\'instant';
    if (diff.inHours < 1) return 'Il y a ${diff.inMinutes} min';
    if (diff.inDays < 1) return 'Il y a ${diff.inHours}h';
    if (diff.inDays < 7) return 'Il y a ${diff.inDays}j';
    return formatDate(date);
  }

  static List<DateTime> getWeekDays(DateTime date) {
    final monday = date.subtract(Duration(days: date.weekday - 1));
    return List.generate(5, (i) => monday.add(Duration(days: i)));
  }
}
