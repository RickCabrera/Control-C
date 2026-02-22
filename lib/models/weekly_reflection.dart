import 'package:hive/hive.dart';

part 'weekly_reflection.g.dart';

@HiveType(typeId: 2)
class WeeklyReflection extends HiveObject {
  @HiveField(0)
  String weekKey; // formato 'YYYY-WNN' (año-semana ISO)

  @HiveField(1)
  bool pursuingRealPotential; // ¿Sigo persiguiendo algo con potencial real o solo me estoy entreteniendo?

  @HiveField(2)
  DateTime timestamp;

  WeeklyReflection({
    required this.weekKey,
    required this.pursuingRealPotential,
    required this.timestamp,
  });

  // Factory method to create a reflection for the current week
  factory WeeklyReflection.forCurrentWeek({
    required bool pursuingRealPotential,
  }) {
    final now = DateTime.now();
    final weekKey = _getWeekKey(now);

    return WeeklyReflection(
      weekKey: weekKey,
      pursuingRealPotential: pursuingRealPotential,
      timestamp: now,
    );
  }

  // Factory method to create a reflection for a specific date
  factory WeeklyReflection.forDate({
    required DateTime date,
    required bool pursuingRealPotential,
  }) {
    final weekKey = _getWeekKey(date);

    return WeeklyReflection(
      weekKey: weekKey,
      pursuingRealPotential: pursuingRealPotential,
      timestamp: DateTime.now(),
    );
  }

  // Generate week key in format 'YYYY-WNN'
  static String _getWeekKey(DateTime date) {
    // Calculate ISO week number
    final year = date.year;
    final month = date.month;
    final day = date.day;

    // Find Thursday of this week (ISO 8601 definition)
    final dayOfWeek = date.weekday; // Monday = 1, Sunday = 7
    final thursday = date.subtract(Duration(days: dayOfWeek - 4));

    // Get the year of the Thursday (this is the ISO year)
    final isoYear = thursday.year;

    // Find the first Thursday of the ISO year
    final jan4 = DateTime(isoYear, 1, 4);
    final firstThursday = jan4.subtract(Duration(days: jan4.weekday - 4));

    // Calculate week number
    final weekNumber = ((thursday.difference(firstThursday).inDays / 7).floor() + 1);

    return '$isoYear-W${weekNumber.toString().padLeft(2, '0')}';
  }

  // Get year from week key
  int get year => int.parse(weekKey.split('-')[0]);

  // Get week number from week key
  int get weekNumber => int.parse(weekKey.split('-')[1].substring(1));

  // Check if this reflection is for the current week
  bool get isCurrentWeek => weekKey == _getWeekKey(DateTime.now());

  @override
  String toString() {
    return 'WeeklyReflection(weekKey: $weekKey, pursuingRealPotential: $pursuingRealPotential, timestamp: $timestamp)';
  }
}
