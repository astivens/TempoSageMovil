import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:temposage/core/utils/date_time_utils.dart';

void main() {
  group('DateTimeUtils', () {
    test('formatDate devuelve fecha en formato correcto', () {
      final date = DateTime(2023, 5, 15);
      expect(DateTimeUtils.formatDate(date), equals('15/5/2023'));
    });

    test('formatLongDate devuelve fecha en formato largo correcto', () {
      final date = DateTime(2023, 5, 15); // 15 de Mayo de 2023 (Lunes)
      expect(
        DateTimeUtils.formatLongDate(date),
        equals('Lunes, 15 de Mayo de 2023'),
      );
    });

    test('getDayOfWeekES devuelve día de la semana en español', () {
      final monday = DateTime(2023, 5, 15); // Lunes
      final sunday = DateTime(2023, 5, 21); // Domingo

      expect(DateTimeUtils.getDayOfWeekES(monday), equals('Lunes'));
      expect(DateTimeUtils.getDayOfWeekES(sunday), equals('Domingo'));
    });

    test('getDayOfWeekEN devuelve día de la semana en inglés', () {
      final monday = DateTime(2023, 5, 15); // Monday
      final sunday = DateTime(2023, 5, 21); // Sunday

      expect(DateTimeUtils.getDayOfWeekEN(monday), equals('Monday'));
      expect(DateTimeUtils.getDayOfWeekEN(sunday), equals('Sunday'));
    });

    test('getMonthNameES devuelve nombre del mes en español', () {
      expect(DateTimeUtils.getMonthNameES(1), equals('Enero'));
      expect(DateTimeUtils.getMonthNameES(6), equals('Junio'));
      expect(DateTimeUtils.getMonthNameES(12), equals('Diciembre'));
    });

    test('getShortMonthES devuelve nombre abreviado del mes en español', () {
      final january = DateTime(2023, 1, 1);
      final december = DateTime(2023, 12, 31);

      expect(DateTimeUtils.getShortMonthES(january), equals('Ene'));
      expect(DateTimeUtils.getShortMonthES(december), equals('Dic'));
    });

    test('formatTime devuelve hora formateada correctamente', () {
      final morning = DateTime(2023, 5, 15, 9, 5);
      final evening = DateTime(2023, 5, 15, 21, 30);

      expect(DateTimeUtils.formatTime(morning), equals('09:05'));
      expect(DateTimeUtils.formatTime(evening), equals('21:30'));
    });

    test('isSameDay identifica correctamente días iguales y diferentes', () {
      final date1 = DateTime(2023, 5, 15, 9, 0);
      final date2 = DateTime(2023, 5, 15, 21, 0);
      final date3 = DateTime(2023, 5, 16, 9, 0);

      expect(DateTimeUtils.isSameDay(date1, date2), isTrue);
      expect(DateTimeUtils.isSameDay(date1, date3), isFalse);
    });

    test('startOfDay devuelve el inicio del día correctamente', () {
      final date = DateTime(2023, 5, 15, 14, 30);
      final startDay = DateTimeUtils.startOfDay(date);

      expect(startDay.hour, equals(0));
      expect(startDay.minute, equals(0));
      expect(startDay.second, equals(0));
      expect(startDay.day, equals(15));
      expect(startDay.month, equals(5));
      expect(startDay.year, equals(2023));
    });

    test('endOfDay devuelve el final del día correctamente', () {
      final date = DateTime(2023, 5, 15, 14, 30);
      final endDay = DateTimeUtils.endOfDay(date);

      expect(endDay.hour, equals(23));
      expect(endDay.minute, equals(59));
      expect(endDay.second, equals(59));
      expect(endDay.day, equals(15));
      expect(endDay.month, equals(5));
      expect(endDay.year, equals(2023));
    });

    test('combineDateAndTime combina fecha y hora correctamente', () {
      final date = DateTime(2023, 5, 15);
      final time = const TimeOfDay(hour: 14, minute: 30);

      final combined = DateTimeUtils.combineDateAndTime(date, time);

      expect(combined.year, equals(2023));
      expect(combined.month, equals(5));
      expect(combined.day, equals(15));
      expect(combined.hour, equals(14));
      expect(combined.minute, equals(30));
    });
  });
}
