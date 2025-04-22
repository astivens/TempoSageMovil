import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/material.dart' show TimeOfDay;
import 'package:hive/hive.dart';

part 'habit_model.freezed.dart';
part 'habit_model.g.dart';

@HiveType(typeId: 3)
class TimeOfDayConverter implements JsonConverter<TimeOfDay, String> {
  const TimeOfDayConverter();

  @override
  TimeOfDay fromJson(String json) {
    final parts = json.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  @override
  String toJson(TimeOfDay time) => '${time.hour}:${time.minute}';
}

@freezed
@HiveType(typeId: 5)
class HabitModel with _$HabitModel {
  @HiveField(0)
  const factory HabitModel({
    @HiveField(0) required String id,
    @HiveField(1) required String title,
    @HiveField(2) required String description,
    @HiveField(3) required DateTime startTime,
    @HiveField(4) required DateTime endTime,
    @HiveField(5) required String category,
    @HiveField(6) required bool isCompleted,
    @HiveField(7) required int streak,
    @HiveField(8) required List<DateTime> completedDates,
    @HiveField(9) required List<int> daysOfWeek,
    @HiveField(10) required DateTime? lastCompleted,
    @HiveField(11) required int totalCompletions,
    @HiveField(12) @TimeOfDayConverter() required TimeOfDay time,
    @HiveField(13) required DateTime createdAt,
  }) = _HabitModel;

  factory HabitModel.fromJson(Map<String, dynamic> json) =>
      _$HabitModelFromJson(json);
}
