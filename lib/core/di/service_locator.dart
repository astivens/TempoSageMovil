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
import '../../core/services/ml_ai_integration_service.dart';
import '../../core/services/csv_service.dart';
import '../../core/services/ml_model_adapter.dart';
import '../../core/services/debug_data_service.dart';
import '../../features/chat/services/ml_data_processor.dart';
import '../config/ai_config.dart';
import '../../services/activity_recommendation_controller.dart';
import '../../features/habits/domain/services/habit_recommendation_service.dart';
import '../../features/habits/domain/services/habit_to_timeblock_service.dart';

/// Singleton instance of GetIt
final getIt = GetIt.instance;

/// Configura todas las dependencias para la aplicación
Future<void> setupDependencies() async {
  // Verificar si ya están configuradas las dependencias
  if (getIt.isRegistered<TFLiteService>()) {
    print('⚠️  Dependencias ya configuradas, saltando configuración...');
    return;
  }
  
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

  // CSV Service
  getIt.registerSingleton<CSVService>(CSVService());

  // ML Model Adapter
  getIt.registerSingleton<MlModelAdapter>(MlModelAdapter());

  // Recommendation Service
  getIt.registerSingleton<RecommendationService>(RecommendationService());
  await getIt<RecommendationService>().initialize();

  // GoogleAIService - Configuración mejorada para Google AI Studio
  if (AIConfig.isGoogleAIConfigured) {
    getIt.registerSingleton<GoogleAIService>(
      GoogleAIService(apiKey: AIConfig.googleAIAPIKey),
    );
    print('✅ GoogleAIService registrado con API key válida');
  } else {
    // Registrar un servicio mock para desarrollo sin API key
    print('⚠️  ${AIConfig.configurationErrorMessage}');
    getIt.registerSingleton<GoogleAIService>(
      GoogleAIService(apiKey: 'mock_key_for_development'),
    );
    print('⚠️  GoogleAIService registrado con API key mock');
  }

  // MLDataProcessor
  getIt.registerFactory<MLDataProcessor>(() => MLDataProcessor(
      tfliteService: getIt<TFLiteService>(),
      recommendationService: getIt<RecommendationService>(),
      csvService: getIt<CSVService>(),
      mlModelAdapter: getIt<MlModelAdapter>()));

  // ML-AI Integration Service - Servicio que combina ML local con Google AI
  getIt.registerSingleton<MLAIIntegrationService>(
    MLAIIntegrationService(
      recommendationService: getIt<RecommendationService>(),
      csvService: getIt<CSVService>(),
      googleAIService: getIt<GoogleAIService>(),
      mlModelAdapter: getIt<MlModelAdapter>(),
    ),
  );
  print('✅ MLAIIntegrationService registrado correctamente');
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

  // ActivityRecommendationController
  getIt.registerLazySingleton<ActivityRecommendationController>(
    () => ActivityRecommendationController(),
  );

  // HabitRecommendationService
  getIt.registerLazySingleton<HabitRecommendationService>(
    () => HabitRecommendationService(
      recommendationService: getIt<RecommendationService>(),
      habitRepository: getIt<HabitRepository>(),
    ),
  );

  // Registra más servicios aquí
}

/// Resetea todas las dependencias registradas (útil para pruebas)
void resetDependencies() {
  getIt.reset();
}
