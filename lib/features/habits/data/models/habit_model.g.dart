// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'habit_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TimeOfDayConverterAdapter extends TypeAdapter<TimeOfDayConverter> {
  @override
  final int typeId = 3;

  @override
  TimeOfDayConverter read(BinaryReader reader) {
    return TimeOfDayConverter();
  }

  @override
  void write(BinaryWriter writer, TimeOfDayConverter obj) {
    writer.writeByte(0);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TimeOfDayConverterAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class HabitModelAdapter extends TypeAdapter<HabitModel> {
  @override
  final int typeId = 5;

  @override
  HabitModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HabitModel(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String,
      startTime: fields[3] as DateTime,
      endTime: fields[4] as DateTime,
      category: fields[5] as String,
      isCompleted: fields[6] as bool,
      streak: fields[7] as int,
      completedDates: (fields[8] as List).cast<DateTime>(),
      daysOfWeek: (fields[9] as List).cast<int>(),
      lastCompleted: fields[10] as DateTime?,
      totalCompletions: fields[11] as int,
      time: fields[12] as TimeOfDay,
      createdAt: fields[13] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, HabitModel obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.startTime)
      ..writeByte(4)
      ..write(obj.endTime)
      ..writeByte(5)
      ..write(obj.category)
      ..writeByte(6)
      ..write(obj.isCompleted)
      ..writeByte(7)
      ..write(obj.streak)
      ..writeByte(8)
      ..write(obj.completedDates)
      ..writeByte(9)
      ..write(obj.daysOfWeek)
      ..writeByte(10)
      ..write(obj.lastCompleted)
      ..writeByte(11)
      ..write(obj.totalCompletions)
      ..writeByte(12)
      ..write(obj.time)
      ..writeByte(13)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HabitModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

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
