import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme/pip_boy_theme.dart';
import 'services/hive_service.dart';
import 'services/notification_service.dart';
import 'screens/onboarding_screen.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  await HiveService.init();
  await NotificationService.init();

  runApp(const ControlCabreraApp());
}

class ControlCabreraApp extends StatelessWidget {
  const ControlCabreraApp({super.key});

  @override
  Widget build(BuildContext context) {
    final hasConfig = HiveService.hasUserConfig();

    return MaterialApp(
      title: 'Comando Cabrera',
      theme: PipBoyTheme.theme,
      debugShowCheckedModeBanner: false,
      home: hasConfig ? const HomeScreen() : const OnboardingScreen(),
    );
  }
}
