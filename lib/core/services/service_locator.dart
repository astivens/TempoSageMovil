import '../../features/activities/data/repositories/activity_repository.dart';
import '../../features/activities/domain/services/activity_to_timeblock_service.dart';
import '../../features/activities/domain/services/activity_notification_service.dart';
import '../../features/timeblocks/data/repositories/time_block_repository.dart';
import '../../features/habits/domain/repositories/habit_repository.dart';
import '../../features/habits/data/repositories/habit_repository_impl.dart';
import '../../features/habits/domain/services/habit_to_timeblock_service.dart';
import '../../features/habits/domain/services/habit_notification_service.dart';
import '../../features/habits/domain/usecases/get_habits_use_case.dart';
import '../utils/logger.dart';
import 'tempo_sage_api_service.dart';
import 'notification_service.dart';
import 'recommendation_service.dart';
import '../../features/activities/domain/usecases/suggest_optimal_time_use_case.dart';

/// Localizador de servicios e implementación de inyección de dependencias.
///
/// Responsable de:
/// - Crear e inicializar repositorios y servicios
/// - Proporcionar acceso a las dependencias en toda la aplicación
/// - Gestionar el ciclo de vida de las dependencias
class ServiceLocator {
  static final ServiceLocator instance = ServiceLocator._internal();
  final Logger _logger = Logger.instance;

  /// Constructor privado para el patrón Singleton
  ServiceLocator._internal() {
    _initRepositories();
  }

  // Repositorios (almacenamiento)
  late final ActivityRepository _activityRepository;
  late final TimeBlockRepository _timeBlockRepository;
  late final HabitRepository _habitRepository;

  // Servicios (lógica de dominio) - inicialización perezosa
  ActivityToTimeBlockService? _activityToTimeBlockService;
  HabitToTimeBlockService? _habitToTimeBlockService;
  TempoSageApiService? _tempoSageApiService;
  NotificationService? _notificationService;
  ActivityNotificationService? _activityNotificationService;
  HabitNotificationService? _habitNotificationService;

  // Casos de uso - inicialización perezosa
  GetHabitsUseCase? _getHabitsUseCase;

  late final RecommendationService recommendationService;
  late final SuggestOptimalTimeUseCase suggestOptimalTimeUseCase;

  /// Inicializa los repositorios de la aplicación.
  /// Este método se llama automáticamente al crear la instancia del ServiceLocator.
  void _initRepositories() {
    try {
      _logger.i('Inicializando repositorios...', tag: 'ServiceLocator');

      // Crear repositorios
      _timeBlockRepository = TimeBlockRepository();
      _habitRepository = HabitRepositoryImpl();
      _activityRepository = ActivityRepository(
        timeBlockRepository: _timeBlockRepository,
      );

      _logger.i('Repositorios inicializados correctamente',
          tag: 'ServiceLocator');
    } catch (e, stackTrace) {
      _logger.e('Error al inicializar repositorios',
          tag: 'ServiceLocator', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Obtiene el repositorio de actividades.
  ActivityRepository get activityRepository => _activityRepository;

  /// Obtiene el repositorio de bloques de tiempo.
  TimeBlockRepository get timeBlockRepository => _timeBlockRepository;

  /// Obtiene el repositorio de hábitos.
  HabitRepository get habitRepository => _habitRepository;

  /// Inicializa todos los repositorios, preparándolos para su uso.
  /// Debe llamarse al inicio de la aplicación antes de acceder a los repositorios.
  Future<void> initializeAll() async {
    try {
      _logger.i('Inicializando todos los repositorios...',
          tag: 'ServiceLocator');

      // Inicializar repositorios
      await _activityRepository.init();
      await _timeBlockRepository.init();
      await _habitRepository.init();

      // Inicializar servicios de recomendación
      recommendationService = RecommendationService();
      await recommendationService.initialize();

      suggestOptimalTimeUseCase = SuggestOptimalTimeUseCase();

      _logger.i('Todos los repositorios inicializados correctamente',
          tag: 'ServiceLocator');
    } catch (e, stackTrace) {
      _logger.e('Error al inicializar todos los repositorios',
          tag: 'ServiceLocator', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Obtiene el servicio para convertir actividades a bloques de tiempo.
  /// El servicio se crea bajo demanda (lazy initialization).
  ActivityToTimeBlockService get activityToTimeBlockService {
    _activityToTimeBlockService ??= ActivityToTimeBlockService(
      activityRepository: activityRepository,
      timeBlockRepository: timeBlockRepository,
    );
    return _activityToTimeBlockService!;
  }

  /// Obtiene el servicio para convertir hábitos a bloques de tiempo.
  /// El servicio se crea bajo demanda (lazy initialization).
  HabitToTimeBlockService get habitToTimeBlockService {
    _habitToTimeBlockService ??=
        HabitToTimeBlockService(_habitRepository, timeBlockRepository);
    return _habitToTimeBlockService!;
  }

  /// Obtiene el caso de uso para gestionar hábitos.
  /// Se crea bajo demanda (lazy initialization).
  GetHabitsUseCase get getHabitsUseCase {
    _getHabitsUseCase ??= GetHabitsUseCase(_habitRepository);
    return _getHabitsUseCase!;
  }

  /// Obtiene el servicio de API de TempoSage.
  /// Se crea bajo demanda (lazy initialization).
  TempoSageApiService get tempoSageApiService {
    _tempoSageApiService ??= TempoSageApiService();
    return _tempoSageApiService!;
  }

  /// Obtiene el servicio de notificaciones.
  /// Se crea bajo demanda (lazy initialization).
  NotificationService get notificationService {
    _notificationService ??= NotificationService();
    return _notificationService!;
  }

  /// Obtiene el servicio de notificaciones de actividades.
  /// Se crea bajo demanda (lazy initialization).
  ActivityNotificationService get activityNotificationService {
    _activityNotificationService ??= ActivityNotificationService(
      notificationService,
      activityRepository,
    );
    return _activityNotificationService!;
  }

  /// Obtiene el servicio de notificaciones de hábitos.
  /// Se crea bajo demanda (lazy initialization).
  HabitNotificationService get habitNotificationService {
    _habitNotificationService ??= HabitNotificationService(
      notificationService,
      habitRepository,
    );
    return _habitNotificationService!;
  }

  /// Reinicia todos los servicios y limpia cachés.
  /// Útil para pruebas o cuando se requiere un estado limpio.
  void resetServices() {
    _activityToTimeBlockService = null;
    _habitToTimeBlockService = null;
    _getHabitsUseCase = null;
    _tempoSageApiService = null;
    _notificationService = null;
    _activityNotificationService = null;
    _habitNotificationService = null;
    _logger.i('Servicios reiniciados', tag: 'ServiceLocator');
  }

  void dispose() {
    resetServices();
    recommendationService.dispose();
  }
}
