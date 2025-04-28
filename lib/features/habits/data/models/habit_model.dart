import 'package:flutter/material.dart' show TimeOfDay;
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'habit_model.g.dart';

@HiveType(typeId: 9)
class TimeOfDayConverter {
  const TimeOfDayConverter();

  TimeOfDay fromJson(String json) {
    final parts = json.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  String toJson(TimeOfDay time) => '${time.hour}:${time.minute}';
}

@HiveType(typeId: 3)
class HabitModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final List<String> daysOfWeek;

  @HiveField(4)
  final String category;

  @HiveField(5)
  final String reminder;

  @HiveField(6)
  final String time;

  @HiveField(7)
  final bool isCompleted;

  @HiveField(8)
  final DateTime? lastCompleted;

  @HiveField(9)
  final int streak;

  @HiveField(10)
  final int totalCompletions;

  @HiveField(11)
  final DateTime dateCreation;

  HabitModel({
    required this.id,
    required this.title,
    required this.description,
    required this.daysOfWeek,
    required this.category,
    required this.reminder,
    required this.time,
    required this.isCompleted,
    this.lastCompleted,
    this.streak = 0,
    this.totalCompletions = 0,
    required this.dateCreation,
  });

  factory HabitModel.create({
    required String title,
    required String description,
    required List<String> daysOfWeek,
    required String category,
    required String reminder,
    required String time,
  }) {
    return HabitModel(
      id: const Uuid().v4(),
      title: title,
      description: description,
      daysOfWeek: daysOfWeek,
      category: category,
      reminder: reminder,
      time: time,
      isCompleted: false,
      dateCreation: DateTime.now(),
    );
  }

  HabitModel copyWith({
    String? id,
    String? title,
    String? description,
    List<String>? daysOfWeek,
    String? category,
    String? reminder,
    String? time,
    bool? isCompleted,
    DateTime? lastCompleted,
    int? streak,
    int? totalCompletions,
    DateTime? dateCreation,
  }) {
    return HabitModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      daysOfWeek: daysOfWeek ?? this.daysOfWeek,
      category: category ?? this.category,
      reminder: reminder ?? this.reminder,
      time: time ?? this.time,
      isCompleted: isCompleted ?? this.isCompleted,
      lastCompleted: lastCompleted ?? this.lastCompleted,
      streak: streak ?? this.streak,
      totalCompletions: totalCompletions ?? this.totalCompletions,
      dateCreation: dateCreation ?? this.dateCreation,
    );
  }
}
