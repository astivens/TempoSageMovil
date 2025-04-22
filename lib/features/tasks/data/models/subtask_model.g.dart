// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subtask_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SubtaskModelImpl _$$SubtaskModelImplFromJson(Map<String, dynamic> json) =>
    _$SubtaskModelImpl(
      id: json['id'] as String,
      title: json['title'] as String,
      isCompleted: json['isCompleted'] as bool,
      parentTaskId: json['parentTaskId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      completedAt: json['completedAt'] == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
    );

Map<String, dynamic> _$$SubtaskModelImplToJson(_$SubtaskModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'isCompleted': instance.isCompleted,
      'parentTaskId': instance.parentTaskId,
      'createdAt': instance.createdAt.toIso8601String(),
      'completedAt': instance.completedAt?.toIso8601String(),
    };
