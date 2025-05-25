import 'dart:async';

/// Servicio de eventos para comunicación entre pantallas
class EventBus {
  static final EventBus _instance = EventBus._internal();
  factory EventBus() => _instance;
  EventBus._internal();

  final StreamController<String> _eventController =
      StreamController<String>.broadcast();

  /// Stream para escuchar eventos
  Stream<String> get events => _eventController.stream;

  /// Emitir un evento
  void emit(String event) {
    _eventController.add(event);
  }

  /// Cerrar el stream
  void dispose() {
    _eventController.close();
  }
}

/// Eventos disponibles
class AppEvents {
  static const String activityCreated = 'activity_created';
  static const String habitCreated = 'habit_created';
  static const String timeBlockCreated = 'timeblock_created';
  static const String dataChanged = 'data_changed';
}
