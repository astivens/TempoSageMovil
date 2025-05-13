import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../../../core/services/notification_service.dart';
import '../repositories/habit_repository.dart';
import '../entities/habit.dart';

@singleton
class HabitNotificationService {
  final NotificationService _notificationService;
  final HabitRepository _habitRepository;

  HabitNotificationService(this._notificationService, this._habitRepository);

  /// Programa una notificación para un hábito en días específicos de la semana
  Future<void> scheduleHabitNotification(Habit habit) async {
    if (habit.reminder != 'Si') return;

    try {
      // Obtener la hora del hábito (formato "HH:MM")
      final timeParts = habit.time.split(':');
      if (timeParts.length != 2) {
        debugPrint('Formato de hora inválido para el hábito: ${habit.time}');
        return;
      }

      final hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);

      // Mapeo de nombres de días en español a números (1 = lunes, 7 = domingo)
      final daysMap = {
        'Lunes': 1,
        'Martes': 2,
        'Miércoles': 3,
        'Jueves': 4,
        'Viernes': 5,
        'Sábado': 6,
        'Domingo': 7
      };

      // Para cada día de la semana, programar una notificación recurrente
      for (final day in habit.daysOfWeek) {
        final dayNumber = daysMap[day];
        if (dayNumber == null) {
          debugPrint('Día de la semana inválido: $day');
          continue;
        }

        // Obtener la próxima fecha para este día de la semana
        final now = DateTime.now();
        DateTime nextDate = _nextDateForDayOfWeek(now, dayNumber);

        // Establecer la hora específica para la notificación
        final scheduledDate = DateTime(
          nextDate.year,
          nextDate.month,
          nextDate.day,
          hour,
          minute,
        );

        // Generar un ID único para esta notificación basado en el ID del hábito y el día
        final int notificationId = '${habit.id}:$day'.hashCode;

        // Crear payload con información relevante para la navegación
        final String payload = 'habit:${habit.id}:$day';

        // Programar la notificación recurrente semanal
        await _notificationService.scheduleRecurringNotification(
          title: 'Recordatorio de hábito',
          body: 'Es hora de: "${habit.name}"',
          scheduledDate: scheduledDate,
          category: NotificationCategory.habits,
          repeating: DateTimeComponents.dayOfWeekAndTime,
          payload: payload,
          id: notificationId,
        );

        debugPrint(
            'Notificación programada para el hábito ${habit.id} los $day a las ${habit.time}');
      }
    } catch (e) {
      debugPrint('Error al programar notificación de hábito: $e');
    }
  }

  /// Cancela todas las notificaciones para un hábito
  Future<void> cancelHabitNotifications(String habitId) async {
    try {
      final daysOfWeek = [
        'Lunes',
        'Martes',
        'Miércoles',
        'Jueves',
        'Viernes',
        'Sábado',
        'Domingo'
      ];

      for (final day in daysOfWeek) {
        final int notificationId = '${habitId}:$day'.hashCode;
        await _notificationService.cancelNotification(notificationId);
      }

      debugPrint('Notificaciones canceladas para el hábito $habitId');
    } catch (e) {
      debugPrint('Error al cancelar notificaciones de hábito: $e');
    }
  }

  /// Actualiza las notificaciones de un hábito (cancela las anteriores y crea nuevas)
  Future<void> updateHabitNotifications(Habit habit) async {
    // Primero cancelar las notificaciones existentes
    await cancelHabitNotifications(habit.id);

    // Luego programar las nuevas si es necesario
    if (habit.reminder == 'Si') {
      await scheduleHabitNotification(habit);
    }
  }

  /// Programa notificaciones para todos los hábitos
  Future<void> scheduleAllHabitNotifications() async {
    try {
      final habits = await _habitRepository.getAllHabits();
      for (final habit in habits) {
        if (habit.reminder == 'Si') {
          await scheduleHabitNotification(habit);
        }
      }
      debugPrint('Todas las notificaciones de hábitos programadas');
    } catch (e) {
      debugPrint('Error al programar todas las notificaciones de hábitos: $e');
    }
  }

  /// Obtiene la próxima fecha para un día específico de la semana
  DateTime _nextDateForDayOfWeek(DateTime date, int targetDayOfWeek) {
    // Convertir de ISO (1-7 donde 1 es lunes) a DateTime (1-7 donde 1 es lunes)
    final currentDayOfWeek = date.weekday;

    // Calcula cuántos días faltan hasta el próximo día objetivo
    int daysUntilTarget = targetDayOfWeek - currentDayOfWeek;
    if (daysUntilTarget <= 0) {
      // Si el día objetivo ya pasó esta semana, ir a la próxima semana
      daysUntilTarget += 7;
    }

    // Crear la nueva fecha
    return date.add(Duration(days: daysUntilTarget));
  }
}
