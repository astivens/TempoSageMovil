import 'package:flutter_test/flutter_test.dart';
import 'package:temposage/features/tasks/data/models/task_model.dart';
import 'package:temposage/features/tasks/data/models/subtask_model.dart';

void main() {
  group('TaskModel Tests', () {
    test('debería crear un TaskModel con todos los campos', () {
      final now = DateTime.now();
      final task = TaskModel(
        id: 'test-task-1',
        title: 'Test Task',
        description: 'Test Description',
        isCompleted: false,
        createdAt: now,
        subtasks: [],
      );

      expect(task.id, equals('test-task-1'));
      expect(task.title, equals('Test Task'));
      expect(task.description, equals('Test Description'));
      expect(task.isCompleted, isFalse);
      expect(task.createdAt, equals(now));
      expect(task.subtasks, isEmpty);
      expect(task.completedAt, isNull);
    });

    test('debería crear un TaskModel con subtareas', () {
      final now = DateTime.now();
      final subtask = SubtaskModel(
        id: 'subtask-1',
        title: 'Subtask 1',
        isCompleted: false,
        parentTaskId: 'task-1',
        createdAt: now,
      );

      final task = TaskModel(
        id: 'task-1',
        title: 'Test Task',
        description: 'Test',
        isCompleted: false,
        createdAt: now,
        subtasks: [subtask],
      );

      expect(task.subtasks.length, equals(1));
      expect(task.subtasks.first.title, equals('Subtask 1'));
    });

    test('debería crear un TaskModel completado', () {
      final now = DateTime.now();
      final completedAt = now.add(const Duration(hours: 1));

      final task = TaskModel(
        id: 'task-1',
        title: 'Completed Task',
        description: 'Test',
        isCompleted: true,
        createdAt: now,
        subtasks: [],
        completedAt: completedAt,
      );

      expect(task.isCompleted, isTrue);
      expect(task.completedAt, equals(completedAt));
    });
  });
}
