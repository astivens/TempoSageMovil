import 'package:freezed_annotation/freezed_annotation.dart';

part 'habit.freezed.dart';
part 'habit.g.dart';

@freezed
class Habit with _$Habit {
  const factory Habit({
    required String id,
    required String name,
    required String description,
    required List<String> daysOfWeek,
    required String category,
    required String reminder,
    required String time,
    required bool isDone,
    required DateTime dateCreation,
  }) = _Habit;

  factory Habit.fromJson(Map<String, dynamic> json) => _$HabitFromJson(json);
}
