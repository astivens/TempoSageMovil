import 'package:get_it/get_it.dart';

import '../../features/habits/data/repositories/habit_repository_impl.dart';
import '../../features/habits/domain/repositories/habit_repository.dart';
import '../../features/habits/domain/usecases/get_habits_use_case.dart';
import '../../features/habits/domain/services/habit_to_timeblock_service.dart';
import '../../features/timeblocks/data/repositories/time_block_repository.dart';
import '../../features/activities/data/repositories/activity_repository.dart';
import '../../services/google_ai_service.dart';
import '../../services/tflite_service.dart';
import '../../core/services/recommendation_service.dart';
import '../../features/chat/services/ml_data_processor.dart';

/// Singleton instance of GetIt
final getIt = GetIt.instance;

/// Configura todas las dependencias para la aplicación
Future<void> setupDependencies() async {
  await _setupCoreServices();
  await _setupRepositories();
  await _setupUseCases();
  await _setupServices();
}

/// Configura servicios del core como logging, conexiones, etc.
Future<void> _setupCoreServices() async {
  // Registra servicios centrales aquí

  // TFLite Service - Se registra primero ya que otros servicios dependen de él
  getIt.registerSingleton<TFLiteService>(TFLiteService());
  await getIt<TFLiteService>().init();

  // Recommendation Service
  getIt.registerSingleton<RecommendationService>(RecommendationService());
  await getIt<RecommendationService>().initialize();

  // GoogleAIService - Reemplaza 'TU_API_KEY' con la clave real en producción
  getIt.registerSingleton<GoogleAIService>(
    GoogleAIService(
        apiKey: const String.fromEnvironment('GOOGLE_AI_API_KEY',
            defaultValue: 'TU_API_KEY')),
  );

  // MLDataProcessor
  getIt.registerFactory<MLDataProcessor>(() => MLDataProcessor(
      tfliteService: getIt<TFLiteService>(),
      recommendationService: getIt<RecommendationService>()));
}

/// Configura repositorios
Future<void> _setupRepositories() async {
  // Registramos los repositorios como singletons

  // TimeBlockRepository
  getIt.registerSingleton<TimeBlockRepository>(
    TimeBlockRepository(),
  );

  // Inicializar el repositorio
  await getIt<TimeBlockRepository>().init();

  // HabitRepository
  getIt.registerSingleton<HabitRepository>(
    HabitRepositoryImpl(),
  );

  // Inicializar el repositorio
  // cast es seguro porque sabemos que HabitRepositoryImpl implementa HabitRepository
  await (getIt<HabitRepository>() as HabitRepositoryImpl).init();

  // ActivityRepository
  getIt.registerSingleton<ActivityRepository>(
    ActivityRepository(
      timeBlockRepository: getIt<TimeBlockRepository>(),
    ),
  );

  // Inicializar el repositorio
  await getIt<ActivityRepository>().init();
}

/// Configura casos de uso
Future<void> _setupUseCases() async {
  // GetHabitsUseCase
  getIt.registerFactory<GetHabitsUseCase>(
    () => GetHabitsUseCase(getIt<HabitRepository>()),
  );

  // Registra más casos de uso aquí
}

/// Configura servicios de dominio
Future<void> _setupServices() async {
  // HabitToTimeBlockService
  getIt.registerLazySingleton<HabitToTimeBlockService>(
    () => HabitToTimeBlockService(
      getIt<HabitRepository>(),
      getIt<TimeBlockRepository>(),
    ),
  );

  // Registra más servicios aquí
}

/// Resetea todas las dependencias registradas (útil para pruebas)
void resetDependencies() {
  getIt.reset();
}
