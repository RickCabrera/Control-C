import 'package:flutter/material.dart';
import '../theme/pip_boy_theme.dart';
import '../widgets/retro_button.dart';
import '../widgets/retro_container.dart';
import '../models/daily_checkin.dart';
import '../models/user_config.dart';
import '../services/hive_service.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _hasCompleted = false;
  DailyCheckIn? _todayCheckIn;
  UserConfig? _userConfig;

  bool? _answer1;
  bool? _answer2;
  bool? _answer3;
  bool? _answer4;

  final List<String> _questions = [
    '¿Construí algo real?',
    '¿Lo acerqué a usuarios / dinero / validación?',
    '¿Trabajé en lo importante, no en relleno?',
    '¿Quedé en condiciones de volver mañana?',
  ];

  @override
  void initState() {
    super.initState();
    _checkTodayStatus();
  }

  void _checkTodayStatus() {
    final checkIn = HiveService.getTodayCheckIn();
    final config = HiveService.getUserConfig();

    setState(() {
      _hasCompleted = checkIn != null;
      _todayCheckIn = checkIn;
      _userConfig = config;
    });
  }

  Future<void> _saveCheckIn() async {
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
    );

    await HiveService.saveDailyCheckIn(checkIn);

    setState(() {
      _hasCompleted = true;
      _todayCheckIn = checkIn;
    });

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('CHECK-IN GUARDADO'),
        backgroundColor: PipBoyColors.primaryDim,
      ),
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 3) return PipBoyColors.primary;
    if (score == 2) return PipBoyColors.warning;
    return PipBoyColors.error;
  }

  Widget _buildQuestionCard(int index, bool? answer, Function(bool) onAnswer) {
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
            _questions[index].toUpperCase(),
            style: const TextStyle(
              fontSize: 16,
              letterSpacing: 1,
              fontWeight: FontWeight.bold,
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
          label: 'GUARDAR CHECK-IN',
          onPressed: _saveCheckIn,
        ),
      ],
    );
  }

  Widget _buildCompletedView() {
    if (_todayCheckIn == null) return const SizedBox.shrink();

    final score = _todayCheckIn!.score;
    final message = DailyCheckIn.getScoreMessage(score);
    final description = DailyCheckIn.getScoreDescription(score);
    final color = _getScoreColor(score);

    return RetroContainer(
      title: 'CHECK-IN COMPLETADO',
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
            description.toUpperCase(),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              letterSpacing: 1,
              height: 1.5,
            ),
          ),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'CONTROL CABRERA',
          style: const TextStyle(letterSpacing: 3),
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
              else ...[
                const Text(
                  'CHECK-IN DIARIO',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'RESPONDE LAS 4 PREGUNTAS CRÍTICAS:',
                  style: TextStyle(
                    fontSize: 14,
                    letterSpacing: 1,
                    color: PipBoyColors.primaryDim,
                  ),
                ),
                const SizedBox(height: 24),
                _buildQuestionCards(),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
