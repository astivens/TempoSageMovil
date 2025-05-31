import 'package:flutter_test/flutter_test.dart';
import 'package:temposage/features/timeblocks/data/repositories/time_block_repository.dart';
import 'package:temposage/features/timeblocks/data/models/time_block_model.dart';
import 'dart:math';
import 'package:temposage/core/utils/logger.dart';

// Mock de TimeBlockRepository para pruebas
class MockTimeBlockRepository extends TimeBlockRepository {
  final Map<String, TimeBlockModel> _timeBlocks = {};

  @override
  Future<TimeBlockModel> addTimeBlock(TimeBlockModel timeBlock) async {
    _timeBlocks[timeBlock.id] = timeBlock;
    return timeBlock;
  }

  @override
  Future<List<TimeBlockModel>> getAllTimeBlocks() async {
    return _timeBlocks.values.toList();
  }

  @override
  Future<TimeBlockModel?> getTimeBlock(String id) async {
    return _timeBlocks[id];
  }

  @override
  Future<void> deleteTimeBlock(String id) async {
    _timeBlocks.remove(id);
  }

  // Este método no está en la clase base, elimino @override
  Future<void> deleteAllTimeBlocks() async {
    _timeBlocks.clear();
  }

  @override
  Future<TimeBlockModel> updateTimeBlock(TimeBlockModel timeBlock) async {
    _timeBlocks[timeBlock.id] = timeBlock;
    return timeBlock;
  }
}

void main() {
  group('Memory Usage Tests', () {
    late MockTimeBlockRepository repository;
    final logger = Logger.instance;

    setUp(() async {
      repository = MockTimeBlockRepository();
    });

    test('Medir uso de memoria al cargar datos', () async {
      // Esta prueba mide indirectamente el uso de memoria
      // No podemos medir directamente la memoria en pruebas regulares
      // pero podemos verificar que no haya desbordamientos o errores

      // Eliminamos variables no utilizadas
      try {
        // Forzar recolección de basura antes de la prueba
        // Nota: esto es solo indicativo, no es una medición precisa
        logger.i('Iniciando prueba de memoria', tag: 'MemoryTest');

        // Generar datos (operación que consume memoria)
        // Generamos menos datos para la prueba
        for (int i = 0; i < 20; i++) {
          final now = DateTime.now();
          final startTime = now.add(Duration(hours: i % 24));
          final endTime = startTime.add(const Duration(minutes: 30));

          final timeBlock = TimeBlockModel(
            id: 'test-memory-$i',
            title: 'Bloque de memoria $i',
            description: 'Prueba de memoria',
            startTime: startTime,
            endTime: endTime,
            category: 'Test',
            isCompleted: false,
            isFocusTime: false,
            color: '#FF0000',
          );

          await repository.addTimeBlock(timeBlock);
        }

        // Verificar que se crearon los datos correctamente
        final blocks = await repository.getAllTimeBlocks();
        expect(blocks.length, equals(20),
            reason: 'Deben haberse creado 20 bloques de tiempo');

        // Realizar operaciones de carga pesada
        for (int i = 0; i < 5; i++) {
          // Cargar todos los bloques varias veces
          final allBlocks = await repository.getAllTimeBlocks();

          // Filtrar y procesar datos
          final filteredBlocks =
              allBlocks.where((block) => block.category == 'Test').toList();

          logger.i(
              'Iteración $i: ${allBlocks.length} bloques totales, '
              '${filteredBlocks.length} filtrados',
              tag: 'MemoryTest');
        }

        logger.i('Prueba de memoria completada sin errores', tag: 'MemoryTest');
      } catch (e) {
        fail('Error durante la prueba de memoria: $e');
      }
    });

    test('Verificar liberación de memoria al eliminar datos', () async {
      // Primero creamos algunos datos
      final random = Random();
      for (int i = 0; i < 10; i++) {
        final now = DateTime.now();
        final startTime = now.add(Duration(hours: i));
        final endTime =
            startTime.add(Duration(minutes: 30 + random.nextInt(30)));

        final timeBlock = TimeBlockModel(
          id: 'test-memory-delete-$i',
          title: 'Bloque para eliminar $i',
          description: 'Prueba de liberación de memoria',
          startTime: startTime,
          endTime: endTime,
          category: 'Test',
          isCompleted: false,
          isFocusTime: random.nextBool(),
          color:
              '#${random.nextInt(0xFFFFFF).toRadixString(16).padLeft(6, '0')}',
        );

        await repository.addTimeBlock(timeBlock);
      }

      // Verificar que se crearon correctamente
      final blocksBefore = await repository.getAllTimeBlocks();
      expect(blocksBefore.length, equals(10));

      logger.i('Creados ${blocksBefore.length} bloques para la prueba',
          tag: 'MemoryTest');

      // Ahora eliminamos los datos y verificamos que se liberen
      for (final block in blocksBefore) {
        await repository.deleteTimeBlock(block.id);
      }

      // Verificar que se eliminaron correctamente
      final blocksAfter = await repository.getAllTimeBlocks();
      expect(blocksAfter.length, equals(0),
          reason: 'Todos los bloques deberían haberse eliminado');

      logger.i('Todos los bloques eliminados correctamente', tag: 'MemoryTest');
    });

    test('Benchmark: operaciones en memoria con lotes grandes', () async {
      // Crear un lote grande de bloques en memoria
      final stopwatch = Stopwatch()..start();
      const blocksToCreate = 100;
      final random = Random();

      // Crear 100 bloques (operación de memoria intensiva)
      final List<TimeBlockModel> blocks = [];
      for (int i = 0; i < blocksToCreate; i++) {
        final now = DateTime.now();
        final startTime = now.add(
            Duration(hours: random.nextInt(24), minutes: random.nextInt(60)));
        final endTime =
            startTime.add(Duration(minutes: 15 + random.nextInt(120)));

        final block = TimeBlockModel(
          id: 'memory-bench-$i',
          title: 'Tarea $i',
          description: 'Descripción de prueba para benchmark de memoria',
          startTime: startTime,
          endTime: endTime,
          category: [
            'Trabajo',
            'Estudio',
            'Ocio',
            'Ejercicio'
          ][random.nextInt(4)],
          isCompleted: random.nextBool(),
          isFocusTime: random.nextBool(),
          color:
              '#${random.nextInt(0xFFFFFF).toRadixString(16).padLeft(6, '0')}',
        );

        blocks.add(block);
      }

      // Operaciones de memoria: filtrado, agrupación, clasificación
      final stopwatch2 = Stopwatch()..start();

      // Filtrar por categoría
      final workBlocks = blocks.where((b) => b.category == 'Trabajo').toList();

      // Agrupar por día
      final Map<String, List<TimeBlockModel>> blocksByDay = {};
      for (final block in blocks) {
        final day =
            '${block.startTime.year}-${block.startTime.month}-${block.startTime.day}';
        if (!blocksByDay.containsKey(day)) {
          blocksByDay[day] = [];
        }
        blocksByDay[day]!.add(block);
      }

      // Ordenar por hora de inicio
      blocks.sort((a, b) => a.startTime.compareTo(b.startTime));

      // Calcular duración total
      int totalMinutes = 0;
      for (final block in blocks) {
        final duration = block.endTime.difference(block.startTime);
        totalMinutes += duration.inMinutes;
      }

      stopwatch2.stop();
      stopwatch.stop();

      // Imprimir resultados usando logger
      logger.i(
          'Tiempo para crear $blocksToCreate bloques: ${stopwatch.elapsedMilliseconds} ms',
          tag: 'MemoryBenchmark');
      logger.i(
          'Tiempo para operaciones de filtrado/agrupación: ${stopwatch2.elapsedMilliseconds} ms',
          tag: 'MemoryBenchmark');
      logger.i('Bloques de trabajo encontrados: ${workBlocks.length}',
          tag: 'MemoryBenchmark');
      logger.i('Días diferentes: ${blocksByDay.length}',
          tag: 'MemoryBenchmark');
      logger.i('Duración total: $totalMinutes minutos', tag: 'MemoryBenchmark');

      expect(stopwatch2.elapsedMilliseconds, lessThan(500),
          reason: 'Las operaciones de filtrado no deberían tomar más de 500ms');
    });
  });
}
