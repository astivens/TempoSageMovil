import 'package:flutter/material.dart';

/// Utilidades para manejo de fechas y horas en la aplicación.
class DateTimeUtils {
  // Lista de días de la semana en español
  static const List<String> _weekdaysES = [
    'Lunes',
    'Martes',
    'Miércoles',
    'Jueves',
    'Viernes',
    'Sábado',
    'Domingo'
  ];

  // Lista de días de la semana en inglés
  static const List<String> _weekdaysEN = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];

  // Lista de meses abreviados en español
  static const List<String> _shortMonthsES = [
    'Ene',
    'Feb',
    'Mar',
    'Abr',
    'May',
    'Jun',
    'Jul',
    'Ago',
    'Sep',
    'Oct',
    'Nov',
    'Dic'
  ];

  /// Formatea una fecha en formato día/mes/año
  static String formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  /// Formatea una fecha en formato largo (ej: Lunes, 15 de Enero de 2023)
  static String formatLongDate(DateTime date) {
    return '${getDayOfWeekES(date)}, ${date.day} de ${getMonthNameES(date.month)} de ${date.year}';
  }

  /// Obtiene el nombre del día de la semana en español para una fecha dada
  static String getDayOfWeekES(DateTime date) {
    // weekday en Dart: 1 = lunes, 7 = domingo
    return _weekdaysES[date.weekday - 1];
  }

  /// Obtiene el nombre del día de la semana en inglés para una fecha dada
  static String getDayOfWeekEN(DateTime date) {
    // weekday en Dart: 1 = Monday, 7 = Sunday
    return _weekdaysEN[date.weekday - 1];
  }

  /// Obtiene el nombre del mes en español
  static String getMonthNameES(int month) {
    const months = [
      'Enero',
      'Febrero',
      'Marzo',
      'Abril',
      'Mayo',
      'Junio',
      'Julio',
      'Agosto',
      'Septiembre',
      'Octubre',
      'Noviembre',
      'Diciembre'
    ];
    return months[month - 1];
  }

  /// Obtiene el nombre abreviado del mes para una fecha dada
  static String getShortMonthES(DateTime date) {
    return _shortMonthsES[date.month - 1];
  }

  /// Formatea una hora en formato HH:MM
  static String formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  /// Verifica si dos fechas son el mismo día (ignorando la hora)
  static bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  /// Obtiene el inicio del día (00:00:00) para una fecha dada
  static DateTime startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// Obtiene el final del día (23:59:59) para una fecha dada
  static DateTime endOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59);
  }

  /// Combina una fecha con una hora
  static DateTime combineDateAndTime(DateTime date, TimeOfDay time) {
    return DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
  }
}
