import 'package:flutter_test/flutter_test.dart';
import 'package:temposage/features/tasks/data/repositories/task_repository_impl.dart';
import 'package:temposage/features/tasks/data/models/task_model.dart';
import 'package:temposage/features/tasks/data/models/subtask_model.dart';

void main() {
  group('TaskRepositoryImpl', () {
    late TaskRepositoryImpl repository;

    setUp(() {
      repository = TaskRepositoryImpl();
    });

    group('getTasks', () {
      test('debería retornar lista vacía inicialmente', () async {
        // Act
        final tasks = await repository.getTasks();

        // Assert
        expect(tasks, isEmpty);
      });

      test('debería retornar todas las tareas', () async {
        // Arrange
        final task1 = TaskModel(
          id: '1',
          title: 'Task 1',
          description: 'Description 1',
          isCompleted: false,
          createdAt: DateTime.now(),
          subtasks: [],
        );
        final task2 = TaskModel(
          id: '2',
          title: 'Task 2',
          description: 'Description 2',
          isCompleted: true,
          createdAt: DateTime.now(),
          subtasks: [],
        );

        await repository.createTask(task1);
        await repository.createTask(task2);

        // Act
        final tasks = await repository.getTasks();

        // Assert
        expect(tasks.length, 2);
        expect(tasks, contains(task1));
        expect(tasks, contains(task2));
      });
    });

    group('getTaskById', () {
      test('debería retornar tarea por ID', () async {
        // Arrange
        final task = TaskModel(
          id: 'task-1',
          title: 'Test Task',
          description: 'Test',
          isCompleted: false,
          createdAt: DateTime.now(),
          subtasks: [],
        );
        await repository.createTask(task);

        // Act
        final result = await repository.getTaskById('task-1');

        // Assert
        expect(result.id, equals('task-1'));
        expect(result.title, equals('Test Task'));
      });

      test('debería lanzar excepción cuando no existe', () async {
        // Act & Assert
        expect(
          () => repository.getTaskById('non-existent'),
          throwsA(isA<StateError>()),
        );
      });
    });

    group('createTask', () {
      test('debería crear una nueva tarea', () async {
        // Arrange
        final task = TaskModel(
          id: '1',
          title: 'New Task',
          description: 'New Description',
          isCompleted: false,
          createdAt: DateTime.now(),
          subtasks: [],
        );

        // Act
        await repository.createTask(task);

        // Assert
        final tasks = await repository.getTasks();
        expect(tasks.length, 1);
        expect(tasks.first.id, equals('1'));
      });
    });

    group('updateTask', () {
      test('debería actualizar tarea existente', () async {
        // Arrange
        final task = TaskModel(
          id: '1',
          title: 'Original',
          description: 'Original Description',
          isCompleted: false,
          createdAt: DateTime.now(),
          subtasks: [],
        );
        await repository.createTask(task);

        final updatedTask = task.copyWith(
          title: 'Updated',
          description: 'Updated Description',
        );

        // Act
        await repository.updateTask(updatedTask);

        // Assert
        final result = await repository.getTaskById('1');
        expect(result.title, equals('Updated'));
        expect(result.description, equals('Updated Description'));
      });

      test('debería no hacer nada si la tarea no existe', () async {
        // Arrange
        final task = TaskModel(
          id: 'non-existent',
          title: 'Test',
          description: 'Test',
          isCompleted: false,
          createdAt: DateTime.now(),
          subtasks: [],
        );

        // Act
        await repository.updateTask(task);

        // Assert
        final tasks = await repository.getTasks();
        expect(tasks, isEmpty);
      });
    });

    group('deleteTask', () {
      test('debería eliminar tarea por ID', () async {
        // Arrange
        final task = TaskModel(
          id: '1',
          title: 'Task to delete',
          description: 'Test',
          isCompleted: false,
          createdAt: DateTime.now(),
          subtasks: [],
        );
        await repository.createTask(task);

        // Act
        await repository.deleteTask('1');

        // Assert
        final tasks = await repository.getTasks();
        expect(tasks, isEmpty);
      });

      test('debería no hacer nada si la tarea no existe', () async {
        // Act
        await repository.deleteTask('non-existent');

        // Assert
        final tasks = await repository.getTasks();
        expect(tasks, isEmpty);
      });
    });

    group('toggleTaskCompletion', () {
      test('debería cambiar isCompleted de false a true', () async {
        // Arrange
        final task = TaskModel(
          id: '1',
          title: 'Task',
          description: 'Test',
          isCompleted: false,
          createdAt: DateTime.now(),
          subtasks: [],
        );
        await repository.createTask(task);

        // Act
        await repository.toggleTaskCompletion('1');

        // Assert
        final result = await repository.getTaskById('1');
        expect(result.isCompleted, isTrue);
        expect(result.completedAt, isNotNull);
      });

      test('debería cambiar isCompleted de true a false', () async {
        // Arrange
        final task = TaskModel(
          id: '1',
          title: 'Task',
          description: 'Test',
          isCompleted: true,
          createdAt: DateTime.now(),
          completedAt: DateTime.now(),
          subtasks: [],
        );
        await repository.createTask(task);

        // Act
        await repository.toggleTaskCompletion('1');

        // Assert
        final result = await repository.getTaskById('1');
        expect(result.isCompleted, isFalse);
        expect(result.completedAt, isNull);
      });

      test('debería no hacer nada si la tarea no existe', () async {
        // Act
        await repository.toggleTaskCompletion('non-existent');

        // Assert
        final tasks = await repository.getTasks();
        expect(tasks, isEmpty);
      });
    });
  });
}

