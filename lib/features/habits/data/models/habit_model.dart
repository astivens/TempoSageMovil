import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/material.dart' show TimeOfDay;

part 'habit_model.freezed.dart';
part 'habit_model.g.dart';

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
class HabitModel with _$HabitModel {
  const factory HabitModel({
    required String id,
    required String title,
    required String description,
    required DateTime startTime,
    required DateTime endTime,
    required String category,
    required bool isCompleted,
    required int streak,
    required List<DateTime> completedDates,
    required List<int> daysOfWeek,
    required DateTime? lastCompleted,
    required int totalCompletions,
    @TimeOfDayConverter() required TimeOfDay time,
    required DateTime createdAt,
  }) = _HabitModel;

  factory HabitModel.fromJson(Map<String, dynamic> json) =>
      _$HabitModelFromJson(json);
}
