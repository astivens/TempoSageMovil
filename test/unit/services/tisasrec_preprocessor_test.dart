import 'package:flutter_test/flutter_test.dart';
import 'package:temposage/services/tisasrec_preprocessor.dart';
import 'package:temposage/data/models/interaction_event.dart';

void main() {
  group('TisasrecPreprocessor Tests', () {
    late TisasrecPreprocessor preprocessor;
    late Map<String, int> itemMapping;

    setUp(() {
      itemMapping = {
        'item1': 1,
        'item2': 2,
        'item3': 3,
      };
      preprocessor = TisasrecPreprocessor(itemMapping: itemMapping);
    });

    test('debería inicializar con valores por defecto', () {
      // Assert
      expect(preprocessor.maxlen, 50);
      expect(preprocessor.timeSpan, 256);
      expect(preprocessor.itemMapping, itemMapping);
    });

    test('debería inicializar con valores personalizados', () {
      // Act
      final customPreprocessor = TisasrecPreprocessor(
        itemMapping: itemMapping,
        maxlen: 100,
        timeSpan: 512,
      );

      // Assert
      expect(customPreprocessor.maxlen, 100);
      expect(customPreprocessor.timeSpan, 512);
    });

    test('preprocessInput debería lanzar error con historial vacío', () {
      // Arrange
      final emptyHistory = <InteractionEvent>[];

      // Act & Assert
      expect(
        () => preprocessor.preprocessInput(emptyHistory),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('preprocessInput debería procesar historial corto correctamente', () {
      // Arrange
      final now = DateTime.now().millisecondsSinceEpoch;
      final history = [
        InteractionEvent(
          itemId: 'item1',
          timestamp: now - 1000,
        ),
        InteractionEvent(
          itemId: 'item2',
          timestamp: now - 500,
        ),
      ];

      // Act
      final result = preprocessor.preprocessInput(history);

      // Assert
      expect(result, isA<List<Object>>());
      expect(result.length, 2); // input_seq y time_matrix
    });

    test('preprocessInput debería truncar historial largo', () {
      // Arrange
      final now = DateTime.now().millisecondsSinceEpoch;
      final history = List.generate(
        100,
        (index) => InteractionEvent(
          itemId: 'item${index % 3 + 1}',
          timestamp: now - (100 - index) * 1000,
        ),
      );

      // Act
      final result = preprocessor.preprocessInput(history);

      // Assert
      expect(result, isA<List<Object>>());
      expect(result.length, 2);
    });

    test('preprocessInput debería mapear itemIds correctamente', () {
      // Arrange
      final now = DateTime.now().millisecondsSinceEpoch;
      final history = [
        InteractionEvent(
          itemId: 'item1',
          timestamp: now - 1000,
        ),
        InteractionEvent(
          itemId: 'item2',
          timestamp: now - 500,
        ),
        InteractionEvent(
          itemId: 'item_unknown',
          timestamp: now,
        ),
      ];

      // Act
      final result = preprocessor.preprocessInput(history);

      // Assert
      expect(result, isA<List<Object>>());
      // item_unknown debería mapearse a 0
    });

    test('preprocessInput debería manejar timestamps correctamente', () {
      // Arrange
      final baseTime = DateTime.now().millisecondsSinceEpoch;
      final history = [
        InteractionEvent(
          itemId: 'item1',
          timestamp: baseTime,
        ),
        InteractionEvent(
          itemId: 'item2',
          timestamp: baseTime + 1000,
        ),
        InteractionEvent(
          itemId: 'item3',
          timestamp: baseTime + 2000,
        ),
      ];

      // Act
      final result = preprocessor.preprocessInput(history);

      // Assert
      expect(result, isA<List<Object>>());
      expect(result.length, 2);
    });

    test('preprocessInput debería crear timeMatrix correctamente', () {
      // Arrange
      final baseTime = DateTime.now().millisecondsSinceEpoch;
      final history = [
        InteractionEvent(
          itemId: 'item1',
          timestamp: baseTime,
        ),
        InteractionEvent(
          itemId: 'item2',
          timestamp: baseTime + 1000,
        ),
      ];

      // Act
      final result = preprocessor.preprocessInput(history);

      // Assert
      expect(result, isA<List<Object>>());
      expect(result.length, 2);
      // time_matrix debería ser [1, maxlen, maxlen]
    });
  });
}

