import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/services/local_storage.dart';
import 'core/services/navigation_service.dart';
import 'core/services/notification_service.dart';
import 'core/services/service_locator.dart';
import 'core/utils/logger.dart';
import 'core/theme/theme_manager.dart';
import 'core/l10n/app_localizations.dart';
import 'features/auth/data/models/user_model.dart';
import 'features/activities/data/models/activity_model_adapter.dart';
import 'features/timeblocks/data/models/time_block_model.dart';
import 'features/settings/data/models/settings_model.dart';
import 'features/habits/data/models/habit_model.dart';
import 'features/habits/data/models/time_of_day_adapter.dart';
import 'features/auth/data/services/auth_service.dart';
import 'features/settings/data/services/settings_service.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/home/presentation/screens/home_screen.dart';
import 'features/settings/presentation/screens/settings_screen.dart';
import 'features/settings/presentation/providers/settings_provider.dart';
import 'features/dashboard/controllers/dashboard_controller.dart';
import 'core/widgets/widgets.dart';
import 'services/test_recommendation.dart';

void main() async {
  await _initializeApp();
}

/// Inicializa todos los componentes necesarios para la aplicación
Future<void> _initializeApp() async {
  WidgetsFlutterBinding.ensureInitialized();
  final logger = Logger.instance;

  try {
    // Inicializar formateo de fechas
    await initializeDateFormatting('es');
    logger.i('Formateo de fechas inicializado', tag: 'App');

    // Inicializar servicios de almacenamiento
    await _initializeStorage();

    // Inicializar servicios de la aplicación
    final notificationService = NotificationService();
    await notificationService.initialize();

    final settingsService = SettingsService();
    await settingsService.init();

    // Inicializar repositorios
    await ServiceLocator.instance.initializeAll();
    logger.i('Servicios y repositorios inicializados', tag: 'App');

    // Programar notificaciones para actividades existentes
    await ServiceLocator.instance.activityNotificationService
        .scheduleAllActivityNotifications();

    // Programar notificaciones para hábitos existentes
    await ServiceLocator.instance.habitNotificationService
        .scheduleAllHabitNotifications();

    // Mostrar notificaciones inmediatas para actividades próximas (dentro de 1 hora)
    await _showImminentNotifications();

    logger.i('Notificaciones programadas', tag: 'App');

    // Verificar autenticación
    final authService = AuthService();
    final currentUser = await authService.getCurrentUser();

    // Obtener las configuraciones iniciales
    final settings = settingsService.settings;

    // Iniciar la aplicación
    runApp(
      MyApp(
        isLoggedIn: currentUser != null,
        settingsService: settingsService,
        initialSettings: settings,
      ),
    );
  } catch (e, stackTrace) {
    logger.c('Error al inicializar la aplicación',
        tag: 'App', error: e, stackTrace: stackTrace);
    // En caso de error crítico, mostrar una pantalla de error
    runApp(const ErrorApp());
  }
}

/// Inicializa los componentes de almacenamiento
Future<void> _initializeStorage() async {
  final logger = Logger.instance;

  try {
    // Inicializar Hive para almacenamiento local
    await LocalStorage.init();

    // Registrar adaptadores de modelos
    Hive.registerAdapter(UserModelAdapter());
    Hive.registerAdapter(ActivityModelAdapter());
    Hive.registerAdapter(TimeBlockModelAdapter());
    Hive.registerAdapter(SettingsModelAdapter());
    Hive.registerAdapter(HabitModelAdapter());
    Hive.registerAdapter(TimeOfDayAdapter());
    // Hive.registerAdapter(TimeOfDayConverterAdapter()); // Comentado para evitar conflicto de typeId

    logger.i('Adaptadores de Hive registrados', tag: 'Storage');
  } catch (e, stackTrace) {
    logger.e('Error al inicializar almacenamiento',
        tag: 'Storage', error: e, stackTrace: stackTrace);
    rethrow;
  }
}

/// Muestra notificaciones inmediatas para actividades y hábitos próximos
Future<void> _showImminentNotifications() async {
  try {
    final logger = Logger.instance;
    final activityRepo = ServiceLocator.instance.activityRepository;
    final notificationService = ServiceLocator.instance.notificationService;

    // Obtener la fecha actual
    final now = DateTime.now();

    // Obtener actividades del día actual
    final activities = await activityRepo.getActivitiesByDate(now);

    // Filtrar actividades que comenzarán dentro de 1 hora
    final upcomingActivities = activities.where((activity) {
      // Si la actividad ya está completada, no mostrar notificación
      if (activity.isCompleted) return false;

      // Calcular tiempo hasta el inicio de la actividad
      final timeUntilStart = activity.startTime.difference(now);

      // Si la actividad comienza en menos de 60 minutos y no ha pasado
      return timeUntilStart.inMinutes <= 60 && timeUntilStart.inMinutes > 0;
    }).toList();

    logger.i('Actividades próximas encontradas: ${upcomingActivities.length}',
        tag: 'Notifications');

    // Mostrar notificaciones para actividades próximas
    for (final activity in upcomingActivities) {
      final minutesUntilStart = activity.startTime.difference(now).inMinutes;

      await notificationService.showNotification(
        title: 'Actividad próxima',
        body: '${activity.title} comienza en $minutesUntilStart minutos',
        category: NotificationCategory.activities,
        id: activity.id.hashCode,
        payload: 'activity:${activity.id}',
      );

      logger.i(
          'Notificación inmediata mostrada para actividad: ${activity.title}',
          tag: 'Notifications');
    }

    // Nota: también se podrían mostrar hábitos del día actual que deban completarse pronto
  } catch (e) {
    debugPrint('Error al mostrar notificaciones inmediatas: $e');
  }
}

/// Aplicación principal
class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  final SettingsService settingsService;
  final SettingsModel initialSettings;

  const MyApp({
    super.key,
    required this.isLoggedIn,
    required this.settingsService,
    required this.initialSettings,
  });

  @override
  Widget build(BuildContext context) {
    // Crear una instancia de ThemeManager con las configuraciones iniciales
    final themeManager = ThemeManager(
      isDarkMode: initialSettings.darkMode,
      isHighContrast: initialSettings.highContrastMode,
      textScaleFactor: initialSettings.fontSizeScale.toDouble(),
    );

    return MultiProvider(
      providers: [
        // Proveedor de configuraciones
        ChangeNotifierProvider(
          create: (_) => SettingsProvider(settingsService),
        ),
        // Proveedor de temas
        ChangeNotifierProvider(
          create: (_) => themeManager,
        ),
        // Otros proveedores
        ChangeNotifierProvider(
          create: (_) => DashboardController(
            activityRepository: ServiceLocator.instance.activityRepository,
            habitRepository: ServiceLocator.instance.habitRepository,
          ),
        ),
      ],
      child: Consumer2<SettingsProvider, ThemeManager>(
        builder: (context, settingsProvider, themeManager, _) {
          // Usar un efecto post-frame para actualizar el tema
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (themeManager.isDarkMode != settingsProvider.settings.darkMode ||
                themeManager.isHighContrast !=
                    settingsProvider.settings.highContrastMode ||
                themeManager.textScaleFactor !=
                    settingsProvider.settings.fontSizeScale.toDouble()) {
              themeManager.updateFromSettings(settingsProvider);
            }
          });

          return AccessibleApp(
            highContrast: themeManager.isHighContrast,
            textScale: themeManager.textScaleFactor,
            child: MaterialApp(
              title: 'TempoSage',
              theme: themeManager.lightTheme,
              darkTheme: themeManager.darkTheme,
              themeMode: themeManager.themeMode,
              navigatorKey: NavigationService.navigatorKey,
              initialRoute: isLoggedIn ? '/home' : '/login',
              localizationsDelegates:
                  AppLocalizationsSetup.localizationsDelegates,
              supportedLocales: AppLocalizationsSetup.supportedLocales,
              locale: Locale(settingsProvider.settings.language),
              routes: {
                '/login': (context) => const LoginScreen(),
                '/home': (context) => const HomeScreen(),
                '/settings': (context) => const SettingsScreen(),
                '/test-recommendation': (context) =>
                    const TestRecommendationPage(),
              },
              builder: (context, child) {
                return MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    textScaler: TextScaler.linear(themeManager.textScaleFactor),
                  ),
                  child: child!,
                );
              },
            ),
          );
        },
      ),
    );
  }
}

/// Pantalla para mostrar cuando la aplicación no pudo inicializarse
class ErrorApp extends StatelessWidget {
  const ErrorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 80,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              const Text(
                'Error al iniciar la aplicación',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Por favor, reinicie la aplicación o contacte soporte.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  _initializeApp();
                },
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
