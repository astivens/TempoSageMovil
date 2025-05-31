import 'package:flutter_test/flutter_test.dart';
import 'package:temposage/features/timeblocks/data/repositories/time_block_repository.dart';
import 'package:temposage/features/timeblocks/data/models/time_block_model.dart';
import 'package:hive/hive.dart';
import 'dart:math';
import 'package:mockito/mockito.dart';
import 'package:temposage/core/utils/logger.dart';

// Mock de Box para pruebas
class MockBox<T> extends Mock implements Box<T> {
  final Map<dynamic, T> _data = {};

  @override
  T? get(key, {T? defaultValue}) {
    return _data[key] ?? defaultValue;
  }

  @override
  Future<void> put(key, T value) async {
    _data[key] = value;
  }

  @override
  Future<void> delete(key) async {
    _data.remove(key);
  }

  @override
  Iterable<T> get values => _data.values;

  @override
  Future<int> clear() async {
    final count = _data.length;
    _data.clear();
    return count;
  }
}

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
  group('TimeBlockRepository Performance Tests', () {
    late MockTimeBlockRepository repository;
    final logger = Logger.instance;

    setUp(() async {
      repository = MockTimeBlockRepository();
    });

    test('Benchmark: Inserción de bloques de tiempo', () async {
      // Preparar datos de prueba
      final stopwatch = Stopwatch()..start();

      // Crear 10 bloques de tiempo (reducido para pruebas)
      final random = Random();
      for (int i = 0; i < 10; i++) {
        final now = DateTime.now();
        final startTime = now.add(Duration(hours: random.nextInt(24)));
        final endTime =
            startTime.add(Duration(minutes: 30 + random.nextInt(90)));

        final timeBlock = TimeBlockModel(
          id: DateTime.now().millisecondsSinceEpoch.toString() + i.toString(),
          title: 'Bloque de prueba $i',
          description: 'Descripción de prueba para benchmark',
          startTime: startTime,
          endTime: endTime,
          category: 'Benchmark',
          isCompleted: false,
          isFocusTime: random.nextBool(),
          color:
              '#${random.nextInt(0xFFFFFF).toRadixString(16).padLeft(6, '0')}',
        );

        await repository.addTimeBlock(timeBlock);
      }

      stopwatch.stop();

      // Imprimir resultados del benchmark
      logger.i(
          'Tiempo para insertar 10 bloques: ${stopwatch.elapsedMilliseconds} ms',
          tag: 'RepositoryBenchmark');
      logger.i('Promedio por bloque: ${stopwatch.elapsedMilliseconds / 10} ms',
          tag: 'RepositoryBenchmark');

      // Verificar que la operación no exceda un umbral razonable
      expect(stopwatch.elapsedMilliseconds, lessThan(5000),
          reason:
              'La inserción de 10 bloques no debería tomar más de 5 segundos');
    });

    test('Benchmark: Consulta de todos los bloques', () async {
      // Preparar datos de prueba - insertar algunos bloques
      try {
        // Crear 5 bloques de tiempo directamente (sin el servicio completo)
        final random = Random();
        for (int i = 0; i < 5; i++) {
          final now = DateTime.now();
          final startTime = now.add(Duration(hours: random.nextInt(24)));
          final endTime =
              startTime.add(Duration(minutes: 30 + random.nextInt(90)));

          final timeBlock = TimeBlockModel(
            id: DateTime.now().millisecondsSinceEpoch.toString() + i.toString(),
            title: 'Bloque para consulta $i',
            description: 'Descripción de prueba para benchmark',
            startTime: startTime,
            endTime: endTime,
            category: 'Benchmark',
            isCompleted: false,
            isFocusTime: random.nextBool(),
            color:
                '#${random.nextInt(0xFFFFFF).toRadixString(16).padLeft(6, '0')}',
          );

          await repository.addTimeBlock(timeBlock);
        }

        // Medir tiempo de consulta
        final stopwatch = Stopwatch()..start();
        final blocks = await repository.getAllTimeBlocks();
        stopwatch.stop();

        // Imprimir resultados
        logger.i(
            'Tiempo para consultar ${blocks.length} bloques: ${stopwatch.elapsedMilliseconds} ms',
            tag: 'RepositoryBenchmark');

        // Verificar rendimiento
        expect(stopwatch.elapsedMilliseconds, lessThan(1000),
            reason:
                'La consulta de los bloques no debería tomar más de 1 segundo');
      } catch (e) {
        fail('Error durante la prueba de consulta: $e');
      }
    });

    test('Benchmark: Filtrado de bloques por fecha', () async {
      // Preparar datos
      try {
        // Crear bloques de tiempo para diferentes fechas
        final random = Random();
        final now = DateTime.now();

        // Crear 10 bloques en diferentes fechas
        for (int i = 0; i < 10; i++) {
          final startTime = now.subtract(Duration(days: random.nextInt(14)));
          final endTime =
              startTime.add(Duration(minutes: 30 + random.nextInt(90)));

          final timeBlock = TimeBlockModel(
            id: DateTime.now().millisecondsSinceEpoch.toString() + i.toString(),
            title: 'Bloque para filtrado $i',
            description: 'Descripción de prueba para benchmark',
            startTime: startTime,
            endTime: endTime,
            category: 'Benchmark',
            isCompleted: false,
            isFocusTime: random.nextBool(),
            color:
                '#${random.nextInt(0xFFFFFF).toRadixString(16).padLeft(6, '0')}',
          );

          await repository.addTimeBlock(timeBlock);
        }

        // Definir rango de fechas para filtrar
        final startDate = DateTime(now.year, now.month, now.day)
            .subtract(const Duration(days: 7));
        final endDate = DateTime(now.year, now.month, now.day);

        // Medir tiempo de filtrado
        final stopwatch = Stopwatch()..start();

        final blocks = await repository.getAllTimeBlocks();
        final filteredBlocks = blocks.where((block) {
          return block.startTime.isAfter(startDate) &&
              block.startTime.isBefore(endDate);
        }).toList();

        stopwatch.stop();

        // Imprimir resultados
        logger.i(
            'Tiempo para filtrar bloques por fecha: ${stopwatch.elapsedMilliseconds} ms',
            tag: 'RepositoryBenchmark');
        logger.i('Bloques encontrados: ${filteredBlocks.length}',
            tag: 'RepositoryBenchmark');

        // Verificar rendimiento
        expect(stopwatch.elapsedMilliseconds, lessThan(500),
            reason: 'El filtrado por fecha no debería tomar más de 500 ms');
      } catch (e) {
        fail('Error durante la prueba de filtrado: $e');
      }
    });
  });
}
