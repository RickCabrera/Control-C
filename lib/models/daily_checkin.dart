import 'package:hive/hive.dart';

part 'daily_checkin.g.dart';

@HiveType(typeId: 1)
class DailyCheckIn extends HiveObject {
  @HiveField(0)
  DateTime date;

  @HiveField(1)
  bool question1;

  @HiveField(2)
  bool question2;

  @HiveField(3)
  bool question3;

  @HiveField(4)
  bool question4;

  @HiveField(5)
  int score;

  @HiveField(6)
  DateTime timestamp;

  DailyCheckIn({
    required this.date,
    required this.question1,
    required this.question2,
    required this.question3,
    required this.question4,
    required this.score,
    required this.timestamp,
  });

  static int calculateScore(bool q1, bool q2, bool q3, bool q4) {
    int score = 0;
    if (q1) score++;
    if (q2) score++;
    if (q3) score++;
    if (q4) score++;
    return score;
  }

  static String getScoreMessage(int score) {
    switch (score) {
      case 4:
        return 'DÍA LEGENDARIO';
      case 3:
        return 'BUEN DÍA';
      case 2:
        return 'ALERTA';
      default:
        return 'REVISA QUÉ PASÓ';
    }
  }

  static String getScoreDescription(int score) {
    switch (score) {
      case 4:
        return 'Completaste todas las tareas críticas. Excelente trabajo.';
      case 3:
        return 'Buen progreso, pero hay espacio para mejorar.';
      case 2:
        return 'Necesitas enfocarte más en lo importante.';
      default:
        return 'Reflexiona sobre qué te impidió avanzar.';
    }
  }
}
