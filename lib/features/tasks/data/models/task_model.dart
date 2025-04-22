import 'package:freezed_annotation/freezed_annotation.dart';
import 'subtask_model.dart';

part 'task_model.freezed.dart';
part 'task_model.g.dart';

@freezed
class TaskModel with _$TaskModel {
  const factory TaskModel({
    required String id,
    required String title,
    required String description,
    required bool isCompleted,
    required DateTime createdAt,
    required List<SubtaskModel> subtasks,
    DateTime? completedAt,
  }) = _TaskModel;

  factory TaskModel.fromJson(Map<String, dynamic> json) =>
      _$TaskModelFromJson(json);
}
