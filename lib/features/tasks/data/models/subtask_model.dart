import 'package:freezed_annotation/freezed_annotation.dart';

part 'subtask_model.freezed.dart';
part 'subtask_model.g.dart';

@freezed
class SubtaskModel with _$SubtaskModel {
  const factory SubtaskModel({
    required String id,
    required String title,
    required bool isCompleted,
    required String parentTaskId,
    required DateTime createdAt,
    DateTime? completedAt,
  }) = _SubtaskModel;

  factory SubtaskModel.fromJson(Map<String, dynamic> json) =>
      _$SubtaskModelFromJson(json);
}
