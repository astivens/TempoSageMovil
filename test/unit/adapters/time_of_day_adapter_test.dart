import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:hive/hive.dart';
import 'package:temposage/features/habits/data/models/time_of_day_adapter.dart';

class MockBinaryReader extends Mock implements BinaryReader {}
class MockBinaryWriter extends Mock implements BinaryWriter {}

void main() {
  group('TimeOfDayAdapter Tests', () {
    late TimeOfDayAdapter adapter;

    setUp(() {
      adapter = TimeOfDayAdapter();
    });

    test('debería tener typeId correcto', () {
      expect(adapter.typeId, equals(8));
    });

    test('debería leer TimeOfDay correctamente', () {
      final reader = MockBinaryReader();
      var callCount = 0;
      when(() => reader.readByte()).thenAnswer((_) {
        callCount++;
        return callCount == 1 ? 9 : 30;
      });

      final timeOfDay = adapter.read(reader);

      expect(timeOfDay.hour, equals(9));
      expect(timeOfDay.minute, equals(30));
    });

    test('debería escribir TimeOfDay correctamente', () {
      final writer = MockBinaryWriter();
      final timeOfDay = const TimeOfDay(hour: 14, minute: 45);

      adapter.write(writer, timeOfDay);

      verify(() => writer.writeByte(14)).called(1);
      verify(() => writer.writeByte(45)).called(1);
    });

    test('debería manejar medianoche correctamente', () {
      final writer = MockBinaryWriter();
      final timeOfDay = const TimeOfDay(hour: 0, minute: 0);

      adapter.write(writer, timeOfDay);

      verify(() => writer.writeByte(0)).called(2);
    });

    test('debería manejar hora máxima correctamente', () {
      final writer = MockBinaryWriter();
      final timeOfDay = const TimeOfDay(hour: 23, minute: 59);

      adapter.write(writer, timeOfDay);

      verify(() => writer.writeByte(23)).called(1);
      verify(() => writer.writeByte(59)).called(1);
    });
  });
}

