import 'package:flutter_test/flutter_test.dart';
import 'package:temposage/features/tasks/data/models/task_model.dart';
import 'package:temposage/features/tasks/data/models/subtask_model.dart';

void main() {
  group('TaskModel Tests', () {
    test('debería crear TaskModel con valores requeridos', () {
      // Arrange
      final createdAt = DateTime.now();
      final subtasks = <SubtaskModel>[];

      // Act
      final task = TaskModel(
        id: '1',
        title: 'Test Task',
        description: 'Test Description',
        isCompleted: false,
        createdAt: createdAt,
        subtasks: subtasks,
      );

      // Assert
      expect(task.id, '1');
      expect(task.title, 'Test Task');
      expect(task.description, 'Test Description');
      expect(task.isCompleted, isFalse);
      expect(task.createdAt, createdAt);
      expect(task.subtasks, subtasks);
      expect(task.completedAt, isNull);
    });

    test('debería crear TaskModel con completedAt', () {
      // Arrange
      final createdAt = DateTime.now();
      final completedAt = DateTime.now().add(const Duration(hours: 1));

      // Act
      final task = TaskModel(
        id: '1',
        title: 'Test Task',
        description: 'Test Description',
        isCompleted: true,
        createdAt: createdAt,
        subtasks: [],
        completedAt: completedAt,
      );

      // Assert
      expect(task.isCompleted, isTrue);
      expect(task.completedAt, completedAt);
    });

    test('debería crear TaskModel con subtareas', () {
      // Arrange
      final subtasks = [
        SubtaskModel(
          id: '1',
          title: 'Subtask 1',
          isCompleted: false,
        ),
        SubtaskModel(
          id: '2',
          title: 'Subtask 2',
          isCompleted: true,
        ),
      ];

      // Act
      final task = TaskModel(
        id: '1',
        title: 'Test Task',
        description: 'Test Description',
        isCompleted: false,
        createdAt: DateTime.now(),
        subtasks: subtasks,
      );

      // Assert
      expect(task.subtasks.length, 2);
      expect(task.subtasks[0].title, 'Subtask 1');
      expect(task.subtasks[1].title, 'Subtask 2');
    });
  });
}

