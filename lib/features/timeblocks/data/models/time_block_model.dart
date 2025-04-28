import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'time_block_model.g.dart';

/// Modelo que representa un bloque de tiempo en la aplicación.
///
/// Un bloque de tiempo es un período definido con una hora de inicio y fin,
/// que puede representar una actividad, un hábito o cualquier otro evento programado.
@HiveType(typeId: 6)
class TimeBlockModel extends HiveObject {
  /// Identificador único del bloque de tiempo
  @HiveField(0)
  final String id;

  /// Título o nombre del bloque de tiempo
  @HiveField(1)
  final String title;

  /// Descripción detallada del bloque de tiempo
  @HiveField(2)
  final String description;

  /// Fecha y hora de inicio del bloque
  @HiveField(3)
  final DateTime startTime;

  /// Fecha y hora de finalización del bloque
  @HiveField(4)
  final DateTime endTime;

  /// Categoría del bloque (ej: trabajo, personal, estudio)
  @HiveField(5)
  final String category;

  /// Indica si este bloque requiere enfoque profundo
  @HiveField(6)
  final bool isFocusTime;

  /// Color del bloque en formato hexadecimal (#RRGGBB)
  @HiveField(7)
  final String color;

  /// Indica si el bloque ha sido completado
  @HiveField(8)
  final bool isCompleted;

  /// Constructor principal que crea una instancia de TimeBlockModel.
  TimeBlockModel({
    required this.id,
    required this.title,
    required this.description,
    required this.startTime,
    required this.endTime,
    required this.category,
    this.isFocusTime = false,
    required this.color,
    this.isCompleted = false,
  }) {
    // Validación en tiempo de ejecución
    assert(title.isNotEmpty, 'El título no puede estar vacío');
    assert(
      endTime.isAfter(startTime),
      'La hora de finalización debe ser posterior a la hora de inicio',
    );
    assert(
      color.startsWith('#') && color.length == 7,
      'El color debe estar en formato hexadecimal (#RRGGBB)',
    );
  }

  /// Crea un nuevo bloque de tiempo con un ID generado automáticamente.
  ///
  /// Este método facilita la creación de nuevos bloques de tiempo sin
  /// necesidad de proporcionar un ID manualmente.
  factory TimeBlockModel.create({
    required String title,
    required String description,
    required DateTime startTime,
    required DateTime endTime,
    required String category,
    bool isFocusTime = false,
    required String color,
    bool isCompleted = false,
  }) {
    return TimeBlockModel(
      id: const Uuid().v4(),
      title: title,
      description: description,
      startTime: startTime,
      endTime: endTime,
      category: category,
      isFocusTime: isFocusTime,
      color: color,
      isCompleted: isCompleted,
    );
  }

  /// Obtiene la duración del bloque de tiempo.
  Duration get duration => endTime.difference(startTime);

  /// Verifica si el bloque de tiempo está actualmente en progreso.
  bool get isInProgress {
    final now = DateTime.now();
    return now.isAfter(startTime) && now.isBefore(endTime);
  }

  /// Verifica si el bloque de tiempo está pendiente (no ha comenzado).
  bool get isPending {
    final now = DateTime.now();
    return now.isBefore(startTime);
  }

  /// Verifica si el bloque de tiempo ya ha pasado.
  bool get isPast {
    final now = DateTime.now();
    return now.isAfter(endTime);
  }

  /// Crea una copia de este bloque de tiempo con los valores proporcionados reemplazados.
  TimeBlockModel copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? startTime,
    DateTime? endTime,
    String? category,
    bool? isFocusTime,
    String? color,
    bool? isCompleted,
  }) {
    return TimeBlockModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      category: category ?? this.category,
      isFocusTime: isFocusTime ?? this.isFocusTime,
      color: color ?? this.color,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  /// Marca este bloque de tiempo como completado.
  TimeBlockModel markAsCompleted() {
    return copyWith(isCompleted: true);
  }

  /// Marca este bloque de tiempo como no completado.
  TimeBlockModel markAsNotCompleted() {
    return copyWith(isCompleted: false);
  }

  /// Obtiene una representación en texto del bloque de tiempo.
  @override
  String toString() {
    return 'TimeBlockModel(id: $id, title: $title, startTime: $startTime, endTime: $endTime, '
        'category: $category, isCompleted: $isCompleted)';
  }
}
