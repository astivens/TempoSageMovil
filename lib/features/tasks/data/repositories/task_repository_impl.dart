import '../models/task_model.dart';
import 'task_repository.dart';

class TaskRepositoryImpl implements TaskRepository {
  final List<TaskModel> _tasks = [];

  @override
  Future<List<TaskModel>> getTasks() async {
    return _tasks;
  }

  @override
  Future<TaskModel> getTaskById(String id) async {
    return _tasks.firstWhere((task) => task.id == id);
  }

  @override
  Future<void> createTask(TaskModel task) async {
    _tasks.add(task);
  }

  @override
  Future<void> updateTask(TaskModel task) async {
    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      _tasks[index] = task;
    }
  }

  @override
  Future<void> deleteTask(String id) async {
    _tasks.removeWhere((task) => task.id == id);
  }

  @override
  Future<void> toggleTaskCompletion(String id) async {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index != -1) {
      final task = _tasks[index];
      _tasks[index] = task.copyWith(
        isCompleted: !task.isCompleted,
        completedAt: !task.isCompleted ? DateTime.now() : null,
      );
    }
  }
}
