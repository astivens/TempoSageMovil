// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ActivityModelImpl _$$ActivityModelImplFromJson(Map<String, dynamic> json) =>
    _$ActivityModelImpl(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: DateTime.parse(json['endTime'] as String),
      priority: json['priority'] as String? ?? 'Media',
      sendReminder: json['sendReminder'] as bool? ?? true,
      reminderMinutesBefore:
          (json['reminderMinutesBefore'] as num?)?.toInt() ?? 15,
      isCompleted: json['isCompleted'] as bool? ?? false,
    );

Map<String, dynamic> _$$ActivityModelImplToJson(_$ActivityModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'category': instance.category,
      'startTime': instance.startTime.toIso8601String(),
      'endTime': instance.endTime.toIso8601String(),
      'priority': instance.priority,
      'sendReminder': instance.sendReminder,
      'reminderMinutesBefore': instance.reminderMinutesBefore,
      'isCompleted': instance.isCompleted,
    };
