// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'habit.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$HabitImpl _$$HabitImplFromJson(Map<String, dynamic> json) => _$HabitImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      daysOfWeek: (json['daysOfWeek'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      category: json['category'] as String,
      reminder: json['reminder'] as String,
      time: json['time'] as String,
      isDone: json['isDone'] as bool,
      dateCreation: DateTime.parse(json['dateCreation'] as String),
    );

Map<String, dynamic> _$$HabitImplToJson(_$HabitImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'daysOfWeek': instance.daysOfWeek,
      'category': instance.category,
      'reminder': instance.reminder,
      'time': instance.time,
      'isDone': instance.isDone,
      'dateCreation': instance.dateCreation.toIso8601String(),
    };
