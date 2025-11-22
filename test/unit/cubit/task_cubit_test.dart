import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:temposage/features/tasks/cubit/task_cubit.dart';
import 'package:temposage/features/tasks/data/repositories/task_repository.dart';
import 'package:temposage/features/tasks/data/models/task_model.dart';
import 'package:temposage/features/tasks/data/models/subtask_model.dart';

class MockTaskRepository extends Mock implements TaskRepository {}

void main() {
  group('TaskCubit', () {
    late TaskCubit cubit;
    late MockTaskRepository mockRepository;

    setUpAll(() {
      registerFallbackValue(TaskModel(
        id: '',
        title: '',
        description: '',
        isCompleted: false,
        createdAt: DateTime.now(),
        subtasks: [],
      ));
    });

    setUp(() {
      mockRepository = MockTaskRepository();
      cubit = TaskCubit(mockRepository);
    });

    tearDown(() {
      cubit.close();
    });

    test('estado inicial debería ser lista vacía', () {
      // Assert
      expect(cubit.state, isEmpty);
    });

    blocTest<TaskCubit, List<TaskModel>>(
      'loadTasks debería cargar tareas del repositorio',
      build: () {
        final task = TaskModel(
          id: '1',
          title: 'Task 1',
          description: 'Description 1',
          isCompleted: false,
          createdAt: DateTime.now(),
          subtasks: [],
        );
        when(() => mockRepository.getTasks()).thenAnswer((_) async => [task]);
        return cubit;
      },
      act: (cubit) => cubit.loadTasks(),
      verify: (cubit) {
        expect(cubit.state.length, 1);
        expect(cubit.state.first.id, equals('1'));
        expect(cubit.state.first.title, equals('Task 1'));
        verify(() => mockRepository.getTasks()).called(1);
      },
    );

    blocTest<TaskCubit, List<TaskModel>>(
      'createTask debería crear tarea y recargar lista',
      build: () {
        final task = TaskModel(
          id: '1',
          title: 'New Task',
          description: 'New Description',
          isCompleted: false,
          createdAt: DateTime.now(),
          subtasks: [],
        );
        when(() => mockRepository.createTask(any())).thenAnswer((_) async {});
        when(() => mockRepository.getTasks()).thenAnswer((_) async => [task]);
        return cubit;
      },
      act: (cubit) => cubit.createTask(
        TaskModel(
          id: '1',
          title: 'New Task',
          description: 'New Description',
          isCompleted: false,
          createdAt: DateTime.now(),
          subtasks: [],
        ),
      ),
      verify: (cubit) {
        expect(cubit.state.length, 1);
        expect(cubit.state.first.id, equals('1'));
        expect(cubit.state.first.title, equals('New Task'));
        verify(() => mockRepository.createTask(any())).called(1);
        verify(() => mockRepository.getTasks()).called(1);
      },
    );

    blocTest<TaskCubit, List<TaskModel>>(
      'updateTask debería actualizar tarea y recargar lista',
      build: () {
        final task = TaskModel(
          id: '1',
          title: 'Updated Task',
          description: 'Updated Description',
          isCompleted: false,
          createdAt: DateTime.now(),
          subtasks: [],
        );
        when(() => mockRepository.updateTask(any())).thenAnswer((_) async {});
        when(() => mockRepository.getTasks()).thenAnswer((_) async => [task]);
        return cubit;
      },
      act: (cubit) => cubit.updateTask(
        TaskModel(
          id: '1',
          title: 'Updated Task',
          description: 'Updated Description',
          isCompleted: false,
          createdAt: DateTime.now(),
          subtasks: [],
        ),
      ),
      verify: (cubit) {
        expect(cubit.state.length, 1);
        expect(cubit.state.first.title, equals('Updated Task'));
        verify(() => mockRepository.updateTask(any())).called(1);
        verify(() => mockRepository.getTasks()).called(1);
      },
    );

    blocTest<TaskCubit, List<TaskModel>>(
      'deleteTask debería eliminar tarea y recargar lista',
      build: () {
        when(() => mockRepository.deleteTask(any())).thenAnswer((_) async {});
        when(() => mockRepository.getTasks()).thenAnswer((_) async => []);
        return cubit;
      },
      act: (cubit) => cubit.deleteTask('1'),
      verify: (cubit) {
        expect(cubit.state, isEmpty);
        verify(() => mockRepository.deleteTask('1')).called(1);
        verify(() => mockRepository.getTasks()).called(1);
      },
    );

    blocTest<TaskCubit, List<TaskModel>>(
      'toggleTaskCompletion debería cambiar estado y recargar lista',
      build: () {
        final task = TaskModel(
          id: '1',
          title: 'Task',
          description: 'Description',
          isCompleted: true,
          createdAt: DateTime.now(),
          completedAt: DateTime.now(),
          subtasks: [],
        );
        when(() => mockRepository.toggleTaskCompletion(any()))
            .thenAnswer((_) async {});
        when(() => mockRepository.getTasks()).thenAnswer((_) async => [task]);
        return cubit;
      },
      act: (cubit) => cubit.toggleTaskCompletion('1'),
      verify: (cubit) {
        expect(cubit.state.length, 1);
        expect(cubit.state.first.isCompleted, isTrue);
        verify(() => mockRepository.toggleTaskCompletion('1')).called(1);
        verify(() => mockRepository.getTasks()).called(1);
      },
    );
  });
}

