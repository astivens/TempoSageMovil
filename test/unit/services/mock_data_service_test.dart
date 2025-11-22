import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:temposage/services/mock_data_service.dart';
import 'package:temposage/features/timeblocks/data/repositories/time_block_repository.dart';
import 'package:temposage/features/timeblocks/data/models/time_block_model.dart';

class MockTimeBlockRepository extends Mock implements TimeBlockRepository {}

void main() {
  group('MockDataService', () {
    late MockDataService service;
    late MockTimeBlockRepository mockRepository;

    setUpAll(() {
      registerFallbackValue(TimeBlockModel(
        id: 'test-id',
        title: 'Test Title',
        description: 'Test Description',
        startTime: DateTime.now(),
        endTime: DateTime.now().add(const Duration(hours: 1)),
        category: 'Test',
        isFocusTime: false,
        color: '#000000',
        isCompleted: false,
      ));
    });

    setUp(() {
      mockRepository = MockTimeBlockRepository();
      service = MockDataService(mockRepository);
    });

    group('generateMonthData', () {
      test('debería generar datos para 30 días', () async {
        // Arrange
        when(() => mockRepository.getAllTimeBlocks())
            .thenAnswer((_) async => []);
        when(() => mockRepository.deleteTimeBlock(any()))
            .thenAnswer((_) async {});
        when(() => mockRepository.addTimeBlock(any()))
            .thenAnswer((_) async {});

        // Act
        await service.generateMonthData();

        // Assert
        verify(() => mockRepository.getAllTimeBlocks()).called(1);
        verify(() => mockRepository.addTimeBlock(any())).called(greaterThan(0));
      });

      test('debería limpiar datos existentes antes de generar', () async {
        // Arrange
        final existingBlocks = [
          TimeBlockModel(
            id: '1',
            title: 'Existing',
            description: 'Test',
            startTime: DateTime.now(),
            endTime: DateTime.now().add(const Duration(hours: 1)),
            category: 'Work',
            isFocusTime: false,
            color: '#FF0000',
            isCompleted: false,
          ),
        ];
        when(() => mockRepository.getAllTimeBlocks())
            .thenAnswer((_) async => existingBlocks);
        when(() => mockRepository.deleteTimeBlock(any()))
            .thenAnswer((_) async {});
        when(() => mockRepository.addTimeBlock(any()))
            .thenAnswer((_) async {});

        // Act
        await service.generateMonthData();

        // Assert
        verify(() => mockRepository.deleteTimeBlock('1')).called(1);
      });
    });

    group('loadMockDataForML', () {
      test('debería cargar datos simulados para ML', () async {
        // Arrange
        when(() => mockRepository.getAllTimeBlocks())
            .thenAnswer((_) async => []);
        when(() => mockRepository.deleteTimeBlock(any()))
            .thenAnswer((_) async {});
        when(() => mockRepository.addTimeBlock(any()))
            .thenAnswer((_) async {});

        // Act
        await service.loadMockDataForML();

        // Assert
        verify(() => mockRepository.getAllTimeBlocks()).called(greaterThan(0));
      });

      test('debería generar bloques de tiempo con diferentes categorías', () async {
        // Arrange
        final capturedBlocks = <TimeBlockModel>[];
        when(() => mockRepository.getAllTimeBlocks())
            .thenAnswer((_) async => []);
        when(() => mockRepository.deleteTimeBlock(any()))
            .thenAnswer((_) async {});
        when(() => mockRepository.addTimeBlock(any())).thenAnswer((invocation) async {
          final block = invocation.positionalArguments[0] as TimeBlockModel;
          capturedBlocks.add(block);
        });

        // Act
        await service.generateMonthData();

        // Assert
        expect(capturedBlocks.length, greaterThan(0));
        final categories = capturedBlocks.map((b) => b.category).toSet();
        expect(categories.length, greaterThan(1));
      });
    });

    group('Generación de bloques', () {
      test('debería generar bloques con fechas correctas', () async {
        // Arrange
        final capturedBlocks = <TimeBlockModel>[];
        when(() => mockRepository.getAllTimeBlocks())
            .thenAnswer((_) async => []);
        when(() => mockRepository.deleteTimeBlock(any()))
            .thenAnswer((_) async {});
        when(() => mockRepository.addTimeBlock(any())).thenAnswer((invocation) async {
          final block = invocation.positionalArguments[0] as TimeBlockModel;
          capturedBlocks.add(block);
        });

        // Act
        await service.generateMonthData();

        // Assert
        expect(capturedBlocks.length, greaterThan(0));
        for (final block in capturedBlocks) {
          expect(block.startTime.isBefore(block.endTime), isTrue);
          expect(block.title, isNotEmpty);
          expect(block.description, isNotEmpty);
          expect(block.category, isNotEmpty);
          expect(block.color, startsWith('#'));
        }
      });

      test('debería generar bloques con duraciones razonables', () async {
        // Arrange
        final capturedBlocks = <TimeBlockModel>[];
        when(() => mockRepository.getAllTimeBlocks())
            .thenAnswer((_) async => []);
        when(() => mockRepository.deleteTimeBlock(any()))
            .thenAnswer((_) async {});
        when(() => mockRepository.addTimeBlock(any())).thenAnswer((invocation) async {
          final block = invocation.positionalArguments[0] as TimeBlockModel;
          capturedBlocks.add(block);
        });

        // Act
        await service.generateMonthData();

        // Assert
        expect(capturedBlocks.length, greaterThan(0));
        for (final block in capturedBlocks) {
          final duration = block.endTime.difference(block.startTime);
          expect(duration.inMinutes, greaterThanOrEqualTo(15));
          expect(duration.inHours, lessThanOrEqualTo(3));
        }
      });

      test('debería generar bloques con horas entre 8 AM y 10 PM', () async {
        // Arrange
        final capturedBlocks = <TimeBlockModel>[];
        when(() => mockRepository.getAllTimeBlocks())
            .thenAnswer((_) async => []);
        when(() => mockRepository.deleteTimeBlock(any()))
            .thenAnswer((_) async {});
        when(() => mockRepository.addTimeBlock(any())).thenAnswer((invocation) async {
          final block = invocation.positionalArguments[0] as TimeBlockModel;
          capturedBlocks.add(block);
        });

        // Act
        await service.generateMonthData();

        // Assert
        expect(capturedBlocks.length, greaterThan(0));
        for (final block in capturedBlocks) {
          expect(block.startTime.hour, greaterThanOrEqualTo(8));
          expect(block.startTime.hour, lessThan(22));
        }
      });
    });
  });
}

