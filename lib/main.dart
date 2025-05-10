import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/services/local_storage.dart';
import 'core/services/navigation_service.dart';
import 'core/services/notification_service.dart';
import 'core/services/service_locator.dart';
import 'core/utils/logger.dart';
import 'core/theme/theme_manager.dart';
import 'features/auth/data/models/user_model.dart';
import 'features/activities/data/models/activity_model.dart';
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
          // Actualizar el ThemeManager cuando cambien las configuraciones
          themeManager.updateFromSettings(settingsProvider);

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
              localizationsDelegates: const [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: const [
                Locale('es'),
                Locale('en'),
              ],
              locale: const Locale('es'),
              routes: {
                '/login': (context) => const LoginScreen(),
                '/home': (context) => const HomeScreen(),
                '/settings': (context) => const SettingsScreen(),
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
