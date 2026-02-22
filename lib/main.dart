import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
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

  try {
    final appDocumentDir = await getApplicationDocumentsDirectory();
    await HiveService.init(appDocumentDir.path);
  } catch (e) {
    debugPrint('Hive init error: $e');
    try {
      await HiveService.init(null);
    } catch (e2) {
      debugPrint('Hive fallback init error: $e2');
    }
  }

  try {
    await NotificationService.init();
  } catch (e) {
    debugPrint('Notification init error: $e');
  }

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
