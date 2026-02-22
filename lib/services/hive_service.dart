import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import '../models/user_config.dart';
import '../models/daily_checkin.dart';
import '../models/weekly_reflection.dart';

class HiveService {
  static const String _userConfigBox = 'user_config';
  static const String _dailyCheckinsBox = 'daily_checkins';
  static const String _weeklyReflectionsBox = 'weekly_reflections';
  static const String _dailyPrioritiesBox = 'daily_priorities';
  static const String _configKey = 'config';

  static Box<UserConfig>? _userBox;
  static Box<DailyCheckIn>? _checkinsBox;
  static Box<WeeklyReflection>? _weeklyBox;
  static Box<String>? _prioritiesBox;

  static Future<void> init([String? path]) async {
    if (path != null) {
      await Hive.initFlutter(path);
    } else {
      await Hive.initFlutter();
    }

    // Register adapters
    Hive.registerAdapter(UserConfigAdapter());
    Hive.registerAdapter(DailyCheckInAdapter());
    Hive.registerAdapter(WeeklyReflectionAdapter());

    // Open boxes
    _userBox = await Hive.openBox<UserConfig>(_userConfigBox);
    _checkinsBox = await Hive.openBox<DailyCheckIn>(_dailyCheckinsBox);
    _weeklyBox = await Hive.openBox<WeeklyReflection>(_weeklyReflectionsBox);
    _prioritiesBox = await Hive.openBox<String>(_dailyPrioritiesBox);
  }

  // User Config methods
  static UserConfig? getUserConfig() {
    return _userBox?.get(_configKey);
  }

  static Future<void> saveUserConfig(UserConfig config) async {
    await _userBox?.put(_configKey, config);
  }

  static bool hasUserConfig() {
    return _userBox?.containsKey(_configKey) ?? false;
  }

  static Future<void> updateCheckinTime(int hour, int minute) async {
    final config = getUserConfig();
    if (config != null) {
      config.checkinHour = hour;
      config.checkinMinute = minute;
      await config.save();
    }
  }

  // Daily CheckIn methods
  static String _getTodayKey() {
    return DateFormat('yyyy-MM-dd').format(DateTime.now());
  }

  static Future<void> saveDailyCheckIn(DailyCheckIn checkIn) async {
    final key = DateFormat('yyyy-MM-dd').format(checkIn.date);
    await _checkinsBox?.put(key, checkIn);
  }

  static DailyCheckIn? getTodayCheckIn() {
    final key = _getTodayKey();
    return _checkinsBox?.get(key);
  }

  static bool hasCompletedToday() {
    return getTodayCheckIn() != null;
  }

  static DailyCheckIn? getCheckInByDate(DateTime date) {
    final key = DateFormat('yyyy-MM-dd').format(date);
    return _checkinsBox?.get(key);
  }

  static List<DailyCheckIn> getAllCheckIns() {
    return _checkinsBox?.values.toList() ?? [];
  }

  static Map<String, dynamic> getStats() {
    final checkIns = getAllCheckIns();

    if (checkIns.isEmpty) {
      return {
        'total_days': 0,
        'current_streak': 0,
        'perfect_days': 0,
        'average_score': 0.0,
        'executed_priority_count': 0,
        'executed_priority_total': 0,
      };
    }

    // Sort by date
    checkIns.sort((a, b) => a.date.compareTo(b.date));

    // Calculate total days
    final totalDays = checkIns.length;

    // Calculate perfect days (score = 4)
    final perfectDays = checkIns.where((c) => c.score == 4).length;

    // Veces que ejecutó la prioridad crítica (question3 = executedPriority)
    final executedPriorityCount = checkIns.where((c) => c.question3).length;

    // Calculate average score
    final totalScore = checkIns.fold<int>(0, (sum, c) => sum + c.score);
    final averageScore = totalScore / totalDays;

    // Calculate current streak
    int currentStreak = 0;
    final today = DateTime.now();
    DateTime checkDate = DateTime(today.year, today.month, today.day);

    while (true) {
      final checkIn = getCheckInByDate(checkDate);
      if (checkIn == null) break;

      currentStreak++;
      checkDate = checkDate.subtract(const Duration(days: 1));
    }

    return {
      'total_days': totalDays,
      'current_streak': currentStreak,
      'perfect_days': perfectDays,
      'average_score': averageScore,
      'executed_priority_count': executedPriorityCount,
      'executed_priority_total': totalDays,
    };
  }

  // Weekly Reflection methods
  static String _getCurrentWeekKey() {
    final now = DateTime.now();

    // Calculate ISO week number
    final dayOfWeek = now.weekday; // Monday = 1, Sunday = 7
    final thursday = now.subtract(Duration(days: dayOfWeek - 4));

    // Get the year of the Thursday (this is the ISO year)
    final isoYear = thursday.year;

    // Find the first Thursday of the ISO year
    final jan4 = DateTime(isoYear, 1, 4);
    final firstThursday = jan4.subtract(Duration(days: jan4.weekday - 4));

    // Calculate week number
    final weekNumber = ((thursday.difference(firstThursday).inDays / 7).floor() + 1);

    return '$isoYear-W${weekNumber.toString().padLeft(2, '0')}';
  }

  static Future<void> saveWeeklyReflection(WeeklyReflection reflection) async {
    await _weeklyBox?.put(reflection.weekKey, reflection);
  }

  static WeeklyReflection? getThisWeekReflection() {
    final key = _getCurrentWeekKey();
    return _weeklyBox?.get(key);
  }

  static bool hasCompletedThisWeek() {
    return getThisWeekReflection() != null;
  }

  static List<WeeklyReflection> getAllWeeklyReflections() {
    return _weeklyBox?.values.toList() ?? [];
  }

  static WeeklyReflection? getWeeklyReflectionByKey(String weekKey) {
    return _weeklyBox?.get(weekKey);
  }

  // Daily Priority methods
  static Future<void> saveTodayPriority(String priority) async {
    final key = _getTodayKey();
    await _prioritiesBox?.put(key, priority);
  }

  static String? getTodayPriority() {
    final key = _getTodayKey();
    return _prioritiesBox?.get(key);
  }

  static bool hasTodayPriority() {
    final key = _getTodayKey();
    return _prioritiesBox?.containsKey(key) ?? false;
  }
}
