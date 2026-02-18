# Control Cabrera - Guía de Desarrollo

## 📱 Overview

App de checklist diario minimalista con estética retro Pip-Boy (Fallout). El usuario responde 4 preguntas críticas cada 24 horas para mantener enfoque en lo importante.

**Stack:** Flutter + Hive (local storage) + Notificaciones programadas
**Plataforma:** Android (offline-first)
**Estética:** Terminal cyan eléctrico tipo Pip-Boy de Fallout

---

## 🎯 Features Core

### 1. Onboarding (Primera vez)
- Input: Nombre del usuario
- TimePicker: Hora diaria de check-in
- Guardar: Config en Hive + Programar notificación
- Navegación: → HomeScreen

### 2. HomeScreen (Pantalla principal)
**Si NO completó hoy:**
- Mostrar 4 preguntas con botones Sí/No
- Validar respuestas completas antes de guardar
- Calcular score (0-4)
- Guardar en Hive con key `YYYY-MM-DD`

**Si YA completó hoy:**
- Mostrar resultado con score y mensaje personalizado
- Colores según score (verde/amarillo/rojo)

**Las 4 preguntas:**
1. ¿Construí algo real?
2. ¿Lo acerqué a usuarios / dinero / validación?
3. ¿Trabajé en lo importante, no en relleno?
4. ¿Quedé en condiciones de volver mañana?

**Mensajes según score:**
- 4/4 = "DÍA LEGENDARIO" (verde)
- 3/4 = "BUEN DÍA" (verde)
- 2/4 = "ALERTA" (amarillo)
- 0-1/4 = "REVISA QUÉ PASÓ" (rojo)

### 3. SettingsScreen
- Ver/Editar: Hora de check-in
- Mostrar: Fecha de inicio (solo lectura)
- Estadísticas: Total días, racha actual, días perfectos, promedio
- Botón de engranaje en AppBar de HomeScreen

### 4. Notificaciones
- Notificación diaria a la hora configurada
- Mensaje: "¿Construiste algo real hoy? Es hora de tu check-in diario."
- Se reprograma automáticamente cada día
- Se actualiza si el usuario cambia la hora en settings

---

## 📁 Estructura del Proyecto

```
lib/
├── main.dart                 # Entry point
├── theme/
│   └── pip_boy_theme.dart   # Colores + ThemeData
├── models/
│   ├── user_config.dart     # @HiveType(typeId: 0)
│   └── daily_checkin.dart   # @HiveType(typeId: 1)
├── services/
│   ├── hive_service.dart    # CRUD de boxes
│   └── notification_service.dart
├── widgets/
│   ├── retro_button.dart
│   ├── retro_input.dart
│   └── retro_container.dart
└── screens/
    ├── onboarding_screen.dart
    ├── home_screen.dart
    └── settings_screen.dart
```

---

## 🛠️ Dependencies (pubspec.yaml)

```yaml
dependencies:
  flutter:
    sdk: flutter
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  flutter_local_notifications: ^17.0.0
  timezone: ^0.9.2
  intl: ^0.19.0
  google_fonts: ^6.1.0

dev_dependencies:
  hive_generator: ^2.0.1
  build_runner: ^2.4.7
```

**Comandos:**
```bash
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

---

## 🎨 Sistema de Diseño - Pip-Boy Theme

### Paleta de Colores

```dart
class PipBoyColors {
  static const Color primary = Color(0xFF00FFD5);        // Cyan brillante
  static const Color primaryDim = Color(0xFF00B89A);     // Cyan oscuro
  static const Color primaryBright = Color(0xFF4DFFEB);  // Cyan muy brillante
  static const Color background = Color(0xFF0A0E0A);     // Negro verdoso
  static const Color surface = Color(0xFF1A1F1A);        // Gris verdoso
  static const Color surfaceVariant = Color(0xFF0F140F); // Más oscuro
  static const Color warning = Color(0xFFFFB800);        // Amarillo
  static const Color error = Color(0xFFFF0000);          // Rojo
}
```

### Fuente
- `google_fonts: CourierPrime` (monoespaciada tipo terminal)

### Widgets Personalizados

**RetroButton:**
- Borde cyan de 2px
- Padding: 24h x 12v
- Glow effect con BoxShadow
- Estado `isSelected` para Sí/No
- Texto en MAYÚSCULAS con letterSpacing: 2

**RetroInput:**
- Label: `> NOMBRE` (cyan dim)
- Borde cyan de 2px
- Background: surfaceVariant
- Placeholder: `_` (cyan dim)

**RetroContainer:**
- Borde cyan de 2px con glow
- Título opcional: `// TÍTULO` en header
- Border bottom entre título y contenido

---

## 💾 Modelos de Datos

### UserConfig (typeId: 0)
```dart
@HiveType(typeId: 0)
class UserConfig extends HiveObject {
  @HiveField(0) String name;
  @HiveField(1) int checkinHour;
  @HiveField(2) int checkinMinute;
  @HiveField(3) DateTime startDate;
}
```

### DailyCheckIn (typeId: 1)
```dart
@HiveType(typeId: 1)
class DailyCheckIn extends HiveObject {
  @HiveField(0) DateTime date;
  @HiveField(1) bool question1;
  @HiveField(2) bool question2;
  @HiveField(3) bool question3;
  @HiveField(4) bool question4;
  @HiveField(5) int score;
  @HiveField(6) DateTime timestamp;
  
  static int calculateScore(bool q1, bool q2, bool q3, bool q4);
  static String getScoreMessage(int score);
  static String getScoreDescription(int score);
}
```

---

## 🗄️ HiveService - API Principal

```dart
// Inicialización
await HiveService.init();

// User Config
UserConfig? getUserConfig()
Future<void> saveUserConfig(UserConfig config)
bool hasUserConfig()
Future<void> updateCheckinTime(int hour, int minute)

// Daily CheckIns
Future<void> saveDailyCheckIn(DailyCheckIn checkIn)
DailyCheckIn? getTodayCheckIn()
bool hasCompletedToday()
DailyCheckIn? getCheckInByDate(DateTime date)
List<DailyCheckIn> getAllCheckIns()
Map<String, dynamic> getStats()
```

**Storage:**
- Box `user_config`: Key fija `'config'`
- Box `daily_checkins`: Keys dinámicas `'YYYY-MM-DD'`

---

## 🔔 NotificationService - API Principal

```dart
// Inicialización
await NotificationService.init();

// Programar notificación diaria
await NotificationService.scheduleDailyNotification(
  hour: 20,
  minute: 0,
);

// Cancelar todas
await NotificationService.cancelAllNotifications();

// Test (opcional)
await NotificationService.showTestNotification();
```

**Configuración Android:**
- Channel ID: `daily_checkin`
- Importance: High
- Color: cyan eléctrico (#27F5DA)
- Mode: `exactAllowWhileIdle` (permite alarmas exactas)

---

## 🖥️ Pantallas - Lógica Clave

### OnboardingScreen
```dart
// Validación
if (_nameController.text.trim().isEmpty) {
  // Mostrar error
}

// Guardar config
final config = UserConfig(
  name: _nameController.text.trim(),
  checkinHour: _selectedTime.hour,
  checkinMinute: _selectedTime.minute,
  startDate: DateTime.now(),
);
await HiveService.saveUserConfig(config);

// Programar notificación
await NotificationService.scheduleDailyNotification(
  hour: _selectedTime.hour,
  minute: _selectedTime.minute,
);

// Navegar (sin back)
Navigator.pushReplacement(context, MaterialPageRoute(...));
```

### HomeScreen
```dart
@override
void initState() {
  _checkTodayStatus(); // Verificar si ya completó hoy
}

// Guardar check-in
final score = DailyCheckIn.calculateScore(q1, q2, q3, q4);
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
setState(() { _hasCompleted = true; });
```

**UI condicional:**
```dart
if (_hasCompleted)
  _buildCompletedView() // Mostrar resultado
else
  _buildQuestionCards() // Mostrar preguntas
```

### SettingsScreen
```dart
// Cambiar hora
await HiveService.updateCheckinTime(hour, minute);
await NotificationService.scheduleDailyNotification(hour: hour, minute: minute);

// Estadísticas
final stats = HiveService.getStats();
// stats['total_days'], stats['current_streak'], stats['perfect_days'], stats['average_score']
```

---

## ⚙️ Configuración Android

### AndroidManifest.xml
```xml
<!-- Antes de <application> -->
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM"/>
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>

<!-- Dentro de <application>, después de <activity> -->
<receiver android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationReceiver" android:exported="false" />
<receiver android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver" android:exported="false">
  <intent-filter>
    <action android:name="android.intent.action.BOOT_COMPLETED"/>
  </intent-filter>
</receiver>
```

### build.gradle
```gradle
android {
    compileSdkVersion 34
    defaultConfig {
        minSdkVersion 21
        targetSdkVersion 34
    }
}
```

---

## 🚀 main.dart

```dart
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
  @override
  Widget build(BuildContext context) {
    final hasConfig = HiveService.hasUserConfig();
    
    return MaterialApp(
      theme: PipBoyTheme.theme,
      home: hasConfig ? const HomeScreen() : const OnboardingScreen(),
    );
  }
}
```

---

## 🧪 Testing & Comandos

```bash
# Generar adaptadores Hive
flutter pub run build_runner build --delete-conflicting-outputs

# Ejecutar en emulador
flutter run

# Limpiar y reconstruir
flutter clean
flutter pub get
flutter run
```

**Debug notificaciones:**
```bash
adb logcat | grep flutter
```

---

## 📝 Reglas de Negocio

1. **Reset diario automático**: Key de Hive = fecha actual → nuevo día = nueva key
2. **Un check-in por día**: `hasCompletedToday()` previene duplicados
3. **Notificación persistente**: Sobrevive reinicios del dispositivo
4. **Reprogramación automática**: Cambiar hora en settings actualiza la notificación
5. **Racha actual**: Se rompe si falta un día (no requiere días consecutivos perfectos)

---

## 🎨 UX Guidelines

- **Textos en MAYÚSCULAS** con letterSpacing para efecto terminal
- **Prefijos `>` y `//`** para labels y títulos
- **Glow effects** sutiles en bordes cyan
- **Loading states** con CircularProgressIndicator cyan
- **SnackBars** con colores según estado (success/warning/error)
- **Sin animaciones excesivas** - estética minimalista retro

---

## 🐛 Troubleshooting Común

**Notificaciones no aparecen:**
1. Verificar permisos en settings del sistema
2. Confirmar que `tz.initializeTimeZones()` esté en `init()`
3. Revisar que la hora programada sea futura

**Hive no persiste:**
1. Verificar que `.g.dart` existan (build_runner)
2. Confirmar `await box.put()` (no olvidar await)
3. Verificar que boxes estén abiertos en main()

**UI se corta en pantallas pequeñas:**
1. Usar `SingleChildScrollView` en todas las pantallas
2. Ajustar paddings dinámicamente si es necesario

---

## ✅ Checklist de Implementación

**Setup inicial:**
- [ ] Crear proyecto: `flutter create control_cabrera`
- [ ] Configurar pubspec.yaml
- [ ] Crear estructura de carpetas

**Modelos y servicios:**
- [ ] `user_config.dart` + adaptador
- [ ] `daily_checkin.dart` + adaptador
- [ ] `hive_service.dart` completo
- [ ] `notification_service.dart` completo
- [ ] Generar `.g.dart` con build_runner

**UI:**
- [ ] `pip_boy_theme.dart`
- [ ] `retro_button.dart`
- [ ] `retro_input.dart`
- [ ] `retro_container.dart`
- [ ] `onboarding_screen.dart`
- [ ] `home_screen.dart`
- [ ] `settings_screen.dart`

**Config Android:**
- [ ] AndroidManifest.xml (permisos + receivers)
- [ ] build.gradle (SDK versions)

**Testing:**
- [ ] Flujo completo: onboarding → check-in → settings
- [ ] Notificación programada
- [ ] Persistencia después de cerrar app
- [ ] Cambio de hora en settings

---


Implementa Control Cabrera siguiendo CLAUDE.md:
1. Crea la estructura de carpetas completa
2. Configura pubspec.yaml con las dependencias
3. Implementa modelos UserConfig y DailyCheckIn con anotaciones Hive
4. Genera adaptadores con build_runner
5. Implementa HiveService y NotificationService
6. Crea el tema PipBoyTheme y widgets retro
7. Implementa las 3 pantallas (Onboarding, Home, Settings)
8. Configura AndroidManifest.xml y build.gradle
9. Implementa main.dart
10. Verifica que compile sin errores

Prioriza funcionalidad core sobre features opcionales.


---

**Desarrollado con ☢️ estilo Pip-Boy**  
**v1.0.0 - Control Cabrera**
