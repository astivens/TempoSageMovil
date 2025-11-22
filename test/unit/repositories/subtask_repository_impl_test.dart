import 'package:flutter_test/flutter_test.dart';
import 'package:temposage/features/tasks/data/repositories/subtask_repository_impl.dart';
import 'package:temposage/features/tasks/data/models/subtask_model.dart';

void main() {
  group('SubtaskRepositoryImpl', () {
    late SubtaskRepositoryImpl repository;

    setUp(() {
      repository = SubtaskRepositoryImpl();
    });

    group('getSubtasksForTask', () {
      test('debería retornar lista vacía cuando no hay subtareas', () async {
        // Act
        final subtasks = await repository.getSubtasksForTask('task-1');

        // Assert
        expect(subtasks, isEmpty);
      });

      test('debería retornar solo subtareas del task especificado', () async {
        // Arrange
        final subtask1 = SubtaskModel(
          id: '1',
          title: 'Subtask 1',
          isCompleted: false,
          parentTaskId: 'task-1',
          createdAt: DateTime.now(),
        );
        final subtask2 = SubtaskModel(
          id: '2',
          title: 'Subtask 2',
          isCompleted: false,
          parentTaskId: 'task-1',
          createdAt: DateTime.now(),
        );
        final subtask3 = SubtaskModel(
          id: '3',
          title: 'Subtask 3',
          isCompleted: false,
          parentTaskId: 'task-2',
          createdAt: DateTime.now(),
        );

        await repository.createSubtask(subtask1);
        await repository.createSubtask(subtask2);
        await repository.createSubtask(subtask3);

        // Act
        final subtasks = await repository.getSubtasksForTask('task-1');

        // Assert
        expect(subtasks.length, 2);
        expect(subtasks, contains(subtask1));
        expect(subtasks, contains(subtask2));
        expect(subtasks, isNot(contains(subtask3)));
      });
    });

    group('createSubtask', () {
      test('debería crear una nueva subtarea', () async {
        // Arrange
        final subtask = SubtaskModel(
          id: '1',
          title: 'New Subtask',
          isCompleted: false,
          parentTaskId: 'task-1',
          createdAt: DateTime.now(),
        );

        // Act
        await repository.createSubtask(subtask);

        // Assert
        final subtasks = await repository.getSubtasksForTask('task-1');
        expect(subtasks.length, 1);
        expect(subtasks.first.id, equals('1'));
      });
    });

    group('updateSubtask', () {
      test('debería actualizar subtarea existente', () async {
        // Arrange
        final subtask = SubtaskModel(
          id: '1',
          title: 'Original',
          isCompleted: false,
          parentTaskId: 'task-1',
          createdAt: DateTime.now(),
        );
        await repository.createSubtask(subtask);

        final updatedSubtask = subtask.copyWith(title: 'Updated');

        // Act
        await repository.updateSubtask(updatedSubtask);

        // Assert
        final subtasks = await repository.getSubtasksForTask('task-1');
        expect(subtasks.first.title, equals('Updated'));
      });

      test('debería no hacer nada si la subtarea no existe', () async {
        // Arrange
        final subtask = SubtaskModel(
          id: 'non-existent',
          title: 'Test',
          isCompleted: false,
          parentTaskId: 'task-1',
          createdAt: DateTime.now(),
        );

        // Act
        await repository.updateSubtask(subtask);

        // Assert
        final subtasks = await repository.getSubtasksForTask('task-1');
        expect(subtasks, isEmpty);
      });
    });

    group('deleteSubtask', () {
      test('debería eliminar subtarea por ID', () async {
        // Arrange
        final subtask = SubtaskModel(
          id: '1',
          title: 'Subtask to delete',
          isCompleted: false,
          parentTaskId: 'task-1',
          createdAt: DateTime.now(),
        );
        await repository.createSubtask(subtask);

        // Act
        await repository.deleteSubtask('1');

        // Assert
        final subtasks = await repository.getSubtasksForTask('task-1');
        expect(subtasks, isEmpty);
      });

      test('debería no hacer nada si la subtarea no existe', () async {
        // Act
        await repository.deleteSubtask('non-existent');

        // Assert
        final subtasks = await repository.getSubtasksForTask('task-1');
        expect(subtasks, isEmpty);
      });
    });

    group('toggleSubtaskCompletion', () {
      test('debería cambiar isCompleted de false a true', () async {
        // Arrange
        final subtask = SubtaskModel(
          id: '1',
          title: 'Subtask',
          isCompleted: false,
          parentTaskId: 'task-1',
          createdAt: DateTime.now(),
        );
        await repository.createSubtask(subtask);

        // Act
        await repository.toggleSubtaskCompletion('1');

        // Assert
        final subtasks = await repository.getSubtasksForTask('task-1');
        expect(subtasks.first.isCompleted, isTrue);
        expect(subtasks.first.completedAt, isNotNull);
      });

      test('debería cambiar isCompleted de true a false', () async {
        // Arrange
        final subtask = SubtaskModel(
          id: '1',
          title: 'Subtask',
          isCompleted: true,
          parentTaskId: 'task-1',
          createdAt: DateTime.now(),
          completedAt: DateTime.now(),
        );
        await repository.createSubtask(subtask);

        // Act
        await repository.toggleSubtaskCompletion('1');

        // Assert
        final subtasks = await repository.getSubtasksForTask('task-1');
        expect(subtasks.first.isCompleted, isFalse);
        expect(subtasks.first.completedAt, isNull);
      });

      test('debería no hacer nada si la subtarea no existe', () async {
        // Act
        await repository.toggleSubtaskCompletion('non-existent');

        // Assert
        final subtasks = await repository.getSubtasksForTask('task-1');
        expect(subtasks, isEmpty);
      });
    });
  });
}

