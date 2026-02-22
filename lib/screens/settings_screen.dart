import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/pip_boy_theme.dart';
import '../widgets/retro_container.dart';
import '../widgets/retro_button.dart';
import '../models/user_config.dart';
import '../services/hive_service.dart';
import '../services/notification_service.dart';
import 'weekly_reflection_screen.dart';
import 'records_screen.dart';    

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  UserConfig? _userConfig;
  Map<String, dynamic>? _stats;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _userConfig = HiveService.getUserConfig();
      _stats = HiveService.getStats();
    });
  }

  Future<void> _changeCheckinTime() async {
    if (_userConfig == null) return;

    final currentTime = TimeOfDay(
      hour: _userConfig!.checkinHour,
      minute: _userConfig!.checkinMinute,
    );

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: currentTime,
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

    if (picked != null) {
      setState(() {
        _isLoading = true;
      });

      try {
        await HiveService.updateCheckinTime(picked.hour, picked.minute);
        await NotificationService.scheduleDailyNotification(
          hour: picked.hour,
          minute: picked.minute,
        );

        _loadData();

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('HORA ACTUALIZADA'),
            backgroundColor: PipBoyColors.primaryDim,
          ),
        );
      } catch (e) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('ERROR: ${e.toString()}'),
            backgroundColor: PipBoyColors.error,
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontSize: 14,
              letterSpacing: 1,
              color: PipBoyColors.primaryDim,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_userConfig == null || _stats == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('CONFIGURACIÓN'),
        ),
        body: const Center(
          child: CircularProgressIndicator(
            color: PipBoyColors.primary,
          ),
        ),
      );
    }

    final checkinTime = TimeOfDay(
      hour: _userConfig!.checkinHour,
      minute: _userConfig!.checkinMinute,
    );

    final startDate = DateFormat('dd/MM/yyyy').format(_userConfig!.startDate);

    return Scaffold(
      appBar: AppBar(
        title: const Text('CONFIGURACIÓN'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RetroContainer(
                title: 'CONFIGURACIÓN DE USUARIO',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStatRow('Nombre', _userConfig!.name.toUpperCase()),
                    const Divider(color: PipBoyColors.primaryDim, height: 32),
                    _buildStatRow('Fecha de inicio', startDate),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              RetroContainer(
                title: 'HORA DE CHECK-IN',
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'HORA ACTUAL',
                          style: TextStyle(
                            fontSize: 14,
                            letterSpacing: 1,
                            color: PipBoyColors.primaryDim,
                          ),
                        ),
                        Text(
                          checkinTime.format(context),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (_isLoading)
                      const Center(
                        child: CircularProgressIndicator(
                          color: PipBoyColors.primary,
                        ),
                      )
                    else
                      RetroButton(
                        label: 'CAMBIAR HORA',
                        onPressed: _changeCheckinTime,
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              RetroContainer(
                title: 'REFLEXIÓN SEMANAL',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Revisa si estás persiguiendo potencial real o solo entreteniéndote.',
                      style: TextStyle(
                        fontSize: 14,
                        letterSpacing: 0.5,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 16),
                    RetroButton(
                      label: 'IR A REFLEXIÓN SEMANAL',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const WeeklyReflectionScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              RetroContainer(
                title: 'REGISTROS',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Revisa tu historial completo de registros diarios y reflexiones semanales.',
                      style: TextStyle(
                        fontSize: 14,
                        letterSpacing: 0.5,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 16),
                    RetroButton(
                      label: 'VER HISTORIAL',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RecordsScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              RetroContainer(
                title: 'ESTADÍSTICAS',
                child: Column(
                  children: [
                    _buildStatRow(
                      'Total de días',
                      _stats!['total_days'].toString(),
                    ),
                    const Divider(color: PipBoyColors.primaryDim, height: 24),
                    _buildStatRow(
                      'Racha actual',
                      _stats!['current_streak'].toString() + ' días',
                    ),
                    const Divider(color: PipBoyColors.primaryDim, height: 24),
                    _buildStatRow(
                      'Días perfectos (4/4)',
                      _stats!['perfect_days'].toString(),
                    ),
                    const Divider(color: PipBoyColors.primaryDim, height: 24),
                    _buildStatRow(
                      'Promedio',
                      _stats!['average_score'].toStringAsFixed(1) + '/4.0',
                    ),
                    const Divider(color: PipBoyColors.primaryDim, height: 24),
                    _buildStatRow(
                      'Prioridad ejecutada',
                      '${_stats!['executed_priority_count']}/${_stats!['executed_priority_total']}',
                    ),
                    const Divider(color: PipBoyColors.primaryDim, height: 24),
                    _buildStatRow(
                      'Semanas reflexionadas',
                      HiveService.getAllWeeklyReflections().length.toString(),
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
