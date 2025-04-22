import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/models/task_model.dart';
import '../data/repositories/task_repository.dart';

class TaskCubit extends Cubit<List<TaskModel>> {
  final TaskRepository _repository;

  TaskCubit(this._repository) : super([]);

  Future<void> loadTasks() async {
    final tasks = await _repository.getTasks();
    emit(tasks);
  }

  Future<void> createTask(TaskModel task) async {
    await _repository.createTask(task);
    await loadTasks();
  }

  Future<void> updateTask(TaskModel task) async {
    await _repository.updateTask(task);
    await loadTasks();
  }

  Future<void> deleteTask(String id) async {
    await _repository.deleteTask(id);
    await loadTasks();
  }

  Future<void> toggleTaskCompletion(String id) async {
    await _repository.toggleTaskCompletion(id);
    await loadTasks();
  }
}
