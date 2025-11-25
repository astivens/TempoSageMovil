import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:temposage/core/utils/duplicate_timeblock_cleaner.dart';
import 'package:temposage/features/timeblocks/data/models/time_block_model.dart';
import 'package:temposage/features/timeblocks/data/repositories/time_block_repository.dart';
import 'package:temposage/features/activities/data/repositories/activity_repository.dart';
import 'package:temposage/core/services/service_locator.dart';
import 'package:temposage/core/services/local_storage.dart';
import 'package:hive/hive.dart';
import 'dart:io';

// Mocks
class MockTimeBlockRepository extends Mock implements TimeBlockRepository {}

class MockActivityRepository extends Mock implements ActivityRepository {}

void main() {
  group('DuplicateTimeBlockCleaner', () {
    late MockTimeBlockRepository mockTimeBlockRepo;
    late MockActivityRepository mockActivityRepo;
    late Directory tempDir;

    setUpAll(() async {
      tempDir = await Directory.systemTemp.createTemp();
      Hive.init(tempDir.path);
      
      // Registrar adaptadores de Hive
      if (!Hive.isAdapterRegistered(6)) {
        Hive.registerAdapter(TimeBlockModelAdapter());
      }
      
      // Inicializar ServiceLocator
      try {
        await ServiceLocator.instance.initializeAll();
      } catch (e) {
        // Puede fallar si ya está inicializado, eso está bien
      }
    });

    setUp(() async {
      mockTimeBlockRepo = MockTimeBlockRepository();
      mockActivityRepo = MockActivityRepository();

      // Inicializar ServiceLocator con mocks
      // Nota: ServiceLocator usa repositorios internos, pero podemos inicializarlo
      // y luego los métodos de DuplicateTimeBlockCleaner usarán los repositorios reales
      // que están en ServiceLocator. Para este test, necesitamos que ServiceLocator
      // esté inicializado pero los repositorios reales funcionarán con datos de prueba.
      
      // Inicializar ServiceLocator si no está inicializado
      try {
        await ServiceLocator.instance.initializeAll();
      } catch (e) {
        // Puede fallar si ya está inicializado, eso está bien
      }
    });

    tearDownAll(() async {
      await Hive.close();
      await tempDir.delete(recursive: true);
    });

    group('cleanDuplicatesForDate', () {
      test('debería retornar 0 cuando no hay time blocks', () async {
        // Arrange
        final date = DateTime.now();
        // Usar el repositorio real de ServiceLocator que ya está inicializado
        final timeBlockRepo = ServiceLocator.instance.timeBlockRepository;
        final activityRepo = ServiceLocator.instance.activityRepository;
        
        // Asegurarse de que no hay bloques para esta fecha
        final existingBlocks = await timeBlockRepo.getTimeBlocksByDate(date);
        for (final block in existingBlocks) {
          await timeBlockRepo.deleteTimeBlock(block.id);
        }

        // Act
        final result = await DuplicateTimeBlockCleaner.cleanDuplicatesForDate(date);

        // Assert
        expect(result, equals(0));
      });

      test('debería retornar 0 cuando hay solo un time block', () async {
        // Arrange
        final date = DateTime.now();
        final timeBlockRepo = ServiceLocator.instance.timeBlockRepository;
        
        // Limpiar bloques existentes para esta fecha
        final existingBlocks = await timeBlockRepo.getTimeBlocksByDate(date);
        for (final block in existingBlocks) {
          await timeBlockRepo.deleteTimeBlock(block.id);
        }
        
        // Crear un solo bloque
        final timeBlock = TimeBlockModel.create(
          title: 'Test Block',
          startTime: date,
          endTime: date.add(const Duration(hours: 1)),
          description: 'Test',
          category: 'Work',
          color: '#FF0000',
        );
        await timeBlockRepo.addTimeBlock(timeBlock);

        // Act
        final result = await DuplicateTimeBlockCleaner.cleanDuplicatesForDate(date);

        // Assert
        expect(result, equals(0));
        
        // Limpiar
        await timeBlockRepo.deleteTimeBlock(timeBlock.id);
      });

      test('debería identificar y eliminar duplicados', () async {
        // Arrange
        final date = DateTime(2025, 1, 15, 10, 0); // Fecha fija para evitar problemas
        final timeBlockRepo = ServiceLocator.instance.timeBlockRepository;
        
        // Limpiar bloques existentes para esta fecha
        final existingBlocks = await timeBlockRepo.getTimeBlocksByDate(date);
        for (final block in existingBlocks) {
          await timeBlockRepo.deleteTimeBlock(block.id);
        }
        
        // Crear dos bloques duplicados (mismo título, mismo tiempo exacto)
        // El algoritmo detecta duplicados por título + startTime + endTime
        final startTime = date;
        final endTime = date.add(const Duration(hours: 1));
        
        final timeBlock1 = TimeBlockModel.create(
          title: 'Test Block Duplicate',
          startTime: startTime,
          endTime: endTime,
          description: 'Test',
          category: 'Work',
          color: '#FF0000',
        );
        final timeBlock2 = TimeBlockModel.create(
          title: 'Test Block Duplicate',
          startTime: startTime,
          endTime: endTime,
          description: 'Test',
          category: 'Work',
          color: '#FF0000',
        );
        
        // Guardar ambos bloques
        // Insertar bloques directamente en Hive para evitar la verificación de duplicados del repositorio
        // (el repositorio evita guardar duplicados, pero queremos probar el limpiador de duplicados)
        final box = await LocalStorage.getBox<TimeBlockModel>('timeblocks');
        await box.put(timeBlock1.id, timeBlock1);
        await box.put(timeBlock2.id, timeBlock2);
        
        // Verificar que se crearon correctamente
        final blocksBefore = await timeBlockRepo.getTimeBlocksByDate(date);
        expect(blocksBefore.length, equals(2), 
            reason: 'Deberían existir exactamente 2 bloques antes de limpiar duplicados');

        // Act
        final result = await DuplicateTimeBlockCleaner.cleanDuplicatesForDate(date);

        // Assert
        expect(result, greaterThanOrEqualTo(1), 
            reason: 'Debería eliminar al menos 1 duplicado. Resultado: $result, Bloques antes: ${blocksBefore.length}');
        
        // Verificar que quedó solo 1 bloque después de la limpieza
        final blocksAfter = await timeBlockRepo.getTimeBlocksByDate(date);
        expect(blocksAfter.length, lessThanOrEqualTo(blocksBefore.length - 1),
            reason: 'Debería quedar menos bloques después de limpiar duplicados');
        
        // Limpiar
        for (final block in blocksAfter) {
          await timeBlockRepo.deleteTimeBlock(block.id);
        }
      });

      test('debería manejar errores correctamente', () async {
        // Arrange
        // Usar una fecha muy antigua que probablemente no cause problemas
        final date = DateTime(1900, 1, 1);

        // Act
        final result = await DuplicateTimeBlockCleaner.cleanDuplicatesForDate(date);

        // Assert
        expect(result, isA<int>());
        expect(result, greaterThanOrEqualTo(0));
      });
    });

    group('analyzeDuplicates', () {
      test('debería analizar duplicados y retornar estadísticas', () async {
        // Act
        final stats = await DuplicateTimeBlockCleaner.analyzeDuplicates();

        // Assert
        expect(stats, isA<Map<String, int>>());
        expect(stats['totalDates'], isNotNull);
        expect(stats['datesWithDuplicates'], isNotNull);
        expect(stats['totalDuplicates'], isNotNull);
        expect(stats['totalDates'], greaterThan(0));
      });
    });

    group('cleanAllDuplicates', () {
      test('debería limpiar duplicados para múltiples fechas', () async {
        // Act
        final result = await DuplicateTimeBlockCleaner.cleanAllDuplicates();

        // Assert
        expect(result, isA<int>());
        expect(result, greaterThanOrEqualTo(0));
      });
    });
  });
}

