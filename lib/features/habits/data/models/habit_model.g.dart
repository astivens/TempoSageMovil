// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'habit_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$HabitModelImpl _$$HabitModelImplFromJson(Map<String, dynamic> json) =>
    _$HabitModelImpl(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: DateTime.parse(json['endTime'] as String),
      category: json['category'] as String,
      isCompleted: json['isCompleted'] as bool,
      streak: (json['streak'] as num).toInt(),
      completedDates: (json['completedDates'] as List<dynamic>)
          .map((e) => DateTime.parse(e as String))
          .toList(),
      daysOfWeek: (json['daysOfWeek'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
      lastCompleted: json['lastCompleted'] == null
          ? null
          : DateTime.parse(json['lastCompleted'] as String),
      totalCompletions: (json['totalCompletions'] as num).toInt(),
      time: const TimeOfDayConverter().fromJson(json['time'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$HabitModelImplToJson(_$HabitModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'startTime': instance.startTime.toIso8601String(),
      'endTime': instance.endTime.toIso8601String(),
      'category': instance.category,
      'isCompleted': instance.isCompleted,
      'streak': instance.streak,
      'completedDates':
          instance.completedDates.map((e) => e.toIso8601String()).toList(),
      'daysOfWeek': instance.daysOfWeek,
      'lastCompleted': instance.lastCompleted?.toIso8601String(),
      'totalCompletions': instance.totalCompletions,
      'time': const TimeOfDayConverter().toJson(instance.time),
      'createdAt': instance.createdAt.toIso8601String(),
    };
