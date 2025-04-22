import '../models/subtask_model.dart';

abstract class SubtaskRepository {
  Future<List<SubtaskModel>> getSubtasksForTask(String taskId);
  Future<void> createSubtask(SubtaskModel subtask);
  Future<void> updateSubtask(SubtaskModel subtask);
  Future<void> deleteSubtask(String id);
  Future<void> toggleSubtaskCompletion(String id);
}
