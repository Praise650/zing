/// Pure formatting helpers.
abstract final class Formatters {
  /// 252 seconds -> "4:12".
  static String duration(int seconds) =>
      '${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}';

  /// 760 minutes -> "12h 40m". Under an hour -> "45m".
  static String studyTime(int minutes) {
    final h = minutes ~/ 60, m = minutes % 60;
    return h == 0 ? '${m}m' : '${h}h ${m}m';
  }

  static int percent(int correct, int total) =>
      total == 0 ? 0 : ((correct / total) * 100).round();

  static String greeting(DateTime now) {
    if (now.hour < 12) return 'Good morning';
    if (now.hour < 18) return 'Good afternoon';
    return 'Good evening';
  }
}
