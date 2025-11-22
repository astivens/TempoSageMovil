import 'package:flutter_test/flutter_test.dart';
import 'package:temposage/core/utils/helpers/date_formatter.dart';

void main() {
  group('DateFormatter - formatDate', () {
    test('debería formatear fecha en formato dd/MM/yyyy', () {
      final date = DateTime(2023, 5, 15);
      final formatted = DateFormatter.formatDate(date);
      expect(formatted, equals('15/05/2023'));
    });

    test('debería formatear fecha con día y mes de un solo dígito', () {
      final date = DateTime(2023, 1, 5);
      final formatted = DateFormatter.formatDate(date);
      expect(formatted, equals('05/01/2023'));
    });

    test('debería formatear fecha con año diferente', () {
      final date = DateTime(2024, 12, 31);
      final formatted = DateFormatter.formatDate(date);
      expect(formatted, equals('31/12/2024'));
    });
  });

  group('DateFormatter - formatTime', () {
    test('debería formatear hora en formato HH:mm', () {
      final time = DateTime(2023, 5, 15, 14, 30);
      final formatted = DateFormatter.formatTime(time);
      expect(formatted, equals('14:30'));
    });

    test('debería formatear hora con minutos de un solo dígito', () {
      final time = DateTime(2023, 5, 15, 9, 5);
      final formatted = DateFormatter.formatTime(time);
      expect(formatted, equals('09:05'));
    });

    test('debería formatear hora con hora de un solo dígito', () {
      final time = DateTime(2023, 5, 15, 5, 30);
      final formatted = DateFormatter.formatTime(time);
      expect(formatted, equals('05:30'));
    });
  });

  group('DateFormatter - formatDateTime', () {
    test('debería formatear fecha y hora en formato dd/MM/yyyy HH:mm', () {
      final dateTime = DateTime(2023, 5, 15, 14, 30);
      final formatted = DateFormatter.formatDateTime(dateTime);
      expect(formatted, equals('15/05/2023 14:30'));
    });

    test('debería formatear fecha y hora con valores de un solo dígito', () {
      final dateTime = DateTime(2023, 1, 5, 9, 5);
      final formatted = DateFormatter.formatDateTime(dateTime);
      expect(formatted, equals('05/01/2023 09:05'));
    });
  });

  group('DateFormatter - formatRelativeTime', () {
    test('debería retornar "Just now" para tiempo muy reciente', () {
      final dateTime = DateTime.now().subtract(const Duration(seconds: 30));
      final formatted = DateFormatter.formatRelativeTime(dateTime);
      expect(formatted, equals('Just now'));
    });

    test('debería retornar minutos cuando la diferencia es menor a una hora',
        () {
      final dateTime = DateTime.now().subtract(const Duration(minutes: 30));
      final formatted = DateFormatter.formatRelativeTime(dateTime);
      expect(formatted, contains('minutes ago'));
    });

    test('debería retornar horas cuando la diferencia es menor a un día', () {
      final dateTime = DateTime.now().subtract(const Duration(hours: 5));
      final formatted = DateFormatter.formatRelativeTime(dateTime);
      expect(formatted, contains('hours ago'));
      expect(formatted, contains('5'));
    });

    test('debería retornar días cuando la diferencia es mayor a un día', () {
      final dateTime = DateTime.now().subtract(const Duration(days: 3));
      final formatted = DateFormatter.formatRelativeTime(dateTime);
      expect(formatted, contains('days ago'));
      expect(formatted, contains('3'));
    });

    test('debería manejar correctamente diferencias de tiempo exactas', () {
      final dateTime = DateTime.now().subtract(const Duration(hours: 1));
      final formatted = DateFormatter.formatRelativeTime(dateTime);
      expect(formatted, contains('hours ago'));
    });
  });
}

