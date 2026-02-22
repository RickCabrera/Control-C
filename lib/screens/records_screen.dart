import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/pip_boy_theme.dart';
import '../widgets/retro_container.dart';
import '../models/daily_checkin.dart';
import '../models/weekly_reflection.dart';
import '../services/hive_service.dart';

class RecordsScreen extends StatefulWidget {
  const RecordsScreen({super.key});

  @override
  State<RecordsScreen> createState() => _RecordsScreenState();
}

class _RecordsScreenState extends State<RecordsScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'REGISTROS',
            style: TextStyle(letterSpacing: 3),
          ),
          bottom: const TabBar(
            indicatorColor: PipBoyColors.primary,
            labelColor: PipBoyColors.primary,
            unselectedLabelColor: PipBoyColors.primaryDim,
            labelStyle: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
            tabs: [
              Tab(text: 'DIARIOS'),
              Tab(text: 'SEMANAL'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildDailyRecordsTab(),
            _buildWeeklyReflectionsTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyRecordsTab() {
    final checkIns = HiveService.getAllCheckIns();

    // Ordenar por fecha descendente (más reciente primero)
    checkIns.sort((a, b) => b.date.compareTo(a.date));

    if (checkIns.isEmpty) {
      return const Center(
        child: Text(
          'SIN REGISTROS AÚN',
          style: TextStyle(
            fontSize: 16,
            letterSpacing: 2,
            color: PipBoyColors.primaryDim,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: checkIns.length,
      itemBuilder: (context, index) {
        final checkIn = checkIns[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildDailyCheckInCard(checkIn),
        );
      },
    );
  }

  Widget _buildDailyCheckInCard(DailyCheckIn checkIn) {
    final dateFormatted = DateFormat('dd/MM/yyyy')
        .format(checkIn.date)
        .toUpperCase();

    final score = checkIn.score;
    final scoreMessage = DailyCheckIn.getScoreMessage(score);
    final scoreColor = _getScoreColor(score);

    return RetroContainer(
      title: dateFormatted,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Prioridad crítica
          RichText(
            text: TextSpan(
              style: const TextStyle(
                fontSize: 14,
                letterSpacing: 0.5,
                height: 1.5,
              ),
              children: [
                const TextSpan(
                  text: 'PRIORIDAD: ',
                  style: TextStyle(
                    color: PipBoyColors.primaryDim,
                  ),
                ),
                TextSpan(
                  text: checkIn.criticalPriority,
                  style: const TextStyle(
                    color: PipBoyColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),
          const Divider(color: PipBoyColors.primaryDim, height: 1),
          const SizedBox(height: 12),

          // Score
          Text(
            '$score/4 — $scoreMessage',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
              color: scoreColor,
            ),
          ),

          const SizedBox(height: 16),

          // Respuestas
          _buildAnswerRow('¿ITERACIÓN CONCRETA?', checkIn.question1),
          const SizedBox(height: 8),
          _buildAnswerRow('¿REDUJO INCERTIDUMBRE?', checkIn.question2),
          const SizedBox(height: 8),
          _buildAnswerRow('¿EJECUTÓ PRIORIDAD?', checkIn.question3),
          const SizedBox(height: 8),
          _buildAnswerRow('¿SIGUIENTE PASO DEFINIDO?', checkIn.question4),
        ],
      ),
    );
  }

  Widget _buildAnswerRow(String question, bool answer) {
    return Row(
      children: [
        Text(
          answer ? '✓' : '✗',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: answer ? PipBoyColors.primary : PipBoyColors.error,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            question,
            style: const TextStyle(
              fontSize: 13,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ],
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 3) return PipBoyColors.primary;
    if (score == 2) return PipBoyColors.warning;
    return PipBoyColors.error;
  }

  Widget _buildWeeklyReflectionsTab() {
    final reflections = HiveService.getAllWeeklyReflections();

    // Ordenar por timestamp descendente (más reciente primero)
    reflections.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    if (reflections.isEmpty) {
      return const Center(
        child: Text(
          'SIN REFLEXIONES AÚN',
          style: TextStyle(
            fontSize: 16,
            letterSpacing: 2,
            color: PipBoyColors.primaryDim,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: reflections.length,
      itemBuilder: (context, index) {
        final reflection = reflections[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildWeeklyReflectionCard(reflection),
        );
      },
    );
  }

  Widget _buildWeeklyReflectionCard(WeeklyReflection reflection) {
    final isPursuingReal = reflection.pursuingRealPotential;
    final resultText = isPursuingReal
        ? '✓ POTENCIAL REAL'
        : '✗ SOLO ENTRETENIÉNDOME';
    final resultColor = isPursuingReal
        ? PipBoyColors.primary
        : PipBoyColors.warning;

    final dateFormatted = DateFormat('dd/MM/yyyy HH:mm')
        .format(reflection.timestamp);

    return RetroContainer(
      title: 'SEMANA ${reflection.weekKey}',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Respuesta grande
          Text(
            resultText,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
              color: resultColor,
            ),
          ),

          const SizedBox(height: 12),

          // Fecha
          Text(
            dateFormatted,
            style: const TextStyle(
              fontSize: 12,
              letterSpacing: 0.5,
              color: PipBoyColors.primaryDim,
            ),
          ),
        ],
      ),
    );
  }
}
