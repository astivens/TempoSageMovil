import 'package:injectable/injectable.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/services/notification_service.dart';
import '../../data/models/activity_model.dart';
import '../../data/repositories/activity_repository.dart';

@singleton
class ActivityNotificationService {
  final NotificationService _notificationService;
  final ActivityRepository _activityRepository;

  ActivityNotificationService(
      this._notificationService, this._activityRepository);

  /// Programa notificaciones para una actividad
  Future<void> scheduleActivityNotification(ActivityModel activity) async {
    if (!activity.sendReminder) return;

    try {
      // Generar ID único para esta notificación basado en el ID de la actividad
      final int notificationId = activity.id.hashCode;

      // Calcular la fecha de la notificación basada en el recordatorio
      final DateTime notificationTime = activity.startTime
          .subtract(Duration(minutes: activity.reminderMinutesBefore));

      // Si la fecha ya pasó, no programar notificación
      if (notificationTime.isBefore(DateTime.now())) {
        return;
      }

      // Crear payload con información relevante para la navegación
      final String payload = 'activity:${activity.id}';

      // Programar la notificación
      await _notificationService.scheduleNotification(
        title: 'Recordatorio de actividad',
        body: 'Tu actividad "${activity.title}" comenzará pronto',
        scheduledDate: notificationTime,
        category: NotificationCategory.activities,
        payload: payload,
        id: notificationId,
      );

      debugPrint(
          'Notificación programada para la actividad ${activity.id} a las ${notificationTime.toIso8601String()}');
    } catch (e) {
      debugPrint('Error al programar notificación: $e');
    }
  }

  /// Programa notificaciones para múltiples actividades
  Future<void> scheduleAllActivityNotifications() async {
    try {
      final activities = await _activityRepository.getAllActivities();
      for (final activity in activities) {
        if (activity.sendReminder) {
          await scheduleActivityNotification(activity);
        }
      }
      debugPrint('Todas las notificaciones de actividades programadas');
    } catch (e) {
      debugPrint('Error al programar notificaciones: $e');
    }
  }

  /// Cancela la notificación de una actividad
  Future<void> cancelActivityNotification(String activityId) async {
    final int notificationId = activityId.hashCode;
    await _notificationService.cancelNotification(notificationId);
    debugPrint('Notificación cancelada para la actividad $activityId');
  }

  /// Actualiza la notificación de una actividad (cancela la anterior y crea una nueva)
  Future<void> updateActivityNotification(ActivityModel activity) async {
    // Primero cancelar la notificación existente
    await cancelActivityNotification(activity.id);

    // Luego programar la nueva si es necesario
    if (activity.sendReminder) {
      await scheduleActivityNotification(activity);
    }
  }
}
