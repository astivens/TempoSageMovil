/// Utilidades para manejo de fechas y horas en la aplicación.
class DateTimeHelper {
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

  /// Obtiene el nombre del día de la semana basado en la configuración de la app
  /// Por defecto devuelve en español
  static String getDayOfWeek(DateTime date, {bool useEnglish = false}) {
    return useEnglish ? getDayOfWeekEN(date) : getDayOfWeekES(date);
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

  /// Obtiene el inicio de la semana (lunes) para una fecha dada
  static DateTime startOfWeek(DateTime date) {
    // weekday: 1 = lunes, 7 = domingo
    final daysSinceMonday = date.weekday - 1;
    return startOfDay(date.subtract(Duration(days: daysSinceMonday)));
  }

  /// Obtiene el fin de la semana (domingo) para una fecha dada
  static DateTime endOfWeek(DateTime date) {
    // weekday: 1 = lunes, 7 = domingo
    final daysUntilSunday = 7 - date.weekday;
    return endOfDay(date.add(Duration(days: daysUntilSunday)));
  }

  /// Obtiene una lista de los días en una semana a partir de una fecha
  static List<DateTime> getDaysInWeek(DateTime date) {
    final start = startOfWeek(date);
    return List.generate(
      7,
      (index) => DateTime(
        start.year,
        start.month,
        start.day + index,
      ),
    );
  }

  /// Obtiene el nombre abreviado del mes para una fecha dada
  static String getShortMonth(DateTime date) {
    const months = [
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
    return months[date.month - 1];
  }
}
