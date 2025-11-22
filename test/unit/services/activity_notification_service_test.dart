import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:temposage/features/activities/domain/services/activity_notification_service.dart';
import 'package:temposage/core/services/notification_service.dart';
import 'package:temposage/features/activities/data/repositories/activity_repository.dart';
import 'package:temposage/features/activities/data/models/activity_model.dart';

class MockNotificationService extends Mock implements NotificationService {}

class MockActivityRepository extends Mock implements ActivityRepository {}

void main() {
  late ActivityNotificationService service;
  late MockNotificationService mockNotificationService;
  late MockActivityRepository mockActivityRepository;

  setUpAll(() {
    registerFallbackValue(NotificationCategory.activities);
  });

  setUp(() {
    mockNotificationService = MockNotificationService();
    mockActivityRepository = MockActivityRepository();
    service = ActivityNotificationService(
      mockNotificationService,
      mockActivityRepository,
    );
  });

  group('ActivityNotificationService - scheduleActivityNotification', () {
    test('debería programar notificación cuando sendReminder es true', () async {
      final activity = ActivityModel(
        id: 'activity-1',
        title: 'Test Activity',
        description: 'Test',
        category: 'Work',
        startTime: DateTime.now().add(const Duration(hours: 2)),
        endTime: DateTime.now().add(const Duration(hours: 3)),
        sendReminder: true,
        reminderMinutesBefore: 15,
      );

      when(() => mockNotificationService.scheduleNotification(
            title: any(named: 'title'),
            body: any(named: 'body'),
            scheduledDate: any(named: 'scheduledDate'),
            category: any(named: 'category'),
            payload: any(named: 'payload'),
            id: any(named: 'id'),
          )).thenAnswer((_) async => Future.value());

      await service.scheduleActivityNotification(activity);

      verify(() => mockNotificationService.scheduleNotification(
            title: 'Recordatorio de actividad',
            body: 'Tu actividad "${activity.title}" comenzará pronto',
            scheduledDate: any(named: 'scheduledDate'),
            category: NotificationCategory.activities,
            payload: 'activity:${activity.id}',
            id: activity.id.hashCode,
          )).called(1);
    });

    test('no debería programar notificación cuando sendReminder es false',
        () async {
      final activity = ActivityModel(
        id: 'activity-1',
        title: 'Test Activity',
        description: 'Test',
        category: 'Work',
        startTime: DateTime.now().add(const Duration(hours: 2)),
        endTime: DateTime.now().add(const Duration(hours: 3)),
        sendReminder: false,
      );

      await service.scheduleActivityNotification(activity);

      verifyNever(() => mockNotificationService.scheduleNotification(
            title: any(named: 'title'),
            body: any(named: 'body'),
            scheduledDate: any(named: 'scheduledDate'),
            category: any(named: 'category'),
            payload: any(named: 'payload'),
            id: any(named: 'id'),
          ));
    });

    test('no debería programar notificación si la fecha ya pasó', () async {
      final activity = ActivityModel(
        id: 'activity-1',
        title: 'Test Activity',
        description: 'Test',
        category: 'Work',
        startTime: DateTime.now().subtract(const Duration(hours: 1)),
        endTime: DateTime.now(),
        sendReminder: true,
        reminderMinutesBefore: 15,
      );

      await service.scheduleActivityNotification(activity);

      verifyNever(() => mockNotificationService.scheduleNotification(
            title: any(named: 'title'),
            body: any(named: 'body'),
            scheduledDate: any(named: 'scheduledDate'),
            category: any(named: 'category'),
            payload: any(named: 'payload'),
            id: any(named: 'id'),
          ));
    });
  });

  group('ActivityNotificationService - scheduleAllActivityNotifications', () {
    test('debería programar notificaciones para todas las actividades con sendReminder',
        () async {
      final activities = [
        ActivityModel(
          id: 'activity-1',
          title: 'Activity 1',
          description: 'Test',
          category: 'Work',
          startTime: DateTime.now().add(const Duration(hours: 2)),
          endTime: DateTime.now().add(const Duration(hours: 3)),
          sendReminder: true,
        ),
        ActivityModel(
          id: 'activity-2',
          title: 'Activity 2',
          description: 'Test',
          category: 'Personal',
          startTime: DateTime.now().add(const Duration(hours: 4)),
          endTime: DateTime.now().add(const Duration(hours: 5)),
          sendReminder: false,
        ),
        ActivityModel(
          id: 'activity-3',
          title: 'Activity 3',
          description: 'Test',
          category: 'Study',
          startTime: DateTime.now().add(const Duration(hours: 6)),
          endTime: DateTime.now().add(const Duration(hours: 7)),
          sendReminder: true,
        ),
      ];

      when(() => mockActivityRepository.getAllActivities())
          .thenAnswer((_) async => activities);
      when(() => mockNotificationService.scheduleNotification(
            title: any(named: 'title'),
            body: any(named: 'body'),
            scheduledDate: any(named: 'scheduledDate'),
            category: any(named: 'category'),
            payload: any(named: 'payload'),
            id: any(named: 'id'),
          )).thenAnswer((_) async => Future.value());

      await service.scheduleAllActivityNotifications();

      verify(() => mockNotificationService.scheduleNotification(
            title: any(named: 'title'),
            body: any(named: 'body'),
            scheduledDate: any(named: 'scheduledDate'),
            category: any(named: 'category'),
            payload: any(named: 'payload'),
            id: any(named: 'id'),
          )).called(2);
    });
  });

  group('ActivityNotificationService - cancelActivityNotification', () {
    test('debería cancelar notificación de una actividad', () async {
      const activityId = 'activity-1';

      when(() => mockNotificationService.cancelNotification(any()))
          .thenAnswer((_) async => Future.value());

      await service.cancelActivityNotification(activityId);

      verify(() => mockNotificationService.cancelNotification(activityId.hashCode))
          .called(1);
    });
  });

  group('ActivityNotificationService - updateActivityNotification', () {
    test('debería cancelar y reprogramar notificación cuando sendReminder es true',
        () async {
      final activity = ActivityModel(
        id: 'activity-1',
        title: 'Updated Activity',
        description: 'Test',
        category: 'Work',
        startTime: DateTime.now().add(const Duration(hours: 2)),
        endTime: DateTime.now().add(const Duration(hours: 3)),
        sendReminder: true,
        reminderMinutesBefore: 15,
      );

      when(() => mockNotificationService.cancelNotification(any()))
          .thenAnswer((_) async => Future.value());
      when(() => mockNotificationService.scheduleNotification(
            title: any(named: 'title'),
            body: any(named: 'body'),
            scheduledDate: any(named: 'scheduledDate'),
            category: any(named: 'category'),
            payload: any(named: 'payload'),
            id: any(named: 'id'),
          )).thenAnswer((_) async => Future.value());

      await service.updateActivityNotification(activity);

      verify(() => mockNotificationService.cancelNotification(activity.id.hashCode))
          .called(1);
      verify(() => mockNotificationService.scheduleNotification(
            title: any(named: 'title'),
            body: any(named: 'body'),
            scheduledDate: any(named: 'scheduledDate'),
            category: any(named: 'category'),
            payload: any(named: 'payload'),
            id: any(named: 'id'),
          )).called(1);
    });

    test('solo debería cancelar notificación cuando sendReminder es false',
        () async {
      final activity = ActivityModel(
        id: 'activity-1',
        title: 'Updated Activity',
        description: 'Test',
        category: 'Work',
        startTime: DateTime.now().add(const Duration(hours: 2)),
        endTime: DateTime.now().add(const Duration(hours: 3)),
        sendReminder: false,
      );

      when(() => mockNotificationService.cancelNotification(any()))
          .thenAnswer((_) async => Future.value());

      await service.updateActivityNotification(activity);

      verify(() => mockNotificationService.cancelNotification(activity.id.hashCode))
          .called(1);
      verifyNever(() => mockNotificationService.scheduleNotification(
            title: any(named: 'title'),
            body: any(named: 'body'),
            scheduledDate: any(named: 'scheduledDate'),
            category: any(named: 'category'),
            payload: any(named: 'payload'),
            id: any(named: 'id'),
          ));
    });
  });
}

