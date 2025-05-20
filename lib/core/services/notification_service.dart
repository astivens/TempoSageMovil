import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'dart:io';

enum NotificationCategory { activities, habits, tasks, reminders, system }

@singleton
class NotificationService {
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  bool _hasPermission = false;

  /// Inicializa el servicio de notificaciones
  Future<void> initialize() async {
    try {
      debugPrint('Inicializando servicio de notificaciones...');

      // Inicializar zona horaria para las notificaciones programadas
      tz_data.initializeTimeZones();

      // Crear todos los canales de notificación para Android (para asegurar que existan)
      if (Platform.isAndroid) {
        await _createNotificationChannels();
      }

      // Configuración para Android
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      // Configuración para iOS
      final DarwinInitializationSettings initializationSettingsIOS =
          DarwinInitializationSettings(
        requestAlertPermission:
            true, // Cambiar a true para solicitar automáticamente en iOS
        requestBadgePermission: true,
        requestSoundPermission: true,
        onDidReceiveLocalNotification:
            (int id, String? title, String? body, String? payload) async {
          // No hacer nada aquí, ya que esta callback es para iOS < 10
        },
      );

      // Configuración general
      final InitializationSettings initializationSettings =
          InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
      );

      // Inicializar con configuraciones
      final bool? initResult = await _localNotifications.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      debugPrint('Resultado de inicialización: $initResult');

      // Solicitar permisos
      final hasPermission = await requestPermission();
      debugPrint('Permisos de notificación obtenidos: $hasPermission');

      // En Android, verificar si los canales están creados correctamente
      if (Platform.isAndroid) {
        final androidImpl =
            _localNotifications.resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>();

        if (androidImpl != null) {
          final channels = await androidImpl.getNotificationChannels();
          debugPrint(
              'Canales de notificación configurados: ${channels?.length ?? 0}');
          channels?.forEach((channel) {
            debugPrint('Canal: ${channel.id} - ${channel.name}');
          });
        }
      }
    } catch (e) {
      debugPrint('ERROR al inicializar notificaciones: $e');
    }
  }

  /// Crea los canales de notificación para Android
  Future<void> _createNotificationChannels() async {
    final androidImpl =
        _localNotifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidImpl != null) {
      // Crear canal para actividades
      await androidImpl.createNotificationChannel(
        const AndroidNotificationChannel(
          'temposage_activities_channel',
          'Actividades',
          description: 'Notificaciones de actividades programadas',
          importance: Importance.high,
        ),
      );

      // Crear canal para hábitos
      await androidImpl.createNotificationChannel(
        const AndroidNotificationChannel(
          'temposage_habits_channel',
          'Hábitos',
          description: 'Recordatorios de hábitos programados',
          importance: Importance.high,
        ),
      );

      // Crear canal para sistema
      await androidImpl.createNotificationChannel(
        const AndroidNotificationChannel(
          'temposage_system_channel',
          'Sistema',
          description: 'Notificaciones del sistema',
          importance: Importance.high,
        ),
      );
    }
  }

  /// Solicita permisos para mostrar notificaciones
  Future<bool> requestPermission() async {
    try {
      if (Platform.isIOS) {
        final bool? result = await _localNotifications
            .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin>()
            ?.requestPermissions(
              alert: true,
              badge: true,
              sound: true,
            );
        _hasPermission = result ?? false;
        debugPrint('Permisos iOS: $_hasPermission');
      } else if (Platform.isAndroid) {
        final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
            _localNotifications.resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>();

        if (androidImplementation != null) {
          try {
            final bool? granted =
                await androidImplementation.requestNotificationsPermission();
            _hasPermission = granted ?? false;
            debugPrint('Permisos Android: $_hasPermission');
          } catch (e) {
            debugPrint('Error al solicitar permisos Android: $e');
            // En versiones más antiguas de Android, puede que el método no esté disponible
            _hasPermission = true;
          }
        } else {
          debugPrint('No se pudo obtener implementación Android');
          _hasPermission = true;
        }
      } else {
        _hasPermission = true; // Para otras plataformas, asumimos permiso
      }

      return _hasPermission;
    } catch (e) {
      debugPrint('ERROR en requestPermission: $e');
      return false;
    }
  }

  /// Verifica si tiene permisos de notificación
  bool get hasPermission => _hasPermission;

  /// Maneja cuando el usuario toca una notificación
  void _onNotificationTapped(NotificationResponse details) {
    // Implementar la navegación o acciones basadas en el payload
    if (details.payload != null && details.payload!.isNotEmpty) {
      debugPrint('Notificación tocada con payload: ${details.payload}');

      final payload = details.payload!;
      final parts = payload.split(':');

      if (parts.isNotEmpty) {
        final type = parts[0];

        switch (type) {
          case 'activity':
            if (parts.length > 1) {
              final activityId = parts[1];
              _navigateToActivityDetail(activityId);
            }
            break;
          case 'habit':
            if (parts.length > 1) {
              final habitId = parts[1];
              _navigateToHabitDetail(habitId);
            }
            break;
        }
      }
    }
  }

  /// Navega a la pantalla de detalle de actividad
  void _navigateToActivityDetail(String activityId) {
    // Usar el servicio de navegación para abrir la actividad
    // (Esta implementación requerirá extender el NavigationService)
    // NavigationService.navigateToActivityDetail(activityId);
    debugPrint('Navegando a detalles de actividad: $activityId');
  }

  /// Navega a la pantalla de detalle de hábito
  void _navigateToHabitDetail(String habitId) {
    // Usar el servicio de navegación para abrir el hábito
    // (Esta implementación requerirá extender el NavigationService)
    // NavigationService.navigateToHabitDetail(habitId);
    debugPrint('Navegando a detalles de hábito: $habitId');
  }

  /// Muestra una notificación inmediata
  Future<void> showNotification({
    required String title,
    required String body,
    required NotificationCategory category,
    String? payload,
    int id = 0,
  }) async {
    if (!_hasPermission) {
      debugPrint('No hay permisos para mostrar notificaciones');
      return;
    }

    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      _getCategoryChannel(category),
      _getCategoryName(category),
      channelDescription: 'Notificaciones de ${_getCategoryName(category)}',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    final DarwinNotificationDetails iosDetails =
        const DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      id,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  /// Programa una notificación para una fecha específica
  Future<void> scheduleNotification({
    required String title,
    required String body,
    required DateTime scheduledDate,
    required NotificationCategory category,
    String? payload,
    int id = 0,
  }) async {
    if (!_hasPermission) {
      debugPrint('No hay permisos para programar notificaciones');
      return;
    }

    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      _getCategoryChannel(category),
      _getCategoryName(category),
      channelDescription:
          'Notificaciones programadas de ${_getCategoryName(category)}',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    final DarwinNotificationDetails iosDetails =
        const DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      notificationDetails,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: payload,
    );
  }

  /// Programa una notificación recurrente (diaria, semanal, etc.)
  Future<void> scheduleRecurringNotification({
    required String title,
    required String body,
    required NotificationCategory category,
    required DateTimeComponents repeating,
    required DateTime scheduledDate,
    String? payload,
    int id = 0,
  }) async {
    if (!_hasPermission) {
      debugPrint('No hay permisos para programar notificaciones recurrentes');
      return;
    }

    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      _getCategoryChannel(category),
      _getCategoryName(category),
      channelDescription:
          'Notificaciones recurrentes de ${_getCategoryName(category)}',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    final DarwinNotificationDetails iosDetails =
        const DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      notificationDetails,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: payload,
      matchDateTimeComponents: repeating,
    );
  }

  /// Cancela una notificación específica
  Future<void> cancelNotification(int id) async {
    await _localNotifications.cancel(id);
  }

  /// Cancela todas las notificaciones
  Future<void> cancelAllNotifications() async {
    await _localNotifications.cancelAll();
  }

  /// Cancela todas las notificaciones de una categoría específica
  Future<void> cancelNotificationsByCategory(
      NotificationCategory category) async {
    // Flutter_local_notifications no tiene funcionalidad para cancelar por grupo
    // Esto requeriría mantener un registro de IDs por categoría
    // Implementación pendiente
  }

  /// Obtiene el ID del canal basado en la categoría
  String _getCategoryChannel(NotificationCategory category) {
    switch (category) {
      case NotificationCategory.activities:
        return 'temposage_activities_channel';
      case NotificationCategory.habits:
        return 'temposage_habits_channel';
      case NotificationCategory.tasks:
        return 'temposage_tasks_channel';
      case NotificationCategory.reminders:
        return 'temposage_reminders_channel';
      case NotificationCategory.system:
        return 'temposage_system_channel';
    }
  }

  /// Obtiene el nombre del canal basado en la categoría
  String _getCategoryName(NotificationCategory category) {
    switch (category) {
      case NotificationCategory.activities:
        return 'Actividades';
      case NotificationCategory.habits:
        return 'Hábitos';
      case NotificationCategory.tasks:
        return 'Tareas';
      case NotificationCategory.reminders:
        return 'Recordatorios';
      case NotificationCategory.system:
        return 'Sistema';
    }
  }

  /// Muestra una notificación de prueba inmediata para verificar que el sistema funciona
  Future<void> showTestNotification() async {
    try {
      debugPrint('Intentando mostrar notificación de prueba...');

      // Verificar permisos explícitamente
      final hasPermissions = await requestPermission();
      debugPrint('¿Tiene permisos? $hasPermissions');

      if (!hasPermissions) {
        debugPrint(
            'No hay permisos para mostrar notificaciones. Solicitando permisos...');
        // Intento adicional de solicitar permisos
        await requestPermission();
      }

      // Crear notificación simplificada para pruebas
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        'temposage_system_channel',
        'Sistema',
        channelDescription: 'Notificaciones del sistema',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
        visibility: NotificationVisibility.public,
      );

      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      );

      // Mostrar notificación directamente
      await _localNotifications.show(
        999,
        'Notificación de prueba',
        'Esta es una notificación de prueba a las ${DateTime.now().hour}:${DateTime.now().minute}',
        notificationDetails,
      );

      debugPrint('Notificación de prueba enviada correctamente');

      // Registrar diagnóstico
      await generateDiagnosticReport();
    } catch (e) {
      debugPrint('ERROR al mostrar notificación de prueba: $e');
    }
  }

  /// Genera un informe de diagnóstico sobre las notificaciones
  Future<String> generateDiagnosticReport() async {
    try {
      final StringBuffer report = StringBuffer();
      report.writeln('==== REPORTE DE DIAGNÓSTICO DE NOTIFICACIONES ====');
      report.writeln('Fecha y hora: ${DateTime.now().toString()}');
      report.writeln(
          'Plataforma: ${Platform.operatingSystem} ${Platform.operatingSystemVersion}');
      report.writeln('Permisos: $_hasPermission');

      if (Platform.isAndroid) {
        final androidImpl =
            _localNotifications.resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>();

        if (androidImpl != null) {
          // Verificar canales
          final channels = await androidImpl.getNotificationChannels();
          report.writeln('Canales de notificación: ${channels?.length ?? 0}');

          channels?.forEach((channel) {
            report.writeln('  - Canal: ${channel.id}');
            report.writeln('    Nombre: ${channel.name}');
            report.writeln('    Importancia: ${channel.importance.value}');
            report.writeln('    Sonido: ${channel.sound?.sound}');
          });

          // Verificar permisos específicos
          try {
            final areNotificationsEnabled =
                await androidImpl.areNotificationsEnabled();
            report.writeln(
                'Notificaciones habilitadas: $areNotificationsEnabled');
          } catch (e) {
            report.writeln(
                'Error al verificar si las notificaciones están habilitadas: $e');
          }
        } else {
          report.writeln('No se pudo obtener implementación Android');
        }
      }

      if (Platform.isIOS) {
        final iosImpl =
            _localNotifications.resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin>();

        if (iosImpl != null) {
          try {
            final authorized = await iosImpl.requestPermissions(
              alert: true,
              badge: true,
              sound: true,
            );
            report.writeln('iOS autorizado: $authorized');
          } catch (e) {
            report.writeln('Error al verificar permisos iOS: $e');
          }
        } else {
          report.writeln('No se pudo obtener implementación iOS');
        }
      }

      final String reportText = report.toString();
      debugPrint(reportText);
      return reportText;
    } catch (e) {
      debugPrint('Error al generar reporte de diagnóstico: $e');
      return 'Error: $e';
    }
  }
}
