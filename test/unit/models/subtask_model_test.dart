import 'package:flutter_test/flutter_test.dart';
import 'package:temposage/features/tasks/data/models/subtask_model.dart';

void main() {
  group('SubtaskModel Tests', () {
    test('debería crear un SubtaskModel con todos los campos', () {
      final now = DateTime.now();
      final subtask = SubtaskModel(
        id: 'subtask-1',
        title: 'Test Subtask',
        isCompleted: false,
        parentTaskId: 'task-1',
        createdAt: now,
      );

      expect(subtask.id, equals('subtask-1'));
      expect(subtask.title, equals('Test Subtask'));
      expect(subtask.isCompleted, isFalse);
      expect(subtask.parentTaskId, equals('task-1'));
      expect(subtask.createdAt, equals(now));
      expect(subtask.completedAt, isNull);
    });

    test('debería crear un SubtaskModel completado', () {
      final now = DateTime.now();
      final completedAt = now.add(const Duration(minutes: 30));

      final subtask = SubtaskModel(
        id: 'subtask-1',
        title: 'Completed Subtask',
        isCompleted: true,
        parentTaskId: 'task-1',
        createdAt: now,
        completedAt: completedAt,
      );

      expect(subtask.isCompleted, isTrue);
      expect(subtask.completedAt, equals(completedAt));
    });

    test('debería asociar correctamente con el parentTaskId', () {
      final now = DateTime.now();
      final subtask = SubtaskModel(
        id: 'subtask-1',
        title: 'Test',
        isCompleted: false,
        parentTaskId: 'parent-task-123',
        createdAt: now,
      );

      expect(subtask.parentTaskId, equals('parent-task-123'));
    });

    test('debería crear SubtaskModel desde JSON', () {
      final now = DateTime.now();
      final json = {
        'id': 'subtask-1',
        'title': 'Test Subtask',
        'isCompleted': true,
        'parentTaskId': 'task-1',
        'createdAt': now.toIso8601String(),
        'completedAt': now.add(const Duration(minutes: 30)).toIso8601String(),
      };

      final subtask = SubtaskModel.fromJson(json);

      expect(subtask.id, equals('subtask-1'));
      expect(subtask.title, equals('Test Subtask'));
      expect(subtask.isCompleted, isTrue);
      expect(subtask.parentTaskId, equals('task-1'));
      expect(subtask.completedAt, isNotNull);
    });

    test('debería convertir SubtaskModel a JSON', () {
      final now = DateTime.now();
      final subtask = SubtaskModel(
        id: 'subtask-1',
        title: 'Test Subtask',
        isCompleted: false,
        parentTaskId: 'task-1',
        createdAt: now,
      );

      final json = subtask.toJson();

      expect(json['id'], equals('subtask-1'));
      expect(json['title'], equals('Test Subtask'));
      expect(json['isCompleted'], isFalse);
      expect(json['parentTaskId'], equals('task-1'));
    });
  });
}
