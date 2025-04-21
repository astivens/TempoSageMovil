import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'core/constants/constants.dart';
import 'core/services/local_storage.dart';
import 'core/services/navigation_service.dart';
import 'core/services/notification_service.dart';
import 'core/services/service_locator.dart';
import 'features/auth/data/models/user_model.dart';
import 'features/activities/data/models/activity_model.dart';
import 'features/timeblocks/data/models/time_block_model.dart';
import 'features/settings/data/models/settings_model.dart';
import 'features/auth/data/services/auth_service.dart';
import 'features/settings/data/services/settings_service.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/home/presentation/screens/home_screen.dart';
import 'features/settings/presentation/screens/settings_screen.dart';
import 'features/settings/presentation/providers/settings_provider.dart';
import 'core/widgets/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'features/habits/cubit/habit_cubit.dart';
import 'features/habits/data/repositories/habit_repository_impl.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();
  Hive.registerAdapter(UserModelAdapter());
  Hive.registerAdapter(ActivityModelAdapter());
  Hive.registerAdapter(TimeBlockModelAdapter());
  Hive.registerAdapter(SettingsModelAdapter());

  // Initialize services
  await LocalStorage.init();
  final notificationService = NotificationService();
  await notificationService.initialize();
  final settingsService = SettingsService();
  await settingsService.init();

  // Initialize repositories
  await ServiceLocator.instance.activityRepository.init();
  await ServiceLocator.instance.timeBlockRepository.init();

  // Check if user is logged in
  final authService = AuthService();
  final currentUser = await authService.getCurrentUser();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => HabitCubit(HabitRepositoryImpl()),
        ),
      ],
      child: MyApp(
        isLoggedIn: currentUser != null,
        settingsService: settingsService,
      ),
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
      ],
      child: AccessibleApp(
        child: MaterialApp(
          title: 'TempoSage',
          theme: AppStyles.lightTheme,
          darkTheme: AppStyles.darkTheme,
          themeMode: ThemeMode.dark,
          navigatorKey: NavigationService.navigatorKey,
          initialRoute: isLoggedIn ? '/home' : '/login',
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
