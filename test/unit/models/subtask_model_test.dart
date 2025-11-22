import 'package:flutter_test/flutter_test.dart';
import 'package:temposage/features/tasks/data/models/subtask_model.dart';

void main() {
  group('SubtaskModel Tests', () {
    test('debería crear SubtaskModel con valores requeridos', () {
      // Act
      final subtask = SubtaskModel(
        id: '1',
        title: 'Test Subtask',
        isCompleted: false,
      );

      // Assert
      expect(subtask.id, '1');
      expect(subtask.title, 'Test Subtask');
      expect(subtask.isCompleted, isFalse);
    });

    test('debería crear SubtaskModel completado', () {
      // Act
      final subtask = SubtaskModel(
        id: '1',
        title: 'Test Subtask',
        isCompleted: true,
      );

      // Assert
      expect(subtask.isCompleted, isTrue);
    });
  });
}

