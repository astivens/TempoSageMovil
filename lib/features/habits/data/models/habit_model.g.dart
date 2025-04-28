// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'habit_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TimeOfDayConverterAdapter extends TypeAdapter<TimeOfDayConverter> {
  @override
  final int typeId = 9;

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
  final int typeId = 3;

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
      daysOfWeek: (fields[3] as List).cast<String>(),
      category: fields[4] as String,
      reminder: fields[5] as String,
      time: fields[6] as String,
      isCompleted: fields[7] as bool,
      lastCompleted: fields[8] as DateTime?,
      streak: fields[9] as int,
      totalCompletions: fields[10] as int,
      dateCreation: fields[11] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, HabitModel obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.daysOfWeek)
      ..writeByte(4)
      ..write(obj.category)
      ..writeByte(5)
      ..write(obj.reminder)
      ..writeByte(6)
      ..write(obj.time)
      ..writeByte(7)
      ..write(obj.isCompleted)
      ..writeByte(8)
      ..write(obj.lastCompleted)
      ..writeByte(9)
      ..write(obj.streak)
      ..writeByte(10)
      ..write(obj.totalCompletions)
      ..writeByte(11)
      ..write(obj.dateCreation);
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
