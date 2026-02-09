import 'package:hive/hive.dart';

part 'user_config.g.dart';

@HiveType(typeId: 0)
class UserConfig extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  int checkinHour;

  @HiveField(2)
  int checkinMinute;

  @HiveField(3)
  DateTime startDate;

  UserConfig({
    required this.name,
    required this.checkinHour,
    required this.checkinMinute,
    required this.startDate,
  });
}
