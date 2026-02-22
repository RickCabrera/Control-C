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

  @HiveField(7)
  String criticalPriority;

  DailyCheckIn({
    required this.date,
    required this.question1,
    required this.question2,
    required this.question3,
    required this.question4,
    required this.score,
    required this.timestamp,
    required this.criticalPriority,
  });

  // Semantic getters for better code readability
  bool get iterationDone => question1;
  bool get reducedUncertainty => question2;
  bool get executedPriority => question3;
  bool get nextStepDefined => question4;

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
        return 'DÍA ÉLITE';
      case 3:
        return 'EXCELENTE';
      case 2:
        return 'SIGUES EN JUEGO';
      default:
        return 'REVISA QUÉ PASÓ';
    }
  }

  static String getScoreDescription(int score) {
    switch (score) {
      case 4:
        return 'Ejecutaste tu prioridad, iteraste, redujiste incertidumbre y dejaste el siguiente paso listo. Día perfecto.';
      case 3:
        return 'Avance sólido. Una métrica falló pero mantienes momentum. Ajusta y sigue.';
      case 2:
        return 'Dos métricas fallaron. Todavía hay progreso pero necesitas más foco en lo crítico.';
      default:
        return 'Día difuso. Revisa si trabajaste en lo importante o te dispersaste en tareas secundarias.';
    }
  }
}
