import 'package:flutter/material.dart';
import '../theme/pip_boy_theme.dart';
import '../widgets/retro_button.dart';
import '../widgets/retro_container.dart';
import '../widgets/retro_input.dart';
import '../models/daily_checkin.dart';
import '../models/user_config.dart';
import '../services/hive_service.dart';
import 'settings_screen.dart';
import 'weekly_reflection_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _hasPriority = false;      // ¿Guardó prioridad hoy?
  bool _hasCompleted = false;     // ¿Completó las 4 métricas hoy?
  String? _todayPriority;         // Prioridad guardada hoy
  DailyCheckIn? _todayCheckIn;
  UserConfig? _userConfig;
  bool _hasWeeklyReflection = false;

  // Critical priority
  final TextEditingController _criticalPriorityController = TextEditingController();

  // Answers
  bool? _answer1;
  bool? _answer2;
  bool? _answer3;
  bool? _answer4;

  final List<Map<String, String>> _questions = [
    {
      'question': '¿Hice una iteración concreta y visible?',
      'hint': 'Código · Documento · Investigación aplicada · Decisión estratégica · Prototipo · Esquema',
    },
    {
      'question': '¿Reduje incertidumbre hoy?',
      'hint': 'Validar hipótesis · Hablar con alguien · Probar algo · Medir algo · Confirmar que una idea no funciona',
    },
    {
      'question': '¿Ejecuté la prioridad crítica?',
      'hint': 'Cada día defines una sola prioridad crítica antes de empezar',
    },
    {
      'question': '¿Dejé definido el siguiente paso?',
      'hint': 'Volver es fácil cuando sabes exactamente qué hacer',
    },
  ];

  @override
  void initState() {
    super.initState();
    _checkTodayStatus();
  }

  @override
  void dispose() {
    _criticalPriorityController.dispose();
    super.dispose();
  }

  void _checkTodayStatus() {
    final priority = HiveService.getTodayPriority();
    final checkIn = HiveService.getTodayCheckIn();
    final config = HiveService.getUserConfig();
    final hasWeekly = HiveService.hasCompletedThisWeek();

    setState(() {
      _hasPriority = priority != null;
      _todayPriority = priority;
      _hasCompleted = checkIn != null;
      _todayCheckIn = checkIn;
      _userConfig = config;
      _hasWeeklyReflection = hasWeekly;
      // Si ya hay prioridad guardada, llena el controller para mostrarlo
      if (priority != null) _criticalPriorityController.text = priority;
    });
  }

  Future<void> _savePriority() async {
    final criticalPriority = _criticalPriorityController.text.trim();
    if (criticalPriority.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ERROR: DEFINE LA PRIORIDAD CRÍTICA'),
          backgroundColor: PipBoyColors.error,
        ),
      );
      return;
    }

    await HiveService.saveTodayPriority(criticalPriority);

    setState(() {
      _hasPriority = true;
      _todayPriority = criticalPriority;
    });

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('PRIORIDAD GUARDADA'),
        backgroundColor: PipBoyColors.primaryDim,
      ),
    );
  }

  Future<void> _saveCheckIn() async {
    // Validate all questions answered
    if (_answer1 == null ||
        _answer2 == null ||
        _answer3 == null ||
        _answer4 == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ERROR: RESPONDE TODAS LAS PREGUNTAS'),
          backgroundColor: PipBoyColors.error,
        ),
      );
      return;
    }

    final score = DailyCheckIn.calculateScore(
      _answer1!,
      _answer2!,
      _answer3!,
      _answer4!,
    );

    final checkIn = DailyCheckIn(
      date: DateTime.now(),
      question1: _answer1!,
      question2: _answer2!,
      question3: _answer3!,
      question4: _answer4!,
      score: score,
      timestamp: DateTime.now(),
      criticalPriority: _todayPriority!,
    );

    await HiveService.saveDailyCheckIn(checkIn);

    setState(() {
      _hasCompleted = true;
      _todayCheckIn = checkIn;
    });

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('REGISTRO GUARDADO'),
        backgroundColor: PipBoyColors.primaryDim,
      ),
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 3) return PipBoyColors.primary;
    if (score == 2) return PipBoyColors.warning;
    return PipBoyColors.error;
  }

  Widget _buildPriorityInputView() {
    return Column(
      children: [
        RetroContainer(
          title: 'ANTES DE EMPEZAR',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '2 MINUTOS',
                style: TextStyle(
                  fontSize: 12,
                  letterSpacing: 1,
                  color: PipBoyColors.primaryDim,
                ),
              ),
              const SizedBox(height: 16),
              RetroInput(
                label: '¿CUÁL ES LA PRIORIDAD CRÍTICA HOY?',
                controller: _criticalPriorityController,
                hintText: 'DEFINE UNA SOLA COSA',
                maxLines: 3,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        RetroButton(
          label: 'GUARDAR PRIORIDAD',
          onPressed: _savePriority,
        ),
      ],
    );
  }

  Widget _buildMetricsView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Weekly reflection reminder if not completed
        if (!_hasWeeklyReflection) _buildWeeklyReflectionReminder(),

        // Priority display (read-only)
        RetroContainer(
          title: 'PRIORIDAD DE HOY',
          child: Text(
            _todayPriority!,
            style: const TextStyle(
              fontSize: 16,
              letterSpacing: 1,
              height: 1.5,
              fontWeight: FontWeight.bold,
              color: PipBoyColors.primary,
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Iteration info
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(
              color: PipBoyColors.primaryDim,
              width: 1,
            ),
            color: PipBoyColors.surfaceVariant,
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ITERACIÓN MÍNIMA: 20–60 MIN',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Title
        const Text(
          'LAS 4 MÉTRICAS',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 16),

        // Question cards
        _buildQuestionCards(),
      ],
    );
  }

  Widget _buildQuestionCard(int index, bool? answer, Function(bool) onAnswer) {
    final questionData = _questions[index];

    return RetroContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PREGUNTA ${index + 1}/4',
            style: const TextStyle(
              fontSize: 12,
              letterSpacing: 2,
              color: PipBoyColors.primaryDim,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            questionData['question']!.toUpperCase(),
            style: const TextStyle(
              fontSize: 16,
              letterSpacing: 1,
              fontWeight: FontWeight.bold,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            questionData['hint']!,
            style: const TextStyle(
              fontSize: 12,
              letterSpacing: 0.5,
              color: PipBoyColors.primaryDim,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: RetroButton(
                  label: 'SÍ',
                  isSelected: answer == true,
                  onPressed: () => onAnswer(true),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: RetroButton(
                  label: 'NO',
                  isSelected: answer == false,
                  onPressed: () => onAnswer(false),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCards() {
    return Column(
      children: [
        _buildQuestionCard(0, _answer1, (value) {
          setState(() => _answer1 = value);
        }),
        const SizedBox(height: 16),
        _buildQuestionCard(1, _answer2, (value) {
          setState(() => _answer2 = value);
        }),
        const SizedBox(height: 16),
        _buildQuestionCard(2, _answer3, (value) {
          setState(() => _answer3 = value);
        }),
        const SizedBox(height: 16),
        _buildQuestionCard(3, _answer4, (value) {
          setState(() => _answer4 = value);
        }),
        const SizedBox(height: 24),
        RetroButton(
          label: 'GUARDAR REGISTRO',
          onPressed: _saveCheckIn,
        ),
      ],
    );
  }

  Widget _buildWeeklyReflectionReminder() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(
          color: PipBoyColors.warning,
          width: 2,
        ),
        color: PipBoyColors.warning.withOpacity(0.1),
        boxShadow: [
          BoxShadow(
            color: PipBoyColors.warning.withOpacity(0.3),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: PipBoyColors.warning,
                size: 24,
              ),
              const SizedBox(width: 12),
              Flexible(
                child: const Text(
                  'REFLEXIÓN SEMANAL PENDIENTE',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                    color: PipBoyColors.warning,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Es momento de revisar si sigues persiguiendo algo con potencial real.',
            style: TextStyle(
              fontSize: 14,
              letterSpacing: 0.5,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          RetroButton(
            label: 'COMPLETAR REFLEXIÓN',
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const WeeklyReflectionScreen(),
                ),
              );
              _checkTodayStatus();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAnswersList() {
    if (_todayCheckIn == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        const Text(
          '// RESPUESTAS DEL DÍA',
          style: TextStyle(
            fontSize: 14,
            letterSpacing: 2,
            color: PipBoyColors.primaryDim,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        _buildAnswerRow('Iteración concreta y visible', _todayCheckIn!.iterationDone),
        _buildAnswerRow('Reducir incertidumbre', _todayCheckIn!.reducedUncertainty),
        _buildAnswerRow('Ejecutar prioridad crítica', _todayCheckIn!.executedPriority),
        _buildAnswerRow('Siguiente paso definido', _todayCheckIn!.nextStepDefined),
      ],
    );
  }

  Widget _buildAnswerRow(String label, bool value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            value ? Icons.check_circle : Icons.cancel,
            color: value ? PipBoyColors.primary : PipBoyColors.error,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label.toUpperCase(),
              style: const TextStyle(
                fontSize: 13,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletedView() {
    if (_todayCheckIn == null) return const SizedBox.shrink();

    final score = _todayCheckIn!.score;
    final message = DailyCheckIn.getScoreMessage(score);
    final description = DailyCheckIn.getScoreDescription(score);
    final color = _getScoreColor(score);

    return Column(
      children: [
        // Weekly reflection reminder if not completed
        if (!_hasWeeklyReflection) _buildWeeklyReflectionReminder(),

        // Priority of the day
        RetroContainer(
          title: 'PRIORIDAD DE HOY',
          child: Text(
            _todayCheckIn!.criticalPriority,
            style: const TextStyle(
              fontSize: 16,
              letterSpacing: 1,
              height: 1.5,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Score
        RetroContainer(
          title: 'REGISTRO DIARIO COMPLETADO',
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  border: Border.all(color: color, width: 2),
                  color: color.withOpacity(0.1),
                ),
                child: Column(
                  children: [
                    Text(
                      '$score/4',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: color,
                        letterSpacing: 4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      message,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: color,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                description,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  letterSpacing: 0.5,
                  height: 1.5,
                ),
              ),
              _buildAnswersList(),
              const SizedBox(height: 24),
              const Text(
                'VUELVE MAÑANA PARA TU PRÓXIMO CHECK-IN.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  letterSpacing: 1,
                  color: PipBoyColors.primaryDim,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'COMANDO CABRERA',
          style: TextStyle(letterSpacing: 3),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
              _checkTodayStatus();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_userConfig != null) ...[
                Text(
                  'BIENVENIDO, ${_userConfig!.name.toUpperCase()}',
                  style: const TextStyle(
                    fontSize: 16,
                    letterSpacing: 2,
                    color: PipBoyColors.primaryDim,
                  ),
                ),
                const SizedBox(height: 24),
              ],
              if (_hasCompleted)
                _buildCompletedView()
              else if (_hasPriority)
                _buildMetricsView()
              else
                _buildPriorityInputView(),
            ],
          ),
        ),
      ),
    );
  }
}
