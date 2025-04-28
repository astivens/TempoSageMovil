import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/constants/constants.dart';
import 'core/services/local_storage.dart';
import 'core/services/navigation_service.dart';
import 'core/services/notification_service.dart';
import 'core/services/service_locator.dart';
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
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize date formatting
  await initializeDateFormatting('es');

  // Initialize Hive and register adapters
  await Hive.initFlutter();

  // Registrar adaptadores
  Hive.registerAdapter(UserModelAdapter());
  Hive.registerAdapter(ActivityModelAdapter());
  Hive.registerAdapter(TimeBlockModelAdapter());
  Hive.registerAdapter(SettingsModelAdapter());
  Hive.registerAdapter(HabitModelAdapter());
  Hive.registerAdapter(TimeOfDayAdapter());
  // Hive.registerAdapter(TimeOfDayConverterAdapter()); // Comentado para evitar conflicto de typeId

  // Initialize local storage
  await LocalStorage.init();

  // Initialize services
  final notificationService = NotificationService();
  await notificationService.initialize();
  final settingsService = SettingsService();
  await settingsService.init();

  // Initialize repositories
  await ServiceLocator.instance.initializeAll();
  debugPrint('Servicios y repositorios inicializados');

  // Check if user is logged in
  final authService = AuthService();
  final currentUser = await authService.getCurrentUser();

  runApp(
    MyApp(
      isLoggedIn: currentUser != null,
      settingsService: settingsService,
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  final SettingsService settingsService;

  const MyApp({
    super.key,
    required this.isLoggedIn,
    required this.settingsService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => SettingsProvider(settingsService),
        ),
        ChangeNotifierProvider(
          create: (_) => DashboardController(
            activityRepository: ServiceLocator.instance.activityRepository,
            habitRepository: ServiceLocator.instance.habitRepository,
          ),
        ),
      ],
      child: AccessibleApp(
        child: MaterialApp(
          title: 'TempoSage',
          theme: AppStyles.lightTheme,
          darkTheme: AppStyles.darkTheme,
          themeMode: ThemeMode.dark,
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
                textScaler: const TextScaler.linear(1.0),
              ),
              child: child!,
            );
          },
        ),
      ),
    );
  }
}
