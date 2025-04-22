// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'time_block_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TimeBlockModelAdapter extends TypeAdapter<TimeBlockModel> {
  @override
  final int typeId = 6;

  @override
  TimeBlockModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TimeBlockModel(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String,
      startTime: fields[3] as DateTime,
      endTime: fields[4] as DateTime,
      category: fields[5] as String,
      isFocusTime: fields[6] as bool,
      color: fields[7] as String,
      isCompleted: fields[8] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, TimeBlockModel obj) {
    writer
      ..writeByte(9)
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
      ..write(obj.isFocusTime)
      ..writeByte(7)
      ..write(obj.color)
      ..writeByte(8)
      ..write(obj.isCompleted);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TimeBlockModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
