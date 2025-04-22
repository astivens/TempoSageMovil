import '../models/task_model.dart';

abstract class TaskRepository {
  Future<List<TaskModel>> getTasks();
  Future<TaskModel> getTaskById(String id);
  Future<void> createTask(TaskModel task);
  Future<void> updateTask(TaskModel task);
  Future<void> deleteTask(String id);
  Future<void> toggleTaskCompletion(String id);
}
