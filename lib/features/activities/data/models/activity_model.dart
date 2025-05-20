import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';

part 'activity_model.freezed.dart';
part 'activity_model.g.dart';

@freezed
abstract class ActivityModel with _$ActivityModel {
  const ActivityModel._(); // Constructor privado para métodos adicionales

  const factory ActivityModel({
    required String id,
    required String title,
    required String description,
    required String category,
    required DateTime startTime,
    required DateTime endTime,
    @Default('Media') String priority,
    @Default(true) bool sendReminder,
    @Default(15) int reminderMinutesBefore,
    @Default(false) bool isCompleted,
  }) = _ActivityModel;

  factory ActivityModel.fromJson(Map<String, dynamic> json) =>
      _$ActivityModelFromJson(json);

  // Métodos adicionales
  ActivityModel toggleCompletion() => copyWith(isCompleted: !isCompleted);
  bool get isOverdue => DateTime.now().isAfter(endTime);
  Duration get duration => endTime.difference(startTime);
  bool get isActive =>
      DateTime.now().isAfter(startTime) && DateTime.now().isBefore(endTime);
}
