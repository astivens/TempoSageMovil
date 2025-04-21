import 'package:hive/hive.dart';

part 'time_block_model.g.dart';

@HiveType(typeId: 3)
class TimeBlockModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final DateTime startTime;

  @HiveField(4)
  final DateTime endTime;

  @HiveField(5)
  final String category;

  @HiveField(6)
  final bool isFocusTime;

  @HiveField(7)
  final String color;

  @HiveField(8)
  final bool isCompleted;

  TimeBlockModel({
    required this.id,
    required this.title,
    required this.description,
    required this.startTime,
    required this.endTime,
    required this.category,
    this.isFocusTime = false,
    required this.color,
    this.isCompleted = false,
  });

  factory TimeBlockModel.create({
    required String title,
    required String description,
    required DateTime startTime,
    required DateTime endTime,
    required String category,
    bool isFocusTime = false,
    required String color,
    bool isCompleted = false,
  }) {
    return TimeBlockModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      description: description,
      startTime: startTime,
      endTime: endTime,
      category: category,
      isFocusTime: isFocusTime,
      color: color,
      isCompleted: isCompleted,
    );
  }

  Duration get duration => endTime.difference(startTime);

  TimeBlockModel copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? startTime,
    DateTime? endTime,
    String? category,
    bool? isFocusTime,
    String? color,
    bool? isCompleted,
  }) {
    return TimeBlockModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      category: category ?? this.category,
      isFocusTime: isFocusTime ?? this.isFocusTime,
      color: color ?? this.color,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
