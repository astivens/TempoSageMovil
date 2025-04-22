import '../models/subtask_model.dart';
import 'subtask_repository.dart';

class SubtaskRepositoryImpl implements SubtaskRepository {
  final List<SubtaskModel> _subtasks = [];

  @override
  Future<List<SubtaskModel>> getSubtasksForTask(String taskId) async {
    return _subtasks
        .where((subtask) => subtask.parentTaskId == taskId)
        .toList();
  }

  @override
  Future<void> createSubtask(SubtaskModel subtask) async {
    _subtasks.add(subtask);
  }

  @override
  Future<void> updateSubtask(SubtaskModel subtask) async {
    final index = _subtasks.indexWhere((s) => s.id == subtask.id);
    if (index != -1) {
      _subtasks[index] = subtask;
    }
  }

  @override
  Future<void> deleteSubtask(String id) async {
    _subtasks.removeWhere((subtask) => subtask.id == id);
  }

  @override
  Future<void> toggleSubtaskCompletion(String id) async {
    final index = _subtasks.indexWhere((s) => s.id == id);
    if (index != -1) {
      final subtask = _subtasks[index];
      _subtasks[index] = subtask.copyWith(
        isCompleted: !subtask.isCompleted,
        completedAt: !subtask.isCompleted ? DateTime.now() : null,
      );
    }
  }
}
