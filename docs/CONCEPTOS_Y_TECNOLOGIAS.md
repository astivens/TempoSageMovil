# 📚 Conceptos y Tecnologías - TempoSage

## 📋 Tabla de Contenido
- [Tecnologías Core](#-tecnologías-core)
- [Patrones de Diseño](#-patrones-de-diseño)
- [Gestión de Estado](#-gestión-de-estado)
- [Persistencia de Datos](#-persistencia-de-datos)
- [Conceptos Avanzados](#-conceptos-avanzados)
- [Herramientas de Desarrollo](#-herramientas-de-desarrollo)

---

## 🔷 Tecnologías Core

### 1. **Freezed** - Generación Automática de Código Inmutable

#### ¿Qué es Freezed?
Freezed es un generador de código para Dart que crea automáticamente clases inmutables con funcionalidades como `copyWith()`, `toString()`, `hashCode`, `==` y serialización JSON.

#### ¿Para qué sirve?
- **Inmutabilidad**: Evita bugs por modificaciones accidentales
- **Menos boilerplate**: Genera automáticamente métodos repetitivos
- **Type safety**: Garantiza tipos seguros en tiempo de compilación
- **Serialización**: JSON automático sin escribir código manual

#### Ejemplo Práctico
```dart
// Sin Freezed (código manual extenso)
class ActivityModel {
  final String id;
  final String title;
  final bool isCompleted;
  
  ActivityModel({
    required this.id,
    required this.title,
    required this.isCompleted,
  });
  
  // Método copyWith manual
  ActivityModel copyWith({
    String? id,
    String? title,
    bool? isCompleted,
  }) {
    return ActivityModel(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
  
  // equals y hashCode manuales
  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ActivityModel &&
            other.id == id &&
            other.title == title &&
            other.isCompleted == isCompleted);
  }
  
  @override
  int get hashCode => Object.hash(id, title, isCompleted);
  
  // toString manual
  @override
  String toString() {
    return 'ActivityModel(id: $id, title: $title, isCompleted: $isCompleted)';
  }
  
  // Serialización JSON manual
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'isCompleted': isCompleted,
    };
  }
  
  factory ActivityModel.fromJson(Map<String, dynamic> json) {
    return ActivityModel(
      id: json['id'] as String,
      title: json['title'] as String,
      isCompleted: json['isCompleted'] as bool,
    );
  }
}

// Con Freezed (código mínimo, funcionalidad máxima)
@freezed
class ActivityModel with _$ActivityModel {
  const ActivityModel._(); // Constructor privado para métodos adicionales
  
  const factory ActivityModel({
    required String id,
    required String title,
    @Default(false) bool isCompleted,
    @Default('') String description,
  }) = _ActivityModel;
  
  // Serialización automática
  factory ActivityModel.fromJson(Map<String, dynamic> json) =>
      _$ActivityModelFromJson(json);
  
  // Métodos de dominio personalizados
  bool get isOverdue => DateTime.now().isAfter(endTime);
  
  ActivityModel toggleCompletion() => copyWith(isCompleted: !isCompleted);
}
```

#### Generación de Código
```bash
# Comando para generar código Freezed
flutter packages pub run build_runner build

# Genera automáticamente:
# - activity_model.freezed.dart (métodos inmutables)
# - activity_model.g.dart (serialización JSON)
```

#### Características Generadas Automáticamente
- ✅ `copyWith()` - Crear copias con cambios
- ✅ `toString()` - Representación legible
- ✅ `operator ==` - Comparación por valor
- ✅ `hashCode` - Hash consistente
- ✅ `fromJson()` / `toJson()` - Serialización JSON
- ✅ Union types - Múltiples variantes de una clase

### 2. **Service Locator Pattern** - Gestión de Dependencias

#### ¿Qué es Service Locator?
Es un patrón de diseño que proporciona un registro central donde los servicios pueden registrarse y luego localizarse cuando se necesiten.

#### ¿Para qué sirve?
- **Desacoplamiento**: Los objetos no necesitan conocer cómo crear sus dependencias
- **Singleton management**: Gestiona instancias únicas de servicios
- **Facilidad de testing**: Permite sustituir servicios por mocks
- **Configuración centralizada**: Un lugar para toda la configuración de DI

#### Implementación en TempoSage
```dart
class ServiceLocator {
  static final ServiceLocator instance = ServiceLocator._internal();
  
  // Singleton pattern
  ServiceLocator._internal() {
    _initRepositories();
    _initServices();
  }
  
  // === REPOSITORIES ===
  late final ActivityRepository _activityRepository;
  late final TimeBlockRepository _timeBlockRepository;
  late final HabitRepository _habitRepository;
  
  ActivityRepository get activityRepository => _activityRepository;
  TimeBlockRepository get timeBlockRepository => _timeBlockRepository;
  HabitRepository get habitRepository => _habitRepository;
  
  // === SERVICES ===
  NotificationService? _notificationService;
  MLRecommendationService? _mlService;
  
  // Lazy initialization (se crea solo cuando se necesita)
  NotificationService get notificationService {
    _notificationService ??= NotificationService();
    return _notificationService!;
  }
  
  MLRecommendationService get mlService {
    _mlService ??= MLRecommendationService();
    return _mlService!;
  }
  
  void _initRepositories() {
    // Inyección de dependencias manual
    _timeBlockRepository = TimeBlockRepository();
    _habitRepository = HabitRepository();
    _activityRepository = ActivityRepository(
      timeBlockRepository: _timeBlockRepository, // Dependencia inyectada
    );
  }
  
  void _initServices() {
    // Los servicios se inicializan lazily
    debugPrint('🔧 ServiceLocator inicializado');
  }
  
  // Para testing: permite reemplazar servicios
  void registerTestRepository<T>(T repository) {
    if (T == ActivityRepository) {
      _activityRepository = repository as ActivityRepository;
    }
    // Más repositorios...
  }
}
```

#### Comparación con otros patrones
```dart
// 🔷 SERVICE LOCATOR (TempoSage)
class ActivityScreen extends StatefulWidget {
  @override
  _ActivityScreenState createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  late final ActivityRepository _repository;
  
  @override
  void initState() {
    super.initState();
    // Obtener dependencia del locator
    _repository = ServiceLocator.instance.activityRepository;
  }
}

// 🔶 CONSTRUCTOR INJECTION (Alternativa)
class ActivityScreen extends StatefulWidget {
  final ActivityRepository repository;
  
  const ActivityScreen({required this.repository});
  
  @override
  _ActivityScreenState createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  late final ActivityRepository _repository;
  
  @override
  void initState() {
    super.initState();
    _repository = widget.repository; // Recibido por constructor
  }
}

// 🔵 PROVIDER (Alternativa)
class ActivityScreen extends StatefulWidget {
  @override
  _ActivityScreenState createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  @override
  Widget build(BuildContext context) {
    // Obtener del Provider context
    final repository = Provider.of<ActivityRepository>(context, listen: false);
    return Container();
  }
}
```

#### Ventajas y Desventajas

| Aspecto | Service Locator | Constructor Injection |
|---------|----------------|----------------------|
| **Facilidad de uso** | ✅ Muy simple | ❌ Requiere configuración |
| **Explicitez de dependencias** | ❌ Dependencias ocultas | ✅ Dependencias claras |
| **Testing** | ⚠️ Requiere configuración | ✅ Fácil de mockear |
| **Acoplamiento** | ⚠️ Acoplado al locator | ✅ Bajo acoplamiento |
| **Flutter idiomático** | ✅ Común en Flutter | ❌ Menos común |

### 3. **Migration Service** - Sistema de Migraciones de Datos

#### ¿Qué es un Migration Service?
Es un sistema que permite evolucionar la estructura de datos de una aplicación sin perder información del usuario, ejecutando cambios de forma automática y versionada.

#### ¿Para qué sirve?
- **Evolución de datos**: Cambiar estructura sin perder datos del usuario
- **Limpieza automática**: Corregir inconsistencias y duplicados
- **Versionado**: Control preciso de qué cambios se han aplicado
- **Rollback seguro**: Posibilidad de revertir cambios si es necesario

#### Implementación Detallada
```dart
class MigrationService {
  static const String _lastMigrationKey = 'last_migration_version';
  static const int _currentMigrationVersion = 3; // Versión actual
  
  /// Ejecuta todas las migraciones necesarias
  static Future<void> runMigrations() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastMigration = prefs.getInt(_lastMigrationKey) ?? 0;
      
      debugPrint('🔄 Verificando migraciones...');
      debugPrint('   📊 Última migración: $lastMigration');
      debugPrint('   🎯 Migración actual: $_currentMigrationVersion');
      
      if (lastMigration < _currentMigrationVersion) {
        debugPrint('🚀 Ejecutando migraciones...');
        
        // Ejecutar migraciones en orden secuencial
        if (lastMigration < 1) {
          await _migrationV1CleanDuplicateTimeBlocks();
        }
        
        if (lastMigration < 2) {
          await _migrationV2AddCategoryField();
        }
        
        if (lastMigration < 3) {
          await _migrationV3UpdateNotificationFormat();
        }
        
        // Actualizar versión de migración
        await prefs.setInt(_lastMigrationKey, _currentMigrationVersion);
        debugPrint('✅ Migraciones completadas');
      } else {
        debugPrint('✨ No se requieren migraciones');
      }
    } catch (e) {
      debugPrint('❌ Error ejecutando migraciones: $e');
      // No relanzar para no bloquear la app
    }
  }
  
  /// Migración V1: Limpia time blocks duplicados
  static Future<void> _migrationV1CleanDuplicateTimeBlocks() async {
    try {
      debugPrint('🧹 Migración V1: Limpiando time blocks duplicados...');
      
      // Analizar el problema
      final stats = await DuplicateTimeBlockCleaner.analyzeDuplicates();
      
      if (stats['totalDuplicates'] != null && stats['totalDuplicates']! > 0) {
        debugPrint('🔍 Encontrados ${stats['totalDuplicates']} duplicados');
        
        // Ejecutar limpieza
        final removedCount = await DuplicateTimeBlockCleaner.cleanAllDuplicates();
        debugPrint('✅ Migración V1: $removedCount duplicados eliminados');
      } else {
        debugPrint('✨ No se encontraron duplicados');
      }
    } catch (e) {
      debugPrint('❌ Error en migración V1: $e');
    }
  }
  
  /// Migración V2: Agrega campo categoria a actividades existentes
  static Future<void> _migrationV2AddCategoryField() async {
    try {
      debugPrint('🔄 Migración V2: Agregando campo categoria...');
      
      final box = await Hive.openBox<ActivityModel>('activities');
      int updatedCount = 0;
      
      for (final key in box.keys) {
        final activity = box.get(key);
        if (activity != null && activity.category.isEmpty) {
          // Agregar categoría por defecto basada en horario
          String defaultCategory = _determineDefaultCategory(activity);
          
          final updatedActivity = activity.copyWith(category: defaultCategory);
          await box.put(key, updatedActivity);
          updatedCount++;
        }
      }
      
      debugPrint('✅ Migración V2: $updatedCount actividades actualizadas');
    } catch (e) {
      debugPrint('❌ Error en migración V2: $e');
    }
  }
  
  /// Migración V3: Actualiza formato de notificaciones
  static Future<void> _migrationV3UpdateNotificationFormat() async {
    try {
      debugPrint('🔔 Migración V3: Actualizando formato de notificaciones...');
      
      // Cancelar todas las notificaciones existentes con formato antiguo
      await ServiceLocator.instance.notificationService.cancelAllNotifications();
      
      // Reagendar todas las actividades activas con nuevo formato
      final activityRepo = ServiceLocator.instance.activityRepository;
      final activities = await activityRepo.getAllActivities();
      
      int rescheduledCount = 0;
      for (final activity in activities) {
        if (activity.sendReminder && !activity.isCompleted) {
          await ServiceLocator.instance.notificationService
              .scheduleActivityNotification(activity);
          rescheduledCount++;
        }
      }
      
      debugPrint('✅ Migración V3: $rescheduledCount notificaciones reagendadas');
    } catch (e) {
      debugPrint('❌ Error en migración V3: $e');
    }
  }
  
  static String _determineDefaultCategory(ActivityModel activity) {
    final hour = activity.startTime.hour;
    
    if (hour >= 6 && hour < 12) return 'Mañana';
    if (hour >= 12 && hour < 18) return 'Tarde';
    if (hour >= 18 && hour < 22) return 'Noche';
    return 'Madrugada';
  }
  
  /// Verificación de salud del sistema
  static Future<Map<String, dynamic>> systemHealthCheck() async {
    try {
      debugPrint('🔍 Verificación de salud del sistema...');
      
      final health = <String, dynamic>{
        'timestamp': DateTime.now().toIso8601String(),
        'migrations': {},
        'data_integrity': {},
        'status': 'healthy',
        'warnings': <String>[],
        'errors': <String>[],
      };
      
      // Verificar estado de migraciones
      final prefs = await SharedPreferences.getInstance();
      final lastMigration = prefs.getInt(_lastMigrationKey) ?? 0;
      
      health['migrations'] = {
        'lastExecuted': lastMigration,
        'current': _currentMigrationVersion,
        'needsMigration': lastMigration < _currentMigrationVersion,
      };
      
      if (lastMigration < _currentMigrationVersion) {
        health['warnings'].add('Hay migraciones pendientes');
        health['status'] = 'warning';
      }
      
      // Verificar integridad de datos
      final duplicateStats = await DuplicateTimeBlockCleaner.analyzeDuplicates();
      health['data_integrity'] = duplicateStats;
      
      if (duplicateStats['totalDuplicates'] > 0) {
        health['warnings'].add('Se encontraron ${duplicateStats['totalDuplicates']} duplicados');
        health['status'] = 'warning';
      }
      
      debugPrint('📊 Salud del sistema: ${health['status']}');
      return health;
    } catch (e) {
      return {
        'status': 'error',
        'errors': ['Error en verificación: $e'],
      };
    }
  }
}
```

#### Casos de Uso Reales
```dart
// Ejemplo 1: Agregar nuevo campo a modelo existente
// Antes (V1)
@freezed
class ActivityModel with _$ActivityModel {
  const factory ActivityModel({
    required String id,
    required String title,
    // Sin campo priority
  }) = _ActivityModel;
}

// Después (V2)
@freezed
class ActivityModel with _$ActivityModel {
  const factory ActivityModel({
    required String id,
    required String title,
    @Default('Media') String priority, // ← Nuevo campo
  }) = _ActivityModel;
}

// Migración para datos existentes
static Future<void> _migrationV2AddPriorityField() async {
  final box = await Hive.openBox<ActivityModel>('activities');
  
  for (final key in box.keys) {
    final activity = box.get(key);
    if (activity != null) {
      // Si el campo no existe (datos antiguos), agregar valor por defecto
      final updated = activity.copyWith(priority: 'Media');
      await box.put(key, updated);
    }
  }
}
```

### 4. **Hive** - Base de Datos NoSQL Local

#### ¿Qué es Hive?
Hive es una base de datos NoSQL ligera, escrita en Dart puro, que almacena datos en cajas (boxes) como pares clave-valor.

#### ¿Para qué sirve?
- **Persistencia offline**: Datos disponibles sin conexión
- **Performance**: Muy rápida para lectura/escritura
- **Tipado fuerte**: Soporte nativo para objetos Dart
- **Multiplataforma**: Funciona en todas las plataformas de Flutter

#### Configuración y Uso
```dart
// Configuración inicial (main.dart)
Future<void> _initializeStorage() async {
  // Inicializar Hive
  await Hive.initFlutter();
  
  // Registrar adaptadores de tipos personalizados
  Hive.registerAdapter(ActivityModelAdapter());
  Hive.registerAdapter(TimeBlockModelAdapter());
  Hive.registerAdapter(HabitModelAdapter());
  
  // Abrir cajas necesarias
  await Hive.openBox<ActivityModel>('activities');
  await Hive.openBox<TimeBlockModel>('timeblocks');
  await Hive.openBox<HabitModel>('habits');
  await Hive.openBox('settings'); // Caja genérica para configuraciones
}

// Wrapper para operaciones comunes
class LocalStorage {
  /// Guarda un objeto en la caja especificada
  static Future<void> saveData<T>(String boxName, String key, T data) async {
    try {
      final box = await Hive.openBox<T>(boxName);
      await box.put(key, data);
      debugPrint('💾 Guardado en $boxName: $key');
    } catch (e) {
      debugPrint('❌ Error guardando en $boxName: $e');
      rethrow;
    }
  }
  
  /// Obtiene un objeto específico
  static Future<T?> getData<T>(String boxName, String key) async {
    try {
      final box = await Hive.openBox<T>(boxName);
      final data = box.get(key);
      debugPrint('📖 Leído de $boxName: $key');
      return data;
    } catch (e) {
      debugPrint('❌ Error leyendo de $boxName: $e');
      return null;
    }
  }
  
  /// Obtiene todos los objetos de una caja
  static Future<List<T>> getAllData<T>(String boxName) async {
    try {
      final box = await Hive.openBox<T>(boxName);
      final data = box.values.toList();
      debugPrint('📚 Leídos ${data.length} elementos de $boxName');
      return data;
    } catch (e) {
      debugPrint('❌ Error leyendo todos de $boxName: $e');
      return [];
    }
  }
  
  /// Elimina un objeto específico
  static Future<void> deleteData(String boxName, String key) async {
    try {
      final box = await Hive.openBox(boxName);
      await box.delete(key);
      debugPrint('🗑️ Eliminado de $boxName: $key');
    } catch (e) {
      debugPrint('❌ Error eliminando de $boxName: $e');
      rethrow;
    }
  }
  
  /// Limpia toda una caja
  static Future<void> clearBox(String boxName) async {
    try {
      final box = await Hive.openBox(boxName);
      await box.clear();
      debugPrint('🧹 Caja $boxName limpiada');
    } catch (e) {
      debugPrint('❌ Error limpiando $boxName: $e');
      rethrow;
    }
  }
}
```

#### Type Adapters Automáticos
```dart
// Con Freezed + Hive, los adaptadores se generan automáticamente
@freezed
@HiveType(typeId: 0) // ID único para el tipo
class ActivityModel with _$ActivityModel {
  const ActivityModel._();
  
  @HiveField(0) // Campo 0
  const factory ActivityModel({
    @HiveField(1) required String id,
    @HiveField(2) required String title,
    @HiveField(3) required String description,
    @HiveField(4) required DateTime startTime,
    @HiveField(5) required DateTime endTime,
    @HiveField(6) @Default(false) bool isCompleted,
  }) = _ActivityModel;
  
  factory ActivityModel.fromJson(Map<String, dynamic> json) =>
      _$ActivityModelFromJson(json);
}

// El comando build_runner genera automáticamente:
// - ActivityModelAdapter (para Hive)
// - Métodos de serialización
```

#### Consultas Avanzadas
```dart
class ActivityRepository {
  static const String _boxName = 'activities';
  
  /// Obtiene actividades por fecha
  Future<List<ActivityModel>> getActivitiesByDate(DateTime date) async {
    final allActivities = await LocalStorage.getAllData<ActivityModel>(_boxName);
    
    return allActivities.where((activity) {
      final activityDate = DateTime(
        activity.startTime.year,
        activity.startTime.month,
        activity.startTime.day,
      );
      final targetDate = DateTime(date.year, date.month, date.day);
      
      return activityDate.isAtSameMomentAs(targetDate);
    }).toList();
  }
  
  /// Obtiene actividades completadas
  Future<List<ActivityModel>> getCompletedActivities() async {
    final allActivities = await LocalStorage.getAllData<ActivityModel>(_boxName);
    return allActivities.where((activity) => activity.isCompleted).toList();
  }
  
  /// Obtiene actividades por categoría
  Future<List<ActivityModel>> getActivitiesByCategory(String category) async {
    final allActivities = await LocalStorage.getAllData<ActivityModel>(_boxName);
    return allActivities.where((activity) => activity.category == category).toList();
  }
  
  /// Busca actividades por texto
  Future<List<ActivityModel>> searchActivities(String query) async {
    final allActivities = await LocalStorage.getAllData<ActivityModel>(_boxName);
    final lowerQuery = query.toLowerCase();
    
    return allActivities.where((activity) {
      return activity.title.toLowerCase().contains(lowerQuery) ||
             activity.description.toLowerCase().contains(lowerQuery);
    }).toList();
  }
  
  /// Estadísticas de actividades
  Future<Map<String, dynamic>> getActivityStats() async {
    final allActivities = await LocalStorage.getAllData<ActivityModel>(_boxName);
    
    final completed = allActivities.where((a) => a.isCompleted).length;
    final pending = allActivities.length - completed;
    
    // Actividades por categoría
    final categoryStats = <String, int>{};
    for (final activity in allActivities) {
      categoryStats[activity.category] = 
          (categoryStats[activity.category] ?? 0) + 1;
    }
    
    return {
      'total': allActivities.length,
      'completed': completed,
      'pending': pending,
      'completionRate': allActivities.isEmpty ? 0.0 : completed / allActivities.length,
      'byCategory': categoryStats,
    };
  }
}
```

### 5. **Provider** - Gestión de Estado

#### ¿Qué es Provider?
Provider es la implementación recomendada por el equipo de Flutter para gestión de estado, basada en InheritedWidget pero más fácil de usar.

#### ¿Para qué sirve?
- **Estado compartido**: Compartir datos entre múltiples widgets
- **Reactividad**: Los widgets se reconstruyen cuando cambian los datos
- **Performance**: Solo reconstruye widgets que realmente necesitan actualizarse
- **Simplicidad**: API más simple que otros gestores de estado

#### Tipos de Providers
```dart
// 1. Provider básico (valores inmutables)
Provider<String>.value(
  value: 'Hello World',
  child: MyApp(),
)

// 2. ChangeNotifierProvider (valores mutables)
ChangeNotifierProvider(
  create: (context) => ActivityProvider(),
  child: MyApp(),
)

// 3. MultiProvider (múltiples providers)
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (context) => ActivityProvider()),
    ChangeNotifierProvider(create: (context) => HabitProvider()),
    ChangeNotifierProvider(create: (context) => ThemeProvider()),
  ],
  child: MyApp(),
)

// 4. FutureProvider (datos asincrónicos)
FutureProvider<List<ActivityModel>>(
  create: (context) => ActivityRepository().getAllActivities(),
  initialData: [],
  child: ActivityList(),
)

// 5. StreamProvider (streams de datos)
StreamProvider<List<ActivityModel>>(
  create: (context) => ActivityRepository().watchActivities(),
  initialData: [],
  child: ActivityList(),
)
```

#### Implementación de ChangeNotifierProvider
```dart
class ActivityProvider extends ChangeNotifier {
  final ActivityRepository _repository = ServiceLocator.instance.activityRepository;
  
  // Estado privado
  List<ActivityModel> _activities = [];
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';
  String _selectedCategory = 'Todas';
  
  // Getters públicos (inmutables)
  List<ActivityModel> get activities => List.unmodifiable(_activities);
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;
  
  // Getters computados (se calculan en tiempo real)
  List<ActivityModel> get filteredActivities {
    var filtered = _activities;
    
    // Filtrar por categoría
    if (_selectedCategory != 'Todas') {
      filtered = filtered.where((a) => a.category == _selectedCategory).toList();
    }
    
    // Filtrar por búsqueda
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((a) =>
          a.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          a.description.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }
    
    return filtered;
  }
  
  List<ActivityModel> get completedActivities =>
      _activities.where((a) => a.isCompleted).toList();
      
  List<ActivityModel> get pendingActivities =>
      _activities.where((a) => !a.isCompleted).toList();
  
  double get completionRate =>
      _activities.isEmpty ? 0.0 : completedActivities.length / _activities.length;
  
  // Actions (métodos que modifican el estado)
  Future<void> loadActivities() async {
    _setLoading(true);
    _clearError();
    
    try {
      final activities = await _repository.getAllActivities();
      _activities = activities;
      debugPrint('✅ ${activities.length} actividades cargadas');
    } catch (e) {
      _setError('Error cargando actividades: $e');
      debugPrint('❌ Error cargando actividades: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  Future<void> addActivity(ActivityModel activity) async {
    try {
      await _repository.addActivity(activity);
      _activities.add(activity);
      notifyListeners(); // ← Notifica a todos los listeners
      debugPrint('✅ Actividad agregada: ${activity.title}');
    } catch (e) {
      _setError('Error agregando actividad: $e');
      debugPrint('❌ Error agregando actividad: $e');
    }
  }
  
  Future<void> updateActivity(ActivityModel activity) async {
    try {
      await _repository.updateActivity(activity);
      
      // Actualizar en la lista local
      final index = _activities.indexWhere((a) => a.id == activity.id);
      if (index != -1) {
        _activities[index] = activity;
        notifyListeners();
      }
      
      debugPrint('✅ Actividad actualizada: ${activity.title}');
    } catch (e) {
      _setError('Error actualizando actividad: $e');
    }
  }
  
  Future<void> deleteActivity(String activityId) async {
    try {
      await _repository.deleteActivity(activityId);
      _activities.removeWhere((a) => a.id == activityId);
      notifyListeners();
      debugPrint('✅ Actividad eliminada: $activityId');
    } catch (e) {
      _setError('Error eliminando actividad: $e');
    }
  }
  
  Future<void> toggleActivityCompletion(String activityId) async {
    final index = _activities.indexWhere((a) => a.id == activityId);
    if (index == -1) return;
    
    final activity = _activities[index];
    final updatedActivity = activity.toggleCompletion();
    
    await updateActivity(updatedActivity);
  }
  
  // Filtros y búsqueda
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }
  
  void setSelectedCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }
  
  void clearFilters() {
    _searchQuery = '';
    _selectedCategory = 'Todas';
    notifyListeners();
  }
  
  // Métodos auxiliares
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  void _setError(String error) {
    _error = error;
    notifyListeners();
  }
  
  void _clearError() {
    _error = null;
    // No llamar notifyListeners() aquí para evitar rebuilds innecesarios
  }
  
  @override
  void dispose() {
    // Limpiar recursos si es necesario
    super.dispose();
  }
}
```

#### Consumir Provider en UI
```dart
// 1. Consumer - Reconstruye cuando cambia el provider
class ActivityList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ActivityProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return Center(child: CircularProgressIndicator());
        }
        
        if (provider.error != null) {
          return ErrorWidget(error: provider.error!);
        }
        
        final activities = provider.filteredActivities;
        
        return ListView.builder(
          itemCount: activities.length,
          itemBuilder: (context, index) {
            final activity = activities[index];
            return ActivityCard(
              activity: activity,
              onToggleCompletion: () => 
                  provider.toggleActivityCompletion(activity.id),
            );
          },
        );
      },
    );
  }
}

// 2. Selector - Solo reconstruye cuando cambia una propiedad específica
class ActivityCounter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Selector<ActivityProvider, int>(
      selector: (context, provider) => provider.activities.length,
      builder: (context, count, child) {
        return Text('Total: $count actividades');
      },
    );
  }
}

// 3. Provider.of - Para obtener el provider sin reconstruir
class ActivityButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        // No reconstruye este widget cuando cambia el provider
        final provider = Provider.of<ActivityProvider>(context, listen: false);
        provider.loadActivities();
      },
      child: Text('Cargar Actividades'),
    );
  }
}

// 4. context.read - Sintaxis más corta (Flutter 1.20+)
class ModernActivityButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => context.read<ActivityProvider>().loadActivities(),
      child: Text('Cargar Actividades'),
    );
  }
}

// 5. context.watch - Para leer y escuchar cambios
class ModernActivityList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ActivityProvider>();
    
    if (provider.isLoading) {
      return Center(child: CircularProgressIndicator());
    }
    
    return ListView.builder(
      itemCount: provider.filteredActivities.length,
      itemBuilder: (context, index) {
        final activity = provider.filteredActivities[index];
        return ActivityCard(activity: activity);
      },
    );
  }
}
```

---

## 🏗️ Patrones de Diseño

### 1. **Repository Pattern** - Abstracción de Acceso a Datos

#### ¿Qué es el Repository Pattern?
Es un patrón que encapsula la lógica de acceso a datos y centraliza las consultas, proporcionando una interfaz más orientada a objetos para acceder a la capa de datos.

#### ¿Para qué sirve?
- **Separación de responsabilidades**: Separa lógica de negocio de acceso a datos
- **Testabilidad**: Facilita crear mocks para testing
- **Flexibilidad**: Permite cambiar fuente de datos sin afectar lógica de negocio
- **Centralización**: Un lugar para toda la lógica de acceso a datos

#### Implementación Completa
```dart
// Interfaz del repository (contrato)
abstract class IActivityRepository {
  Future<List<ActivityModel>> getAllActivities();
  Future<ActivityModel?> getActivityById(String id);
  Future<void> addActivity(ActivityModel activity);
  Future<void> updateActivity(ActivityModel activity);
  Future<void> deleteActivity(String id);
  Future<List<ActivityModel>> getActivitiesByDate(DateTime date);
  Future<List<ActivityModel>> searchActivities(String query);
}

// Implementación concreta
class ActivityRepository implements IActivityRepository {
  static const String _boxName = 'activities';
  final TimeBlockRepository _timeBlockRepository;
  final Logger _logger = Logger.instance;
  
  // Cache en memoria para performance
  final List<ActivityModel> _cachedActivities = [];
  bool _isCacheValid = false;
  
  ActivityRepository({
    required TimeBlockRepository timeBlockRepository,
  }) : _timeBlockRepository = timeBlockRepository;
  
  @override
  Future<List<ActivityModel>> getAllActivities() async {
    try {
      // Usar cache si está válido
      if (_isCacheValid) {
        _logger.d('Usando cache para getAllActivities');
        return List.from(_cachedActivities);
      }
      
      // Cargar desde base de datos
      final activities = await LocalStorage.getAllData<ActivityModel>(_boxName);
      
      // Actualizar cache
      _cachedActivities.clear();
      _cachedActivities.addAll(activities);
      _isCacheValid = true;
      
      _logger.i('Cargadas ${activities.length} actividades desde BD');
      return activities;
    } catch (e) {
      _logger.e('Error obteniendo actividades', error: e);
      throw ActivityRepositoryException('Error al obtener actividades: $e');
    }
  }
  
  @override
  Future<ActivityModel?> getActivityById(String id) async {
    try {
      // Buscar primero en cache
      if (_isCacheValid) {
        final cached = _cachedActivities.where((a) => a.id == id).firstOrNull;
        if (cached != null) {
          _logger.d('Actividad encontrada en cache: $id');
          return cached;
        }
      }
      
      // Buscar en base de datos
      final activity = await LocalStorage.getData<ActivityModel>(_boxName, id);
      _logger.d('Actividad obtenida de BD: $id');
      return activity;
    } catch (e) {
      _logger.e('Error obteniendo actividad $id', error: e);
      return null;
    }
  }
  
  @override
  Future<void> addActivity(ActivityModel activity) async {
    try {
      _logger.i('Agregando actividad: ${activity.title}');
      
      // 1. Validar actividad
      _validateActivity(activity);
      
      // 2. Verificar duplicados
      await _checkForDuplicates(activity);
      
      // 3. Guardar en base de datos
      await LocalStorage.saveData<ActivityModel>(_boxName, activity.id, activity);
      
      // 4. Actualizar cache
      _cachedActivities.add(activity);
      
      // 5. Sincronizar con otros dominios
      await _syncWithTimeBlocks(activity);
      
      // 6. Programar notificaciones
      if (activity.sendReminder) {
        await _scheduleNotification(activity);
      }
      
      _logger.i('Actividad agregada exitosamente: ${activity.id}');
    } catch (e) {
      _logger.e('Error agregando actividad', error: e);
      rethrow;
    }
  }
  
  @override
  Future<void> updateActivity(ActivityModel activity) async {
    try {
      _logger.i('Actualizando actividad: ${activity.title}');
      
      // 1. Verificar que existe
      final existing = await getActivityById(activity.id);
      if (existing == null) {
        throw ActivityRepositoryException('Actividad no encontrada: ${activity.id}');
      }
      
      // 2. Guardar cambios
      await LocalStorage.saveData<ActivityModel>(_boxName, activity.id, activity);
      
      // 3. Actualizar cache
      final index = _cachedActivities.indexWhere((a) => a.id == activity.id);
      if (index != -1) {
        _cachedActivities[index] = activity;
      }
      
      // 4. Sincronizar cambios
      await _syncWithTimeBlocks(activity);
      
      // 5. Actualizar notificaciones
      await _updateNotifications(existing, activity);
      
      _logger.i('Actividad actualizada: ${activity.id}');
    } catch (e) {
      _logger.e('Error actualizando actividad', error: e);
      rethrow;
    }
  }
  
  @override
  Future<void> deleteActivity(String id) async {
    try {
      _logger.i('Eliminando actividad: $id');
      
      // 1. Obtener actividad antes de eliminar
      final activity = await getActivityById(id);
      if (activity == null) {
        _logger.w('Actividad no encontrada para eliminar: $id');
        return;
      }
      
      // 2. Eliminar de base de datos
      await LocalStorage.deleteData(_boxName, id);
      
      // 3. Eliminar del cache
      _cachedActivities.removeWhere((a) => a.id == id);
      
      // 4. Limpiar timeblocks relacionados
      await _cleanupTimeBlocks(activity);
      
      // 5. Cancelar notificaciones
      await _cancelNotifications(activity);
      
      _logger.i('Actividad eliminada: $id');
    } catch (e) {
      _logger.e('Error eliminando actividad', error: e);
      rethrow;
    }
  }
  
  @override
  Future<List<ActivityModel>> getActivitiesByDate(DateTime date) async {
    try {
      final allActivities = await getAllActivities();
      
      final targetDate = DateTime(date.year, date.month, date.day);
      
      final filtered = allActivities.where((activity) {
        final activityDate = DateTime(
          activity.startTime.year,
          activity.startTime.month,
          activity.startTime.day,
        );
        return activityDate.isAtSameMomentAs(targetDate);
      }).toList();
      
      // Ordenar por hora de inicio
      filtered.sort((a, b) => a.startTime.compareTo(b.startTime));
      
      _logger.d('Encontradas ${filtered.length} actividades para ${date.toString()}');
      return filtered;
    } catch (e) {
      _logger.e('Error obteniendo actividades por fecha', error: e);
      throw ActivityRepositoryException('Error al filtrar por fecha: $e');
    }
  }
  
  @override
  Future<List<ActivityModel>> searchActivities(String query) async {
    try {
      if (query.trim().isEmpty) return [];
      
      final allActivities = await getAllActivities();
      final lowerQuery = query.toLowerCase();
      
      final filtered = allActivities.where((activity) {
        return activity.title.toLowerCase().contains(lowerQuery) ||
               activity.description.toLowerCase().contains(lowerQuery) ||
               activity.category.toLowerCase().contains(lowerQuery);
      }).toList();
      
      _logger.d('Búsqueda "$query": ${filtered.length} resultados');
      return filtered;
    } catch (e) {
      _logger.e('Error en búsqueda', error: e);
      throw ActivityRepositoryException('Error en búsqueda: $e');
    }
  }
  
  // === MÉTODOS AUXILIARES ===
  
  void _validateActivity(ActivityModel activity) {
    if (activity.title.trim().isEmpty) {
      throw ActivityRepositoryException('El título de la actividad es requerido');
    }
    
    if (activity.startTime.isAfter(activity.endTime)) {
      throw ActivityRepositoryException('La hora de inicio debe ser anterior a la de fin');
    }
    
    final now = DateTime.now();
    if (activity.endTime.isBefore(now.subtract(Duration(days: 30)))) {
      throw ActivityRepositoryException('No se pueden crear actividades muy antiguas');
    }
  }
  
  Future<void> _checkForDuplicates(ActivityModel activity) async {
    final existingActivities = await getActivitiesByDate(activity.startTime);
    
    final duplicates = existingActivities.where((existing) =>
        existing.title == activity.title &&
        existing.startTime.isAtSameMomentAs(activity.startTime)
    ).toList();
    
    if (duplicates.isNotEmpty) {
      throw ActivityRepositoryException('Ya existe una actividad con ese título y horario');
    }
  }
  
  Future<void> _syncWithTimeBlocks(ActivityModel activity) async {
    try {
      // Buscar timeblock existente generado por esta actividad
      final timeBlocks = await _timeBlockRepository.getTimeBlocksByDate(activity.startTime);
      
      final existingBlock = timeBlocks.where((block) =>
          block.description.contains('[ACTIVITY_GENERATED]') &&
          block.description.contains('ID: ${activity.id}')
      ).firstOrNull;
      
      if (existingBlock != null) {
        // Actualizar timeblock existente
        final updatedBlock = existingBlock.copyWith(
          title: activity.title,
          startTime: activity.startTime,
          endTime: activity.endTime,
          category: activity.category,
          isCompleted: activity.isCompleted,
        );
        await _timeBlockRepository.updateTimeBlock(updatedBlock);
        _logger.d('TimeBlock actualizado para actividad: ${activity.id}');
      } else {
        // Crear nuevo timeblock
        final newBlock = TimeBlockModel(
          id: uuid.v4(),
          title: activity.title,
          description: '[ACTIVITY_GENERATED] ID: ${activity.id}\n${activity.description}',
          startTime: activity.startTime,
          endTime: activity.endTime,
          category: activity.category,
          isCompleted: activity.isCompleted,
        );
        await _timeBlockRepository.addTimeBlock(newBlock);
        _logger.d('TimeBlock creado para actividad: ${activity.id}');
      }
    } catch (e) {
      _logger.w('Error sincronizando con timeblocks', error: e);
      // No relanzar para no bloquear operación principal
    }
  }
  
  Future<void> _cleanupTimeBlocks(ActivityModel activity) async {
    try {
      final timeBlocks = await _timeBlockRepository.getTimeBlocksByDate(activity.startTime);
      
      final relatedBlocks = timeBlocks.where((block) =>
          block.description.contains('[ACTIVITY_GENERATED]') &&
          block.description.contains('ID: ${activity.id}')
      ).toList();
      
      for (final block in relatedBlocks) {
        await _timeBlockRepository.deleteTimeBlock(block.id);
        _logger.d('TimeBlock eliminado: ${block.id}');
      }
    } catch (e) {
      _logger.w('Error limpiando timeblocks', error: e);
    }
  }
  
  Future<void> _scheduleNotification(ActivityModel activity) async {
    try {
      await ServiceLocator.instance.notificationService
          .scheduleActivityNotification(activity);
      _logger.d('Notificación programada para: ${activity.id}');
    } catch (e) {
      _logger.w('Error programando notificación', error: e);
    }
  }
  
  Future<void> _updateNotifications(ActivityModel oldActivity, ActivityModel newActivity) async {
    try {
      // Cancelar notificación anterior
      await ServiceLocator.instance.notificationService
          .cancelActivityNotification(oldActivity.id);
      
      // Programar nueva si es necesario
      if (newActivity.sendReminder) {
        await _scheduleNotification(newActivity);
      }
    } catch (e) {
      _logger.w('Error actualizando notificaciones', error: e);
    }
  }
  
  Future<void> _cancelNotifications(ActivityModel activity) async {
    try {
      await ServiceLocator.instance.notificationService
          .cancelActivityNotification(activity.id);
      _logger.d('Notificación cancelada para: ${activity.id}');
    } catch (e) {
      _logger.w('Error cancelando notificación', error: e);
    }
  }
  
  /// Invalida el cache para forzar recarga desde BD
  void invalidateCache() {
    _isCacheValid = false;
    _cachedActivities.clear();
    _logger.d('Cache invalidado');
  }
  
  /// Obtiene estadísticas de las actividades
  Future<Map<String, dynamic>> getActivityStats() async {
    try {
      final activities = await getAllActivities();
      
      final completed = activities.where((a) => a.isCompleted).length;
      final pending = activities.length - completed;
      
      // Estadísticas por categoría
      final categoryStats = <String, int>{};
      for (final activity in activities) {
        categoryStats[activity.category] = (categoryStats[activity.category] ?? 0) + 1;
      }
      
      // Actividades por día de la semana
      final weekdayStats = List.filled(7, 0);
      for (final activity in activities) {
        weekdayStats[activity.startTime.weekday - 1]++;
      }
      
      return {
        'total': activities.length,
        'completed': completed,
        'pending': pending,
        'completionRate': activities.isEmpty ? 0.0 : completed / activities.length,
        'byCategory': categoryStats,
        'byWeekday': weekdayStats,
      };
    } catch (e) {
      _logger.e('Error obteniendo estadísticas', error: e);
      return {};
    }
  }
}

// Excepción personalizada
class ActivityRepositoryException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;
  
  ActivityRepositoryException(
    this.message, {
    this.code,
    this.originalError,
  });
  
  @override
  String toString() => 'ActivityRepositoryException: $message';
}
```

### 2. **Clean Architecture** - Arquitectura por Capas

#### ¿Qué es Clean Architecture?
Es una arquitectura que separa las responsabilidades en capas concéntricas, donde las capas internas no conocen las externas, garantizando bajo acoplamiento y alta cohesión.

#### Capas en TempoSage
```
🎨 Presentation Layer (UI)
   ├── Screens (Pantallas completas)
   ├── Widgets (Componentes de UI)
   └── Controllers (Gestión de estado de UI)
          ↓
🎯 Domain Layer (Lógica de Negocio)
   ├── Entities (Objetos de negocio)
   ├── Use Cases (Casos de uso específicos)
   └── Services (Lógica de dominio compleja)
          ↓
💾 Data Layer (Acceso a Datos)
   ├── Models (Representación de datos)
   ├── Repositories (Acceso a datos)
   └── Data Sources (Fuentes de datos: local, remote)
```

#### Implementación por Capas

##### Data Layer
```dart
// 📄 models/activity_model.dart
@freezed
class ActivityModel with _$ActivityModel {
  const factory ActivityModel({
    required String id,
    required String title,
    required String description,
    required DateTime startTime,
    required DateTime endTime,
  }) = _ActivityModel;
  
  factory ActivityModel.fromJson(Map<String, dynamic> json) =>
      _$ActivityModelFromJson(json);
}

// 📄 repositories/activity_repository.dart
class ActivityRepository {
  // Implementación ya mostrada anteriormente
}
```

##### Domain Layer
```dart
// 📄 entities/activity.dart (Entidad pura de negocio)
class Activity {
  final String id;
  final String title;
  final String description;
  final DateTime startTime;
  final DateTime endTime;
  final bool isCompleted;
  
  Activity({
    required this.id,
    required this.title,
    required this.description,
    required this.startTime,
    required this.endTime,
    this.isCompleted = false,
  });
  
  // Lógica de negocio pura (sin dependencias externas)
  bool get isOverdue => DateTime.now().isAfter(endTime) && !isCompleted;
  
  Duration get duration => endTime.difference(startTime);
  
  bool get isActive {
    final now = DateTime.now();
    return now.isAfter(startTime) && now.isBefore(endTime);
  }
  
  Activity complete() => Activity(
    id: id,
    title: title,
    description: description,
    startTime: startTime,
    endTime: endTime,
    isCompleted: true,
  );
  
  // Validaciones de negocio
  bool isValidTimeRange() => startTime.isBefore(endTime);
  
  bool conflictsWith(Activity other) {
    return (startTime.isBefore(other.endTime) && endTime.isAfter(other.startTime));
  }
}

// 📄 usecases/create_activity_usecase.dart
class CreateActivityUseCase {
  final ActivityRepository _repository;
  final NotificationService _notificationService;
  
  CreateActivityUseCase(this._repository, this._notificationService);
  
  Future<Result<Activity, String>> execute(CreateActivityParams params) async {
    try {
      // 1. Crear entidad de dominio
      final activity = Activity(
        id: params.id,
        title: params.title,
        description: params.description,
        startTime: params.startTime,
        endTime: params.endTime,
      );
      
      // 2. Validaciones de negocio
      if (!activity.isValidTimeRange()) {
        return Result.failure('La hora de inicio debe ser anterior a la de fin');
      }
      
      // 3. Verificar conflictos
      final existingActivities = await _repository.getActivitiesByDate(activity.startTime);
      final conflicts = existingActivities
          .map((model) => _mapToEntity(model))
          .where((existing) => activity.conflictsWith(existing))
          .toList();
      
      if (conflicts.isNotEmpty) {
        return Result.failure('La actividad tiene conflictos de horario');
      }
      
      // 4. Convertir a modelo y guardar
      final activityModel = _mapToModel(activity);
      await _repository.addActivity(activityModel);
      
      // 5. Programar notificación si es necesario
      if (params.sendReminder) {
        await _notificationService.scheduleActivityNotification(activityModel);
      }
      
      return Result.success(activity);
    } catch (e) {
      return Result.failure('Error creando actividad: $e');
    }
  }
  
  Activity _mapToEntity(ActivityModel model) {
    return Activity(
      id: model.id,
      title: model.title,
      description: model.description,
      startTime: model.startTime,
      endTime: model.endTime,
      isCompleted: model.isCompleted,
    );
  }
  
  ActivityModel _mapToModel(Activity entity) {
    return ActivityModel(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      startTime: entity.startTime,
      endTime: entity.endTime,
      isCompleted: entity.isCompleted,
    );
  }
}

// 📄 Parámetros del caso de uso
class CreateActivityParams {
  final String id;
  final String title;
  final String description;
  final DateTime startTime;
  final DateTime endTime;
  final bool sendReminder;
  
  CreateActivityParams({
    required this.id,
    required this.title,
    required this.description,
    required this.startTime,
    required this.endTime,
    this.sendReminder = true,
  });
}

// 📄 Result pattern para manejo de errores
abstract class Result<T, E> {
  factory Result.success(T value) = Success<T, E>;
  factory Result.failure(E error) = Failure<T, E>;
  
  bool get isSuccess;
  bool get isFailure;
  T get value;
  E get error;
}

class Success<T, E> implements Result<T, E> {
  final T _value;
  
  Success(this._value);
  
  @override
  bool get isSuccess => true;
  
  @override
  bool get isFailure => false;
  
  @override
  T get value => _value;
  
  @override
  E get error => throw Exception('Success has no error');
}

class Failure<T, E> implements Result<T, E> {
  final E _error;
  
  Failure(this._error);
  
  @override
  bool get isSuccess => false;
  
  @override
  bool get isFailure => true;
  
  @override
  T get value => throw Exception('Failure has no value');
  
  @override
  E get error => _error;
}
```

##### Presentation Layer
```dart
// 📄 controllers/activity_controller.dart
class ActivityController extends ChangeNotifier {
  final CreateActivityUseCase _createActivityUseCase;
  final GetActivitiesUseCase _getActivitiesUseCase;
  
  List<Activity> _activities = [];
  bool _isLoading = false;
  String? _error;
  
  ActivityController(this._createActivityUseCase, this._getActivitiesUseCase);
  
  List<Activity> get activities => List.unmodifiable(_activities);
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  Future<void> loadActivities() async {
    _setLoading(true);
    
    final result = await _getActivitiesUseCase.execute();
    
    result.fold(
      success: (activities) {
        _activities = activities;
        _error = null;
      },
      failure: (error) {
        _error = error;
      },
    );
    
    _setLoading(false);
  }
  
  Future<bool> createActivity({
    required String title,
    required String description,
    required DateTime startTime,
    required DateTime endTime,
    bool sendReminder = true,
  }) async {
    _setLoading(true);
    
    final params = CreateActivityParams(
      id: uuid.v4(),
      title: title,
      description: description,
      startTime: startTime,
      endTime: endTime,
      sendReminder: sendReminder,
    );
    
    final result = await _createActivityUseCase.execute(params);
    
    if (result.isSuccess) {
      _activities.add(result.value);
      _error = null;
      notifyListeners();
      _setLoading(false);
      return true;
    } else {
      _error = result.error;
      _setLoading(false);
      return false;
    }
  }
  
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}

// 📄 screens/create_activity_screen.dart
class CreateActivityScreen extends StatefulWidget {
  @override
  _CreateActivityScreenState createState() => _CreateActivityScreenState();
}

class _CreateActivityScreenState extends State<CreateActivityScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  DateTime? _startTime;
  DateTime? _endTime;
  bool _sendReminder = true;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Crear Actividad')),
      body: Consumer<ActivityController>(
        builder: (context, controller, child) {
          return Form(
            key: _formKey,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  TextFormField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      labelText: 'Título *',
                      errorText: controller.error,
                    ),
                    validator: (value) => value?.isEmpty == true 
                        ? 'El título es requerido' 
                        : null,
                  ),
                  // Más campos del formulario...
                  
                  if (controller.isLoading)
                    CircularProgressIndicator()
                  else
                    ElevatedButton(
                      onPressed: _submitForm,
                      child: Text('Crear Actividad'),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
  
  void _submitForm() async {
    if (_formKey.currentState!.validate() && _startTime != null && _endTime != null) {
      final controller = Provider.of<ActivityController>(context, listen: false);
      
      final success = await controller.createActivity(
        title: _titleController.text,
        description: _descriptionController.text,
        startTime: _startTime!,
        endTime: _endTime!,
        sendReminder: _sendReminder,
      );
      
      if (success) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Actividad creada exitosamente')),
        );
      }
      // El error se muestra automáticamente en el formulario
    }
  }
}
```

#### Beneficios de Clean Architecture
- ✅ **Testabilidad**: Cada capa se puede testear independientemente
- ✅ **Mantenibilidad**: Cambios en una capa no afectan otras
- ✅ **Escalabilidad**: Fácil agregar nuevas funcionalidades
- ✅ **Reutilización**: Los casos de uso se pueden reutilizar
- ✅ **Claridad**: Responsabilidades bien definidas

---

## 🔧 Conceptos Avanzados

### 1. **GetIt** - Inyección de Dependencias

#### ¿Qué es GetIt?
GetIt es un service locator simple y rápido para Dart y Flutter que permite el registro y resolución de dependencias de forma type-safe.

#### ¿Para qué sirve?
- **Registro de servicios**: Registra instancias singleton o factory
- **Resolución type-safe**: Obtiene dependencias con seguridad de tipos
- **Lazy initialization**: Crea instancias solo cuando se necesitan
- **Lifecycle management**: Maneja el ciclo de vida de los objetos

#### Configuración Básica
```dart
// 📄 di/service_locator.dart
final GetIt getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  // === SERVICIOS CORE ===
  
  // Singleton - Una sola instancia para toda la app
  getIt.registerSingleton<Logger>(Logger());
  
  // Lazy singleton - Se crea cuando se usa por primera vez
  getIt.registerLazySingleton<NotificationService>(() => NotificationService());
  
  // Factory - Nueva instancia cada vez que se solicita
  getIt.registerFactory<NetworkService>(() => NetworkService());
  
  // === REPOSITORIOS ===
  
  // Registrar repositorios con dependencias
  getIt.registerLazySingleton<TimeBlockRepository>(() => TimeBlockRepository());
  
  getIt.registerLazySingleton<ActivityRepository>(() => ActivityRepository(
    timeBlockRepository: getIt<TimeBlockRepository>(), // Inyección automática
  ));
  
  getIt.registerLazySingleton<HabitRepository>(() => HabitRepository());
  
  // === CASOS DE USO ===
  
  getIt.registerFactory<CreateActivityUseCase>(() => CreateActivityUseCase(
    getIt<ActivityRepository>(),
    getIt<NotificationService>(),
  ));
  
  getIt.registerFactory<GetActivitiesUseCase>(() => GetActivitiesUseCase(
    getIt<ActivityRepository>(),
  ));
  
  // === CONTROLADORES ===
  
  getIt.registerFactory<ActivityController>(() => ActivityController(
    getIt<CreateActivityUseCase>(),
    getIt<GetActivitiesUseCase>(),
  ));
  
  debugPrint('🔧 ServiceLocator configurado con GetIt');
}

// Usar en main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await setupServiceLocator();
  
  runApp(MyApp());
}
```

#### Uso en la Aplicación
```dart
// Obtener dependencias en cualquier lugar
class SomeService {
  void doSomething() {
    // Type-safe: obtiene ActivityRepository
    final activityRepo = getIt<ActivityRepository>();
    
    // También se puede hacer así
    final logger = getIt.get<Logger>();
  }
}

// En widgets
class ActivityScreen extends StatefulWidget {
  @override
  _ActivityScreenState createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  late final ActivityController _controller;
  
  @override
  void initState() {
    super.initState();
    _controller = getIt<ActivityController>();
  }
  
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _controller,
      child: Consumer<ActivityController>(
        builder: (context, controller, child) {
          return ListView.builder(
            itemCount: controller.activities.length,
            itemBuilder: (context, index) {
              return ActivityCard(activity: controller.activities[index]);
            },
          );
        },
      ),
    );
  }
}
```

#### Configuración Avanzada
```dart
// Registro condicional
Future<void> setupServiceLocator() async {
  // Diferentes implementaciones según el entorno
  if (kDebugMode) {
    getIt.registerLazySingleton<ApiService>(() => MockApiService());
  } else {
    getIt.registerLazySingleton<ApiService>(() => HttpApiService());
  }
  
  // Registro con configuración async
  final database = await initializeDatabase();
  getIt.registerSingleton<Database>(database);
  
  // Registro con disposición automática
  getIt.registerSingleton<SomeService>(
    SomeService(),
    dispose: (service) => service.dispose(),
  );
}

// Scopes para diferentes contextos
void setupUserScope() {
  getIt.pushNewScope();
  
  // Servicios específicos del usuario logueado
  getIt.registerSingleton<UserSession>(UserSession.current);
  getIt.registerLazySingleton<UserPreferences>(() => UserPreferences());
}

void clearUserScope() {
  getIt.popScope(); // Limpia todas las dependencias del scope
}
```

#### Testing con GetIt
```dart
// test/setup.dart
void setupTestServiceLocator() {
  // Limpiar registros existentes
  getIt.reset();
  
  // Registrar mocks para testing
  getIt.registerSingleton<ActivityRepository>(MockActivityRepository());
  getIt.registerSingleton<NotificationService>(MockNotificationService());
  
  // Casos de uso con mocks
  getIt.registerFactory<CreateActivityUseCase>(() => CreateActivityUseCase(
    getIt<ActivityRepository>(),
    getIt<NotificationService>(),
  ));
}

// En los tests
void main() {
  group('ActivityController Tests', () {
    setUp(() {
      setupTestServiceLocator();
    });
    
    tearDown(() {
      getIt.reset();
    });
    
    test('should create activity successfully', () async {
      // Arrange
      final controller = getIt<ActivityController>();
      
      // Act
      final result = await controller.createActivity(
        title: 'Test Activity',
        description: 'Test Description',
        startTime: DateTime.now(),
        endTime: DateTime.now().add(Duration(hours: 1)),
      );
      
      // Assert
      expect(result, true);
      expect(controller.activities.length, 1);
    });
  });
}
```

### 2. **Stream Pattern** - Datos Reactivos

#### ¿Qué son los Streams?
Los Streams son secuencias de datos asincrónicos que permiten reaccionar a cambios en tiempo real.

#### ¿Para qué sirven?
- **Datos en tiempo real**: Actualizaciones automáticas cuando cambian los datos
- **Programación reactiva**: UI que reacciona automáticamente a cambios
- **Desacoplamiento**: Los productores y consumidores no se conocen directamente
- **Performance**: Solo se actualizan los widgets que necesitan cambios

#### Implementación con StreamController
```dart
// 📄 repositories/reactive_activity_repository.dart
class ReactiveActivityRepository {
  static const String _boxName = 'activities';
  
  // StreamController para emitir cambios
  final _activitiesController = StreamController<List<ActivityModel>>.broadcast();
  
  // Stream público para que otros escuchen
  Stream<List<ActivityModel>> get activitiesStream => _activitiesController.stream;
  
  // Cache local
  List<ActivityModel> _activities = [];
  
  /// Inicializa el repositorio y carga datos
  Future<void> initialize() async {
    try {
      _activities = await LocalStorage.getAllData<ActivityModel>(_boxName);
      _emitActivities();
      debugPrint('✅ ReactiveActivityRepository inicializado con ${_activities.length} actividades');
    } catch (e) {
      debugPrint('❌ Error inicializando ReactiveActivityRepository: $e');
      _activitiesController.addError(e);
    }
  }
  
  /// Agrega una actividad y notifica a los listeners
  Future<void> addActivity(ActivityModel activity) async {
    try {
      // Guardar en BD
      await LocalStorage.saveData<ActivityModel>(_boxName, activity.id, activity);
      
      // Actualizar cache
      _activities.add(activity);
      
      // Emitir cambio a todos los listeners
      _emitActivities();
      
      debugPrint('✅ Actividad agregada y stream actualizado: ${activity.title}');
    } catch (e) {
      debugPrint('❌ Error agregando actividad: $e');
      _activitiesController.addError(e);
      rethrow;
    }
  }
  
  /// Actualiza una actividad existente
  Future<void> updateActivity(ActivityModel activity) async {
    try {
      await LocalStorage.saveData<ActivityModel>(_boxName, activity.id, activity);
      
      // Actualizar en cache
      final index = _activities.indexWhere((a) => a.id == activity.id);
      if (index != -1) {
        _activities[index] = activity;
        _emitActivities();
      }
      
      debugPrint('✅ Actividad actualizada: ${activity.title}');
    } catch (e) {
      debugPrint('❌ Error actualizando actividad: $e');
      _activitiesController.addError(e);
      rethrow;
    }
  }
  
  /// Elimina una actividad
  Future<void> deleteActivity(String id) async {
    try {
      await LocalStorage.deleteData(_boxName, id);
      
      _activities.removeWhere((a) => a.id == id);
      _emitActivities();
      
      debugPrint('✅ Actividad eliminada: $id');
    } catch (e) {
      debugPrint('❌ Error eliminando actividad: $e');
      _activitiesController.addError(e);
      rethrow;
    }
  }
  
  /// Stream filtrado por fecha
  Stream<List<ActivityModel>> getActivitiesByDateStream(DateTime date) {
    return activitiesStream.map((activities) {
      final targetDate = DateTime(date.year, date.month, date.day);
      
      return activities.where((activity) {
        final activityDate = DateTime(
          activity.startTime.year,
          activity.startTime.month,
          activity.startTime.day,
        );
        return activityDate.isAtSameMomentAs(targetDate);
      }).toList();
    });
  }
  
  /// Stream de actividades completadas
  Stream<List<ActivityModel>> get completedActivitiesStream {
    return activitiesStream.map((activities) =>
        activities.where((a) => a.isCompleted).toList());
  }
  
  /// Stream de estadísticas en tiempo real
  Stream<Map<String, dynamic>> get statsStream {
    return activitiesStream.map((activities) {
      final completed = activities.where((a) => a.isCompleted).length;
      final pending = activities.length - completed;
      
      return {
        'total': activities.length,
        'completed': completed,
        'pending': pending,
        'completionRate': activities.isEmpty ? 0.0 : completed / activities.length,
      };
    });
  }
  
  void _emitActivities() {
    _activitiesController.add(List.from(_activities));
  }
  
  void dispose() {
    _activitiesController.close();
  }
}
```

#### Consumir Streams en UI
```dart
// 📄 widgets/reactive_activity_list.dart
class ReactiveActivityList extends StatelessWidget {
  final DateTime date;
  
  const ReactiveActivityList({required this.date});
  
  @override
  Widget build(BuildContext context) {
    final repository = getIt<ReactiveActivityRepository>();
    
    return StreamBuilder<List<ActivityModel>>(
      stream: repository.getActivitiesByDateStream(date),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error, color: Colors.red, size: 48),
                SizedBox(height: 16),
                Text('Error: ${snapshot.error}'),
                ElevatedButton(
                  onPressed: () => repository.initialize(),
                  child: Text('Reintentar'),
                ),
              ],
            ),
          );
        }
        
        final activities = snapshot.data ?? [];
        
        if (activities.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.event_note, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('No hay actividades para esta fecha'),
              ],
            ),
          );
        }
        
        return ListView.builder(
          itemCount: activities.length,
          itemBuilder: (context, index) {
            return ActivityCard(
              activity: activities[index],
              onToggleCompletion: () => _toggleCompletion(activities[index]),
              onEdit: () => _editActivity(activities[index]),
              onDelete: () => _deleteActivity(activities[index]),
            );
          },
        );
      },
    );
  }
  
  void _toggleCompletion(ActivityModel activity) {
    final repository = getIt<ReactiveActivityRepository>();
    final updated = activity.toggleCompletion();
    repository.updateActivity(updated);
  }
  
  void _editActivity(ActivityModel activity) {
    // Navegar a pantalla de edición
  }
  
  void _deleteActivity(ActivityModel activity) {
    final repository = getIt<ReactiveActivityRepository>();
    repository.deleteActivity(activity.id);
  }
}

// 📄 widgets/activity_stats_widget.dart
class ActivityStatsWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final repository = getIt<ReactiveActivityRepository>();
    
    return StreamBuilder<Map<String, dynamic>>(
      stream: repository.statsStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return SizedBox(
            height: 100,
            child: Center(child: CircularProgressIndicator()),
          );
        }
        
        final stats = snapshot.data!;
        
        return Card(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _StatItem(
                  icon: Icons.list,
                  label: 'Total',
                  value: '${stats['total']}',
                ),
                _StatItem(
                  icon: Icons.check_circle,
                  label: 'Completadas',
                  value: '${stats['completed']}',
                  color: Colors.green,
                ),
                _StatItem(
                  icon: Icons.pending,
                  label: 'Pendientes',
                  value: '${stats['pending']}',
                  color: Colors.orange,
                ),
                _StatItem(
                  icon: Icons.trending_up,
                  label: 'Progreso',
                  value: '${(stats['completionRate'] * 100).toStringAsFixed(1)}%',
                  color: Colors.blue,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? color;
  
  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    this.color,
  });
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color ?? Theme.of(context).primaryColor),
        SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
```

#### BLoC Pattern con Streams
```dart
// 📄 blocs/activity_bloc.dart
// Estados
abstract class ActivityState {}

class ActivityLoading extends ActivityState {}

class ActivityLoaded extends ActivityState {
  final List<ActivityModel> activities;
  
  ActivityLoaded(this.activities);
}

class ActivityError extends ActivityState {
  final String message;
  
  ActivityError(this.message);
}

// Eventos
abstract class ActivityEvent {}

class LoadActivities extends ActivityEvent {}

class AddActivity extends ActivityEvent {
  final ActivityModel activity;
  
  AddActivity(this.activity);
}

class UpdateActivity extends ActivityEvent {
  final ActivityModel activity;
  
  UpdateActivity(this.activity);
}

class DeleteActivity extends ActivityEvent {
  final String id;
  
  DeleteActivity(this.id);
}

// BLoC
class ActivityBloc {
  final ActivityRepository _repository;
  
  final _stateController = StreamController<ActivityState>.broadcast();
  final _eventController = StreamController<ActivityEvent>();
  
  Stream<ActivityState> get state => _stateController.stream;
  Sink<ActivityEvent> get eventSink => _eventController.sink;
  
  ActivityBloc(this._repository) {
    _eventController.stream.listen(_handleEvent);
  }
  
  void _handleEvent(ActivityEvent event) async {
    if (event is LoadActivities) {
      _stateController.add(ActivityLoading());
      
      try {
        final activities = await _repository.getAllActivities();
        _stateController.add(ActivityLoaded(activities));
      } catch (e) {
        _stateController.add(ActivityError(e.toString()));
      }
    } else if (event is AddActivity) {
      try {
        await _repository.addActivity(event.activity);
        eventSink.add(LoadActivities()); // Recargar lista
      } catch (e) {
        _stateController.add(ActivityError(e.toString()));
      }
    }
    // Más eventos...
  }
  
  void dispose() {
    _stateController.close();
    _eventController.close();
  }
}

// Uso en widget
class BlocActivityList extends StatefulWidget {
  @override
  _BlocActivityListState createState() => _BlocActivityListState();
}

class _BlocActivityListState extends State<BlocActivityList> {
  late ActivityBloc _bloc;
  
  @override
  void initState() {
    super.initState();
    _bloc = ActivityBloc(getIt<ActivityRepository>());
    _bloc.eventSink.add(LoadActivities());
  }
  
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ActivityState>(
      stream: _bloc.state,
      builder: (context, snapshot) {
        final state = snapshot.data;
        
        if (state is ActivityLoading) {
          return Center(child: CircularProgressIndicator());
        } else if (state is ActivityLoaded) {
          return ListView.builder(
            itemCount: state.activities.length,
            itemBuilder: (context, index) {
              return ActivityCard(activity: state.activities[index]);
            },
          );
        } else if (state is ActivityError) {
          return Center(child: Text('Error: ${state.message}'));
        }
        
        return Container();
      },
    );
  }
  
  @override
  void dispose() {
    _bloc.dispose();
    super.dispose();
  }
}
```

---

## 🛠️ Herramientas de Desarrollo

### 1. **build_runner** - Generación de Código

#### ¿Qué es build_runner?
Es una herramienta que ejecuta generadores de código durante el desarrollo, creando automáticamente archivos basados en anotaciones.

#### ¿Para qué sirve?
- **Generación automática**: Crea código repetitivo automáticamente
- **Serialización JSON**: Genera métodos `fromJson` y `toJson`
- **Immutable classes**: Genera métodos para clases inmutables
- **Type adapters**: Crea adaptadores para Hive automáticamente

#### Configuración en pubspec.yaml
```yaml
dev_dependencies:
  build_runner: ^2.4.7
  freezed: ^2.4.6
  json_annotation: ^4.8.1
  json_serializable: ^6.7.1
  hive_generator: ^2.0.1
```

#### Comandos Principales
```bash
# Generar código una vez
flutter packages pub run build_runner build

# Generar y sobrescribir conflictos
flutter packages pub run build_runner build --delete-conflicting-outputs

# Modo watch (regenera automáticamente cuando cambias archivos)
flutter packages pub run build_runner watch

# Limpiar archivos generados
flutter packages pub run build_runner clean
```

#### Ejemplo de Generación
```dart
// 📄 activity_model.dart (archivo fuente)
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';

part 'activity_model.freezed.dart';  // Archivo que se generará
part 'activity_model.g.dart';        // Archivo que se generará

@freezed
@HiveType(typeId: 0)
class ActivityModel with _$ActivityModel {
  const ActivityModel._();
  
  @HiveField(0)
  const factory ActivityModel({
    @HiveField(1) required String id,
    @HiveField(2) required String title,
    @HiveField(3) required String description,
    @HiveField(4) required DateTime startTime,
    @HiveField(5) required DateTime endTime,
    @HiveField(6) @Default(false) bool isCompleted,
  }) = _ActivityModel;
  
  factory ActivityModel.fromJson(Map<String, dynamic> json) =>
      _$ActivityModelFromJson(json);
  
  // Métodos de dominio personalizados
  bool get isOverdue => DateTime.now().isAfter(endTime) && !isCompleted;
  
  ActivityModel toggleCompletion() => copyWith(isCompleted: !isCompleted);
}
```

Al ejecutar `build_runner`, se generan automáticamente:

```dart
// 📄 activity_model.freezed.dart (generado automáticamente)
// ¡NO EDITAR MANUALMENTE!

part of 'activity_model.dart';

class _$ActivityModelTearOff {
  const _$ActivityModelTearOff();

  _ActivityModel call({
    required String id,
    required String title,
    required String description,
    required DateTime startTime,
    required DateTime endTime,
    bool isCompleted = false,
  }) {
    return _ActivityModel(
      id: id,
      title: title,
      description: description,
      startTime: startTime,
      endTime: endTime,
      isCompleted: isCompleted,
    );
  }
}

const $ActivityModel = _$ActivityModelTearOff();

mixin _$ActivityModel {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  DateTime get startTime => throw _privateConstructorUsedError;
  DateTime get endTime => throw _privateConstructorUsedError;
  bool get isCompleted => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ActivityModelCopyWith<ActivityModel> get copyWith =>
      throw _privateConstructorUsedError;
}

abstract class $ActivityModelCopyWith<$Res> {
  factory $ActivityModelCopyWith(
          ActivityModel value, $Res Function(ActivityModel) then) =
      _$ActivityModelCopyWithImpl<$Res>;
  $Res call({
    String id,
    String title,
    String description,
    DateTime startTime,
    DateTime endTime,
    bool isCompleted,
  });
}

class _$ActivityModelCopyWithImpl<$Res> implements $ActivityModelCopyWith<$Res> {
  _$ActivityModelCopyWithImpl(this._value, this._then);

  final ActivityModel _value;
  final $Res Function(ActivityModel) _then;

  @override
  $Res call({
    Object? id = freezed,
    Object? title = freezed,
    Object? description = freezed,
    Object? startTime = freezed,
    Object? endTime = freezed,
    Object? isCompleted = freezed,
  }) {
    return _then(_value.copyWith(
      id: id == freezed ? _value.id : id as String,
      title: title == freezed ? _value.title : title as String,
      description: description == freezed ? _value.description : description as String,
      startTime: startTime == freezed ? _value.startTime : startTime as DateTime,
      endTime: endTime == freezed ? _value.endTime : endTime as DateTime,
      isCompleted: isCompleted == freezed ? _value.isCompleted : isCompleted as bool,
    ));
  }
}

class _ActivityModel extends ActivityModel {
  const _ActivityModel({
    required this.id,
    required this.title,
    required this.description,
    required this.startTime,
    required this.endTime,
    this.isCompleted = false,
  }) : super._();

  @override
  @HiveField(1)
  final String id;
  @override
  @HiveField(2)
  final String title;
  @override
  @HiveField(3)
  final String description;
  @override
  @HiveField(4)
  final DateTime startTime;
  @override
  @HiveField(5)
  final DateTime endTime;
  @override
  @JsonKey()
  @HiveField(6)
  final bool isCompleted;

  @override
  String toString() {
    return 'ActivityModel(id: $id, title: $title, description: $description, startTime: $startTime, endTime: $endTime, isCompleted: $isCompleted)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ActivityModel &&
            const DeepCollectionEquality().equals(other.id, id) &&
            const DeepCollectionEquality().equals(other.title, title) &&
            const DeepCollectionEquality().equals(other.description, description) &&
            const DeepCollectionEquality().equals(other.startTime, startTime) &&
            const DeepCollectionEquality().equals(other.endTime, endTime) &&
            const DeepCollectionEquality().equals(other.isCompleted, isCompleted));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(id),
      const DeepCollectionEquality().hash(title),
      const DeepCollectionEquality().hash(description),
      const DeepCollectionEquality().hash(startTime),
      const DeepCollectionEquality().hash(endTime),
      const DeepCollectionEquality().hash(isCompleted));

  @JsonKey(ignore: true)
  @override
  $ActivityModelCopyWith<ActivityModel> get copyWith =>
      _$ActivityModelCopyWithImpl<ActivityModel>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_ActivityModelToJson(this);
  }
}

abstract class _ActivityModel extends ActivityModel {
  const factory _ActivityModel({
    @HiveField(1) required String id,
    @HiveField(2) required String title,
    @HiveField(3) required String description,
    @HiveField(4) required DateTime startTime,
    @HiveField(5) required DateTime endTime,
    @HiveField(6) bool isCompleted,
  }) = _$_ActivityModel;
  const _ActivityModel._() : super._();

  factory _ActivityModel.fromJson(Map<String, dynamic> json) =
      _$_ActivityModel.fromJson;

  @override
  @HiveField(1)
  String get id;
  @override
  @HiveField(2)
  String get title;
  @override
  @HiveField(3)
  String get description;
  @override
  @HiveField(4)
  DateTime get startTime;
  @override
  @HiveField(5)
  DateTime get endTime;
  @override
  @HiveField(6)
  bool get isCompleted;
  @override
  @JsonKey(ignore: true)
  $ActivityModelCopyWith<ActivityModel> get copyWith =>
      throw _privateConstructorUsedError;
}
```

```dart
// 📄 activity_model.g.dart (generado automáticamente)
// ¡NO EDITAR MANUALMENTE!

part of 'activity_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ActivityModelAdapter extends TypeAdapter<ActivityModel> {
  @override
  final int typeId = 0;

  @override
  ActivityModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ActivityModel(
      id: fields[1] as String,
      title: fields[2] as String,
      description: fields[3] as String,
      startTime: fields[4] as DateTime,
      endTime: fields[5] as DateTime,
      isCompleted: fields[6] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, ActivityModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(1)
      ..write(obj.id)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.description)
      ..writeByte(4)
      ..write(obj.startTime)
      ..writeByte(5)
      ..write(obj.endTime)
      ..writeByte(6)
      ..write(obj.isCompleted);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ActivityModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_ActivityModel _$$_ActivityModelFromJson(Map<String, dynamic> json) =>
    _$_ActivityModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: DateTime.parse(json['endTime'] as String),
      isCompleted: json['isCompleted'] as bool? ?? false,
    );

Map<String, dynamic> _$$_ActivityModelToJson(_$_ActivityModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'startTime': instance.startTime.toIso8601String(),
      'endTime': instance.endTime.toIso8601String(),
      'isCompleted': instance.isCompleted,
    };
```

#### Scripts de Automatización
```bash
# 📄 scripts/generate.sh
#!/bin/bash

echo "🔄 Limpiando archivos generados..."
flutter packages pub run build_runner clean

echo "🚀 Generando código..."
flutter packages pub run build_runner build --delete-conflicting-outputs

echo "✅ Generación completada"

# 📄 scripts/watch.sh
#!/bin/bash

echo "👀 Iniciando modo watch..."
echo "Los archivos se regenerarán automáticamente cuando los edites"
flutter packages pub run build_runner watch --delete-conflicting-outputs
```

### 2. **Logger** - Sistema de Logging

#### ¿Qué es un Logger?
Es un sistema que registra eventos, errores y mensajes durante la ejecución de la aplicación para facilitar debugging y monitoreo.

#### ¿Para qué sirve?
- **Debugging**: Entender qué está pasando en la aplicación
- **Monitoreo**: Detectar errores y problemas en producción
- **Auditoría**: Rastrear acciones del usuario
- **Performance**: Medir tiempos de operaciones

#### Implementación del Logger
```dart
// 📄 core/utils/logger.dart
enum LogLevel {
  debug,    // Solo en modo debug
  info,     // Información general
  warning,  // Advertencias
  error,    // Errores
  critical, // Errores críticos
}

class Logger {
  static final Logger instance = Logger._internal();
  Logger._internal();
  
  // Configuración
  LogLevel _minLevel = kDebugMode ? LogLevel.debug : LogLevel.info;
  bool _enableFileLogging = false;
  late final File? _logFile;
  
  // Colores para console
  static const Map<LogLevel, String> _colors = {
    LogLevel.debug: '\x1B[37m',    // Blanco
    LogLevel.info: '\x1B[34m',     // Azul
    LogLevel.warning: '\x1B[33m',  // Amarillo
    LogLevel.error: '\x1B[31m',    // Rojo
    LogLevel.critical: '\x1B[35m', // Magenta
  };
  static const String _resetColor = '\x1B[0m';
  
  /// Inicializa el logger con configuración
  Future<void> initialize({
    LogLevel minLevel = LogLevel.info,
    bool enableFileLogging = false,
  }) async {
    _minLevel = minLevel;
    _enableFileLogging = enableFileLogging;
    
    if (_enableFileLogging) {
      try {
        final directory = await getApplicationDocumentsDirectory();
        _logFile = File('${directory.path}/app.log');
        await _logFile!.create(recursive: true);
        i('Logger inicializado con archivo: ${_logFile!.path}');
      } catch (e) {
        print('❌ Error inicializando archivo de log: $e');
        _enableFileLogging = false;
      }
    }
    
    i('Logger inicializado - Nivel mínimo: $_minLevel');
  }
  
  /// Log de debug (solo en modo debug)
  void d(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    if (kDebugMode) {
      _log(LogLevel.debug, message, tag: tag, error: error, stackTrace: stackTrace);
    }
  }
  
  /// Log de información
  void i(String message, {String? tag, Object? error}) {
    _log(LogLevel.info, message, tag: tag, error: error);
  }
  
  /// Log de advertencia
  void w(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.warning, message, tag: tag, error: error, stackTrace: stackTrace);
  }
  
  /// Log de error
  void e(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.error, message, tag: tag, error: error, stackTrace: stackTrace);
  }
  
  /// Log crítico
  void c(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.critical, message, tag: tag, error: error, stackTrace: stackTrace);
  }
  
  void _log(
    LogLevel level,
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    // Filtrar por nivel mínimo
    if (level.index < _minLevel.index) return;
    
    final timestamp = DateTime.now().toIso8601String();
    final levelStr = level.name.toUpperCase().padRight(8);
    final tagStr = tag != null ? '[$tag] ' : '';
    final errorStr = error != null ? ' - Error: $error' : '';
    
    // Formatear mensaje
    final logMessage = '$timestamp [$levelStr] $tagStr$message$errorStr';
    
    // Imprimir en consola con colores
    final color = _colors[level] ?? '';
    final coloredMessage = '$color$logMessage$_resetColor';
    print(coloredMessage);
    
    // Imprimir stack trace si existe
    if (stackTrace != null) {
      print('StackTrace:');
      print(stackTrace.toString());
    }
    
    // Escribir a archivo si está habilitado
    if (_enableFileLogging && _logFile != null) {
      _writeToFile(logMessage, stackTrace);
    }
    
    // Enviar a servicios de monitoreo en producción
    if (!kDebugMode && level.index >= LogLevel.error.index) {
      _sendToMonitoringService(level, message, error, stackTrace);
    }
  }
  
  void _writeToFile(String message, StackTrace? stackTrace) {
    try {
      _logFile!.writeAsStringSync(
        '$message\n',
        mode: FileMode.append,
      );
      
      if (stackTrace != null) {
        _logFile!.writeAsStringSync(
          'StackTrace: $stackTrace\n',
          mode: FileMode.append,
        );
      }
    } catch (e) {
      print('❌ Error escribiendo al archivo de log: $e');
    }
  }
  
  void _sendToMonitoringService(
    LogLevel level,
    String message,
    Object? error,
    StackTrace? stackTrace,
  ) {
    // Aquí integrarías con servicios como:
    // - Firebase Crashlytics
    // - Sentry
    // - Bugsnag
    // etc.
    
    // Ejemplo con Firebase Crashlytics:
    // FirebaseCrashlytics.instance.recordError(
    //   error ?? message,
    //   stackTrace,
    //   fatal: level == LogLevel.critical,
    // );
  }
  
  /// Obtiene los logs del archivo
  Future<String> getLogContent() async {
    if (!_enableFileLogging || _logFile == null) {
      return 'File logging no habilitado';
    }
    
    try {
      if (await _logFile!.exists()) {
        return await _logFile!.readAsString();
      } else {
        return 'Archivo de log no existe';
      }
    } catch (e) {
      return 'Error leyendo archivo de log: $e';
    }
  }
  
  /// Limpia el archivo de log
  Future<void> clearLog() async {
    if (_enableFileLogging && _logFile != null) {
      try {
        await _logFile!.writeAsString('');
        i('Archivo de log limpiado');
      } catch (e) {
        e('Error limpiando archivo de log: $e');
      }
    }
  }
  
  /// Configuración avanzada para diferentes entornos
  static void configureForEnvironment() {
    if (kDebugMode) {
      // Desarrollo: logs detallados
      Logger.instance.initialize(
        minLevel: LogLevel.debug,
        enableFileLogging: true,
      );
    } else if (kProfileMode) {
      // Profile: logs de performance
      Logger.instance.initialize(
        minLevel: LogLevel.info,
        enableFileLogging: true,
      );
    } else {
      // Producción: solo errores
      Logger.instance.initialize(
        minLevel: LogLevel.warning,
        enableFileLogging: false,
      );
    }
  }
}
```

#### Uso del Logger
```dart
// En repositorios
class ActivityRepository {
  final Logger _logger = Logger.instance;
  
  Future<void> addActivity(ActivityModel activity) async {
    _logger.i('Agregando actividad: ${activity.title}', tag: 'ActivityRepo');
    
    try {
      await LocalStorage.saveData<ActivityModel>(_boxName, activity.id, activity);
      _logger.i('Actividad guardada exitosamente', tag: 'ActivityRepo');
    } catch (e) {
      _logger.e('Error guardando actividad', tag: 'ActivityRepo', error: e);
      rethrow;
    }
  }
}

// En servicios
class NotificationService {
  final Logger _logger = Logger.instance;
  
  Future<void> scheduleNotification(ActivityModel activity) async {
    _logger.d('Programando notificación para: ${activity.title}', tag: 'Notifications');
    
    try {
      // Lógica de notificación...
      _logger.i('Notificación programada exitosamente', tag: 'Notifications');
    } catch (e) {
      _logger.w('Error programando notificación', tag: 'Notifications', error: e);
    }
  }
}

// En UI para debugging
class ActivityScreen extends StatefulWidget {
  @override
  _ActivityScreenState createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  final Logger _logger = Logger.instance;
  
  @override
  void initState() {
    super.initState();
    _logger.d('ActivityScreen inicializado', tag: 'UI');
  }
  
  void _onActivityTap(ActivityModel activity) {
    _logger.d('Activity tapped: ${activity.title}', tag: 'UI');
    // Navegar a detalles...
  }
  
  @override
  void dispose() {
    _logger.d('ActivityScreen disposed', tag: 'UI');
    super.dispose();
  }
}
```

#### Logger Widget para Debug
```dart
// 📄 widgets/debug_log_viewer.dart
class DebugLogViewer extends StatefulWidget {
  @override
  _DebugLogViewerState createState() => _DebugLogViewerState();
}

class _DebugLogViewerState extends State<DebugLogViewer> {
  String _logContent = '';
  bool _isLoading = false;
  
  @override
  void initState() {
    super.initState();
    _loadLogContent();
  }
  
  Future<void> _loadLogContent() async {
    setState(() => _isLoading = true);
    
    final content = await Logger.instance.getLogContent();
    
    setState(() {
      _logContent = content;
      _isLoading = false;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Debug Logs'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadLogContent,
          ),
          IconButton(
            icon: Icon(Icons.clear),
            onPressed: _clearLogs,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Text(
                _logContent.isEmpty ? 'No hay logs disponibles' : _logContent,
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                ),
              ),
            ),
    );
  }
  
  Future<void> _clearLogs() async {
    await Logger.instance.clearLog();
    await _loadLogContent();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Logs limpiados')),
    );
  }
}
```

---

¡Esta guía cubre todos los conceptos y tecnologías principales utilizados en TempoSage! 🚀 

Cada sección incluye:
- ✅ **Explicación clara** del concepto
- ✅ **Casos de uso prácticos**
- ✅ **Implementaciones completas**
- ✅ **Ejemplos de código funcional**
- ✅ **Comparaciones** con otros enfoques
- ✅ **Best practices** y recomendaciones
</rewritten_file> 