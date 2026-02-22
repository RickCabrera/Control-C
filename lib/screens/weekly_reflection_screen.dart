import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/pip_boy_theme.dart';
import '../widgets/retro_button.dart';
import '../widgets/retro_container.dart';
import '../models/weekly_reflection.dart';
import '../services/hive_service.dart';

class WeeklyReflectionScreen extends StatefulWidget {
  const WeeklyReflectionScreen({super.key});

  @override
  State<WeeklyReflectionScreen> createState() => _WeeklyReflectionScreenState();
}

class _WeeklyReflectionScreenState extends State<WeeklyReflectionScreen> {
  bool _hasCompleted = false;
  WeeklyReflection? _thisWeekReflection;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkWeekStatus();
  }

  void _checkWeekStatus() {
    final reflection = HiveService.getThisWeekReflection();

    setState(() {
      _hasCompleted = reflection != null;
      _thisWeekReflection = reflection;
    });
  }

  Future<void> _saveReflection(bool pursuingRealPotential) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final reflection = WeeklyReflection.forCurrentWeek(
        pursuingRealPotential: pursuingRealPotential,
      );

      await HiveService.saveWeeklyReflection(reflection);

      setState(() {
        _hasCompleted = true;
        _thisWeekReflection = reflection;
        _isLoading = false;
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('REFLEXIÓN GUARDADA'),
          backgroundColor: PipBoyColors.primaryDim,
        ),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('ERROR: ${e.toString()}'),
          backgroundColor: PipBoyColors.error,
        ),
      );
    }
  }

  Widget _buildQuestionView() {
    return RetroContainer(
      title: 'LA PREGUNTA DE LA SEMANA',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '¿SIGO PERSIGUIENDO ALGO CON POTENCIAL REAL O SOLO ESTOY ENTRETENIÉNDOME?',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Responde con honestidad. Nadie más lo verá.',
            style: TextStyle(
              fontSize: 13,
              letterSpacing: 0.5,
              color: PipBoyColors.primaryDim,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 32),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(
                color: PipBoyColors.primary,
              ),
            )
          else ...[
            RetroButton(
              label: 'POTENCIAL REAL',
              onPressed: () => _saveReflection(true),
            ),
            const SizedBox(height: 16),
            RetroButton(
              label: 'SOLO ENTRETENIÉNDOME',
              onPressed: () => _saveReflection(false),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCompletedView() {
    if (_thisWeekReflection == null) return const SizedBox.shrink();

    final isPursuingReal = _thisWeekReflection!.pursuingRealPotential;
    final color = isPursuingReal ? PipBoyColors.primary : PipBoyColors.warning;
    final message = isPursuingReal ? 'BIEN. SIGUE EJECUTANDO.' : 'HORA DE RECALIBRAR.';
    final suggestion = isPursuingReal
        ? 'Mantén el foco en las métricas críticas. Ejecuta la prioridad cada día.'
        : 'Si no estás persiguiendo algo con potencial real, es momento de replantear. ¿Qué deberías estar construyendo?';

    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    final timestampStr = dateFormat.format(_thisWeekReflection!.timestamp);

    return Column(
      children: [
        // Status badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(
              color: PipBoyColors.primary,
              width: 2,
            ),
            color: PipBoyColors.primary.withOpacity(0.1),
          ),
          child: const Text(
            'RESPONDIDA ESTA SEMANA',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
              color: PipBoyColors.primary,
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Answer
        RetroContainer(
          title: 'TU RESPUESTA',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isPursuingReal
                    ? 'ESTOY PERSIGUIENDO POTENCIAL REAL'
                    : 'SOLO ME ESTOY ENTRETENIENDOME',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                  color: color,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Registrado: $timestampStr',
                style: const TextStyle(
                  fontSize: 12,
                  letterSpacing: 0.5,
                  color: PipBoyColors.primaryDim,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Feedback
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            border: Border.all(
              color: color,
              width: 2,
            ),
            color: color.withOpacity(0.1),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 8,
                spreadRadius: 0,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                message,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                  color: color,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                suggestion,
                style: const TextStyle(
                  fontSize: 14,
                  letterSpacing: 0.5,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Info
        const Text(
          'PODRÁS RESPONDER NUEVAMENTE LA PRÓXIMA SEMANA.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            letterSpacing: 1,
            color: PipBoyColors.primaryDim,
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
          'REFLEXIÓN SEMANAL',
          style: TextStyle(letterSpacing: 3),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'REVISIÓN SEMANAL',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Cada semana revisa si estás persiguiendo algo real.',
                style: TextStyle(
                  fontSize: 14,
                  letterSpacing: 0.5,
                  color: PipBoyColors.primaryDim,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 32),
              if (_hasCompleted) _buildCompletedView() else _buildQuestionView(),
            ],
          ),
        ),
      ),
    );
  }
}
