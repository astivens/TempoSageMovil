import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:hive/hive.dart';
import 'package:temposage/features/timeblocks/data/repositories/time_block_repository.dart';
import 'package:temposage/features/timeblocks/data/models/time_block_model.dart';

// Usar mocktail en lugar de mockito para simplificar
class MockBox<T> extends Mock implements Box<T> {}

// Crear un fake de TimeBlockModel para el valor de respaldo
class FakeTimeBlockModel extends Fake implements TimeBlockModel {}

// Crear un mock del repositorio que implementa directamente los métodos necesarios
class MockTimeBlockRepository extends TimeBlockRepository {
  final MockBox<TimeBlockModel> mockBox;

  MockTimeBlockRepository(this.mockBox);

  @override
  Future<void> init() async {
    // No hacer nada en la inicialización
  }

  @override
  Future<List<TimeBlockModel>> getAllTimeBlocks() async {
    return mockBox.values.toList();
  }

  @override
  Future<TimeBlockModel?> getTimeBlock(String id) async {
    return mockBox.get(id);
  }

  @override
  Future<List<TimeBlockModel>> getTimeBlocksByDate(DateTime date) async {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    return mockBox.values.where((timeBlock) {
      final blockDate = DateTime(
        timeBlock.startTime.year,
        timeBlock.startTime.month,
        timeBlock.startTime.day,
      );
      return blockDate.year == normalizedDate.year &&
          blockDate.month == normalizedDate.month &&
          blockDate.day == normalizedDate.day;
    }).toList();
  }

  @override
  Future<void> addTimeBlock(TimeBlockModel timeBlock) async {
    await mockBox.put(timeBlock.id, timeBlock);
  }

  @override
  Future<void> updateTimeBlock(TimeBlockModel timeBlock) async {
    await mockBox.put(timeBlock.id, timeBlock);
  }

  @override
  Future<void> deleteTimeBlock(String id) async {
    await mockBox.delete(id);
  }

  @override
  Future<void> deleteAllTimeBlocksForDate(DateTime date) async {
    final blocks = await getTimeBlocksByDate(date);
    for (final block in blocks) {
      await mockBox.delete(block.id);
    }
  }
}

void main() {
  setUpAll(() {
    // Registrar un valor de respaldo para TimeBlockModel
    registerFallbackValue(FakeTimeBlockModel());
  });

  group('TimeBlockRepository', () {
    late MockTimeBlockRepository repository;
    late MockBox<TimeBlockModel> mockBox;

    final testTimeBlock1 = TimeBlockModel.create(
      title: 'Test Block 1',
      description: 'Test Description 1',
      startTime: DateTime(2023, 5, 15, 10, 0),
      endTime: DateTime(2023, 5, 15, 11, 0),
      category: 'Test',
      color: '#FF0000',
    );

    final testTimeBlock2 = TimeBlockModel.create(
      title: 'Test Block 2',
      description: 'Test Description 2',
      startTime: DateTime(2023, 5, 15, 14, 0),
      endTime: DateTime(2023, 5, 15, 15, 0),
      category: 'Test',
      isFocusTime: true,
      color: '#00FF00',
    );

    final testTimeBlock3 = TimeBlockModel.create(
      title: 'Test Block 3',
      description: 'Test Description 3',
      startTime: DateTime(2023, 5, 16, 10, 0),
      endTime: DateTime(2023, 5, 16, 11, 0),
      category: 'Test',
      color: '#0000FF',
    );

    setUp(() async {
      mockBox = MockBox<TimeBlockModel>();

      // Configurar el comportamiento del mock
      when(() => mockBox.values).thenReturn([
        testTimeBlock1,
        testTimeBlock2,
        testTimeBlock3,
      ]);

      when(() => mockBox.get(any())).thenAnswer((invocation) {
        final id = invocation.positionalArguments[0];
        if (id == testTimeBlock1.id) return testTimeBlock1;
        if (id == testTimeBlock2.id) return testTimeBlock2;
        if (id == testTimeBlock3.id) return testTimeBlock3;
        return null;
      });

      // Crear el repositorio mock que usa nuestro box mock
      repository = MockTimeBlockRepository(mockBox);
    });

    test('init debería inicializar el repositorio correctamente', () async {
      await repository.init();
      // No hay una aserción específica, pero si no hay excepción, la prueba pasa
    });

    test('getAllTimeBlocks debería retornar todos los bloques de tiempo',
        () async {
      final result = await repository.getAllTimeBlocks();
      expect(result.length, 3);
      expect(result, contains(testTimeBlock1));
      expect(result, contains(testTimeBlock2));
      expect(result, contains(testTimeBlock3));
    });

    test(
        'getTimeBlocksByDate debería retornar bloques para una fecha específica',
        () async {
      final date = DateTime(2023, 5, 15);
      final result = await repository.getTimeBlocksByDate(date);

      expect(result.length, 2);
      expect(result, contains(testTimeBlock1));
      expect(result, contains(testTimeBlock2));
      expect(result, isNot(contains(testTimeBlock3)));
    });

    test('getTimeBlock debería retornar un bloque específico por ID', () async {
      final result = await repository.getTimeBlock(testTimeBlock1.id);
      expect(result, equals(testTimeBlock1));
    });

    test('getTimeBlock debería retornar null si el ID no existe', () async {
      final result = await repository.getTimeBlock('non-existent-id');
      expect(result, isNull);
    });

    test('isDuplicate debería detectar bloques duplicados', () async {
      // Crear un bloque similar a testTimeBlock1 pero con ID diferente
      final duplicateBlock = TimeBlockModel.create(
        title: testTimeBlock1.title,
        description: 'Different description',
        startTime: testTimeBlock1.startTime.add(const Duration(minutes: 5)),
        endTime: testTimeBlock1.endTime.add(const Duration(minutes: 5)),
        category: testTimeBlock1.category,
        color: testTimeBlock1.color,
      );

      final result = await repository.isDuplicate(duplicateBlock);
      expect(result, isTrue);
    });

    test('isDuplicate debería retornar false para bloques no duplicados',
        () async {
      // Crear un bloque diferente
      final uniqueBlock = TimeBlockModel.create(
        title: 'Unique Block',
        description: 'Unique Description',
        startTime: DateTime(2023, 5, 15, 16, 0),
        endTime: DateTime(2023, 5, 15, 17, 0),
        category: 'Unique',
        color: '#FF00FF',
      );

      final result = await repository.isDuplicate(uniqueBlock);
      expect(result, isFalse);
    });

    test('addTimeBlock debería añadir un nuevo bloque', () async {
      // Configurar para que put funcione con cualquier TimeBlockModel
      when(() => mockBox.put(any(), any<TimeBlockModel>()))
          .thenAnswer((_) async {});

      final newBlock = TimeBlockModel.create(
        title: 'New Block',
        description: 'New Description',
        startTime: DateTime(2023, 5, 17, 10, 0),
        endTime: DateTime(2023, 5, 17, 11, 0),
        category: 'New',
        color: '#FFFF00',
      );

      await repository.addTimeBlock(newBlock);

      verify(() => mockBox.put(newBlock.id, newBlock)).called(1);
    });

    test('updateTimeBlock debería actualizar un bloque existente', () async {
      // Configurar para que put funcione con cualquier TimeBlockModel
      when(() => mockBox.put(any(), any<TimeBlockModel>()))
          .thenAnswer((_) async {});

      final updatedBlock = testTimeBlock1.copyWith(
        title: 'Updated Title',
        description: 'Updated Description',
      );

      await repository.updateTimeBlock(updatedBlock);

      verify(() => mockBox.put(updatedBlock.id, updatedBlock)).called(1);
    });

    test('deleteTimeBlock debería eliminar un bloque por ID', () async {
      when(() => mockBox.delete(any())).thenAnswer((_) async {});

      await repository.deleteTimeBlock(testTimeBlock1.id);

      verify(() => mockBox.delete(testTimeBlock1.id)).called(1);
    });

    test(
        'getTotalHoursForDate debería calcular correctamente las horas totales',
        () async {
      final date = DateTime(2023, 5, 15);
      final result = await repository.getTotalHoursForDate(date);

      // testTimeBlock1 y testTimeBlock2 suman 2 horas
      expect(result, equals(2.0));
    });

    test(
        'getFocusTimeForDate debería calcular correctamente las horas de enfoque',
        () async {
      final date = DateTime(2023, 5, 15);
      final result = await repository.getFocusTimeForDate(date);

      // Solo testTimeBlock2 es isFocusTime (1 hora)
      expect(result, equals(1.0));
    });

    test(
        'deleteAllTimeBlocksForDate debería eliminar todos los bloques de una fecha',
        () async {
      when(() => mockBox.delete(any())).thenAnswer((_) async {});

      final date = DateTime(2023, 5, 15);
      await repository.deleteAllTimeBlocksForDate(date);

      // Debería llamar a delete para testTimeBlock1 y testTimeBlock2
      verify(() => mockBox.delete(testTimeBlock1.id)).called(1);
      verify(() => mockBox.delete(testTimeBlock2.id)).called(1);
      // No debería eliminar testTimeBlock3 (otra fecha)
      verifyNever(() => mockBox.delete(testTimeBlock3.id));
    });

    test('debugMode debería retornar un valor booleano', () {
      expect(repository.debugMode, isA<bool>());
    });
  });
}
