import 'package:flutter/foundation.dart';
import '../errors/app_exception.dart';

/// Niveles de log disponibles
enum LogLevel {
  debug,
  info,
  warning,
  error,
  critical,
}

/// Sistema de logging centralizado para la aplicación
class Logger {
  static final Logger _instance = Logger._internal();
  static Logger get instance => _instance;

  Logger._internal();

  /// Configuración del nivel mínimo de log
  LogLevel _minLevel = kDebugMode ? LogLevel.debug : LogLevel.info;

  /// Determina si se muestran registros completos o simplificados
  bool _verboseMode = false;

  /// Configura el nivel mínimo de log
  void setMinLevel(LogLevel level) {
    _minLevel = level;
  }

  /// Configura el modo verboso para logs detallados
  void setVerboseMode(bool verbose) {
    _verboseMode = verbose;
  }

  /// Log de nivel debug (solo para desarrollo)
  void d(String message, {String? tag, Map<String, dynamic>? data}) {
    _log(LogLevel.debug, message, tag: tag, data: data);
  }

  /// Log de nivel info (información general)
  void i(String message, {String? tag, Map<String, dynamic>? data}) {
    _log(LogLevel.info, message, tag: tag, data: data);
  }

  /// Log de nivel warning (situaciones anómalas pero no errores)
  void w(String message, {String? tag, Map<String, dynamic>? data}) {
    _log(LogLevel.warning, message, tag: tag, data: data);
  }

  /// Log de nivel error (situaciones de error recuperables)
  void e(String message,
      {String? tag,
      dynamic error,
      StackTrace? stackTrace,
      Map<String, dynamic>? data}) {
    _log(
      LogLevel.error,
      message,
      tag: tag,
      error: error,
      stackTrace: stackTrace,
      data: data,
    );
  }

  /// Log de nivel critical (errores graves que pueden detener la aplicación)
  void c(String message,
      {String? tag,
      dynamic error,
      StackTrace? stackTrace,
      Map<String, dynamic>? data}) {
    _log(
      LogLevel.critical,
      message,
      tag: tag,
      error: error,
      stackTrace: stackTrace,
      data: data,
    );
  }

  /// Registra una excepción de la aplicación
  void exception(AppException exception,
      {String? tag, StackTrace? stackTrace, Map<String, dynamic>? data}) {
    final errorData = {
      'code': exception.code,
      'originalError': exception.originalError,
      ...?data,
    };

    _log(
      LogLevel.error,
      exception.message,
      tag: tag ?? 'Exception',
      error: exception,
      stackTrace: stackTrace,
      data: errorData,
    );
  }

  /// Método interno para registrar mensajes de log
  void _log(
    LogLevel level,
    String message, {
    String? tag,
    dynamic error,
    StackTrace? stackTrace,
    Map<String, dynamic>? data,
  }) {
    if (level.index < _minLevel.index) return;

    final dateTime = DateTime.now().toIso8601String();
    final logTag = tag != null ? '[$tag]' : '';
    final logLevel = level.toString().split('.').last.toUpperCase();

    // Formato básico del mensaje
    String logMessage = '[$dateTime][$logLevel]$logTag $message';

    // En modo no verboso, solo agregamos información adicional para niveles superiores a info
    bool shouldAddDetails =
        _verboseMode || level.index >= LogLevel.warning.index;

    // Agregar datos adicionales si existen y se permite
    if (shouldAddDetails && data != null && data.isNotEmpty) {
      logMessage += '\nData: $data';
    }

    // Agregar información de error si existe y se permite
    if (shouldAddDetails && error != null) {
      logMessage += '\nError: $error';

      if (stackTrace != null) {
        // En modo no verboso, limitamos la traza a las primeras 5 líneas
        String stackTraceStr = stackTrace.toString();
        if (!_verboseMode) {
          final lines = stackTraceStr.split('\n');
          if (lines.length > 5) {
            stackTraceStr = '${lines.take(5).join('\n')}\n...';
          }
        }
        logMessage += '\nStackTrace: $stackTraceStr';
      }
    }

    // Imprimir según el nivel de log
    switch (level) {
      case LogLevel.debug:
      case LogLevel.info:
        debugPrint(logMessage);
        break;
      case LogLevel.warning:
      case LogLevel.error:
      case LogLevel.critical:
        debugPrint('\x1B[31m$logMessage\x1B[0m'); // Rojo para errores
        break;
    }

    // Aquí podrías integrar servicios de reporting como Firebase Crashlytics
    // para niveles de error y críticos
  }
}
