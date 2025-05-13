import 'package:hive/hive.dart';

part 'activity_model.g.dart';

@HiveType(typeId: 2)
class ActivityModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String description;

  @HiveField(3)
  bool isCompleted;

  @HiveField(4)
  final DateTime startTime;

  @HiveField(5)
  final DateTime endTime;

  @HiveField(6)
  final String category;

  @HiveField(7)
  final String priority;

  @HiveField(8)
  final bool sendReminder;

  @HiveField(9)
  final int reminderMinutesBefore;

  ActivityModel({
    required this.id,
    required this.title,
    required this.description,
    this.isCompleted = false,
    required this.startTime,
    required this.endTime,
    required this.category,
    required this.priority,
    this.sendReminder = false,
    this.reminderMinutesBefore = 15,
  });

  factory ActivityModel.create({
    required String title,
    required String description,
    required DateTime startTime,
    required DateTime endTime,
    required String category,
    required String priority,
    bool sendReminder = false,
    int reminderMinutesBefore = 15,
  }) {
    return ActivityModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      description: description,
      startTime: startTime,
      endTime: endTime,
      category: category,
      priority: priority,
      sendReminder: sendReminder,
      reminderMinutesBefore: reminderMinutesBefore,
    );
  }

  ActivityModel copyWith({
    String? id,
    String? title,
    String? description,
    bool? isCompleted,
    DateTime? startTime,
    DateTime? endTime,
    String? category,
    String? priority,
    bool? sendReminder,
    int? reminderMinutesBefore,
  }) {
    return ActivityModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      sendReminder: sendReminder ?? this.sendReminder,
      reminderMinutesBefore:
          reminderMinutesBefore ?? this.reminderMinutesBefore,
    );
  }
}
