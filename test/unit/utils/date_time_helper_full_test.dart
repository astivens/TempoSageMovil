import 'package:flutter_test/flutter_test.dart';
import 'package:temposage/core/utils/date_time_helper.dart';

void main() {
  group('DateTimeHelper', () {
    test('getDayOfWeekES retorna el día de la semana en español', () {
      final monday = DateTime(2023, 5, 15); // Lunes
      final sunday = DateTime(2023, 5, 21); // Domingo

      expect(DateTimeHelper.getDayOfWeekES(monday), 'Lunes');
      expect(DateTimeHelper.getDayOfWeekES(sunday), 'Domingo');
    });

    test('getDayOfWeekEN retorna el día de la semana en inglés', () {
      final monday = DateTime(2023, 5, 15); // Monday
      final sunday = DateTime(2023, 5, 21); // Sunday

      expect(DateTimeHelper.getDayOfWeekEN(monday), 'Monday');
      expect(DateTimeHelper.getDayOfWeekEN(sunday), 'Sunday');
    });

    test('getDayOfWeek retorna el día según la configuración', () {
      final date = DateTime(2023, 5, 15); // Lunes/Monday

      expect(DateTimeHelper.getDayOfWeek(date), 'Lunes');
      expect(DateTimeHelper.getDayOfWeek(date, useEnglish: true), 'Monday');
    });

    test('formatTime formatea correctamente la hora', () {
      final morning = DateTime(2023, 5, 15, 9, 5);
      final evening = DateTime(2023, 5, 15, 21, 30);

      expect(DateTimeHelper.formatTime(morning), '09:05');
      expect(DateTimeHelper.formatTime(evening), '21:30');
    });

    test('isSameDay identifica correctamente días iguales y diferentes', () {
      final date1 = DateTime(2023, 5, 15, 9, 0);
      final date2 = DateTime(2023, 5, 15, 21, 0);
      final date3 = DateTime(2023, 5, 16, 9, 0);

      expect(DateTimeHelper.isSameDay(date1, date2), isTrue);
      expect(DateTimeHelper.isSameDay(date1, date3), isFalse);
    });

    test('startOfDay retorna inicio del día', () {
      final date = DateTime(2023, 5, 15, 14, 30);
      final startDay = DateTimeHelper.startOfDay(date);

      expect(startDay, DateTime(2023, 5, 15));
      expect(startDay.hour, 0);
      expect(startDay.minute, 0);
      expect(startDay.second, 0);
    });

    test('endOfDay retorna final del día', () {
      final date = DateTime(2023, 5, 15, 14, 30);
      final endDay = DateTimeHelper.endOfDay(date);

      expect(endDay, DateTime(2023, 5, 15, 23, 59, 59));
    });

    test('startOfWeek retorna inicio de la semana', () {
      final wednesday = DateTime(2023, 5, 17); // Miércoles
      final startWeek = DateTimeHelper.startOfWeek(wednesday);

      expect(startWeek, DateTime(2023, 5, 15)); // Lunes
    });

    test('endOfWeek retorna final de la semana', () {
      final wednesday = DateTime(2023, 5, 17); // Miércoles
      final endWeek = DateTimeHelper.endOfWeek(wednesday);

      expect(endWeek, DateTime(2023, 5, 21, 23, 59, 59)); // Domingo
    });

    test('getDaysInWeek retorna los 7 días de la semana', () {
      final date = DateTime(2023, 5, 15); // Lunes
      final days = DateTimeHelper.getDaysInWeek(date);

      expect(days.length, 7);
      expect(days[0], DateTime(2023, 5, 15)); // Lunes
      expect(days[1], DateTime(2023, 5, 16)); // Martes
      expect(days[2], DateTime(2023, 5, 17)); // Miércoles
      expect(days[3], DateTime(2023, 5, 18)); // Jueves
      expect(days[4], DateTime(2023, 5, 19)); // Viernes
      expect(days[5], DateTime(2023, 5, 20)); // Sábado
      expect(days[6], DateTime(2023, 5, 21)); // Domingo
    });

    test('getShortMonth retorna nombre abreviado del mes', () {
      expect(DateTimeHelper.getShortMonth(DateTime(2023, 1, 1)), 'Ene');
      expect(DateTimeHelper.getShortMonth(DateTime(2023, 6, 15)), 'Jun');
      expect(DateTimeHelper.getShortMonth(DateTime(2023, 12, 31)), 'Dic');
    });
  });
}
