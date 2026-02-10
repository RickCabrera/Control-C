import 'package:flutter/material.dart';
import '../theme/pip_boy_theme.dart';
import '../widgets/retro_input.dart';
import '../widgets/retro_button.dart';
import '../widgets/retro_container.dart';
import '../models/user_config.dart';
import '../services/hive_service.dart';
import '../services/notification_service.dart';
import 'home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _nameController = TextEditingController();
  TimeOfDay _selectedTime = const TimeOfDay(hour: 20, minute: 0);
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: PipBoyColors.primary,
              onPrimary: PipBoyColors.background,
              surface: PipBoyColors.surface,
              onSurface: PipBoyColors.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _saveAndContinue() async {
    final name = _nameController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ERROR: NOMBRE REQUERIDO'),
          backgroundColor: PipBoyColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Save user config
      final config = UserConfig(
        name: name,
        checkinHour: _selectedTime.hour,
        checkinMinute: _selectedTime.minute,
        startDate: DateTime.now(),
      );
      await HiveService.saveUserConfig(config);

      // Schedule notification
      await NotificationService.scheduleDailyNotification(
        hour: _selectedTime.hour,
        minute: _selectedTime.minute,
      );

      if (!mounted) return;

      // Navigate to home screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('ERROR: ${e.toString()}'),
          backgroundColor: PipBoyColors.error,
        ),
      );

      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              const Text(
                'CONTROL CABRERA',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 3,
                  color: PipBoyColors.primaryBright,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'SISTEMA DE SEGUIMIENTO V1.0',
                style: TextStyle(
                  fontSize: 14,
                  letterSpacing: 2,
                  color: PipBoyColors.primaryDim,
                ),
              ),
              const SizedBox(height: 40),
              RetroContainer(
                title: 'CONFIGURACIÓN INICIAL',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'BIENVENIDO CABRERA.',
                      style: TextStyle(
                        fontSize: 14,
                        letterSpacing: 1,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'REGISTRAREMOS 4 PREGUNTAS CRÍTICAS CADA 24 HORAS.',
                      style: TextStyle(
                        fontSize: 14,
                        letterSpacing: 1,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    RetroInput(
                      label: 'NOMBRE',
                      controller: _nameController,
                      hintText: 'INGRESA TU NOMBRE',
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      '> HORA DE CHECK-IN DIARIO',
                      style: TextStyle(
                        color: PipBoyColors.primaryDim,
                        fontSize: 14,
                        letterSpacing: 2,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: _selectTime,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: PipBoyColors.primary,
                            width: 2,
                          ),
                          color: PipBoyColors.surfaceVariant,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _selectedTime.format(context),
                              style: const TextStyle(
                                fontSize: 18,
                                letterSpacing: 2,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Icon(Icons.access_time),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    if (_isLoading)
                      const Center(
                        child: CircularProgressIndicator(
                          color: PipBoyColors.primary,
                        ),
                      )
                    else
                      RetroButton(
                        label: 'INICIAR CONTROL CABRERA',
                        onPressed: _saveAndContinue,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
