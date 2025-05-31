import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:temposage/core/services/event_bus.dart';

void main() {
  group('EventBus Tests', () {
    late EventBus eventBus;
    late List<StreamSubscription<String>> subscriptions;

    setUp(() {
      eventBus = EventBus();
      subscriptions = [];
    });

    tearDown(() async {
      for (final subscription in subscriptions) {
        await subscription.cancel();
      }
    });

    test('should be singleton', () {
      // Arrange & Act
      final instance1 = EventBus();
      final instance2 = EventBus();

      // Assert
      expect(instance1, same(instance2));
    });

    test('should emit and receive events', () async {
      // Arrange
      const testEvent = 'test_event';
      final events = <String>[];
      final subscription = eventBus.events.listen(events.add);
      subscriptions.add(subscription);

      // Act
      eventBus.emit(testEvent);

      // Assert
      await Future.delayed(Duration.zero); // Permitir que el evento se procese
      expect(events, contains(testEvent));
    });

    test('should emit multiple events in order', () async {
      // Arrange
      const event1 = 'event1';
      const event2 = 'event2';
      const event3 = 'event3';
      final events = <String>[];
      final subscription = eventBus.events.listen(events.add);
      subscriptions.add(subscription);

      // Act
      eventBus.emit(event1);
      eventBus.emit(event2);
      eventBus.emit(event3);

      // Assert
      await Future.delayed(
          Duration.zero); // Permitir que los eventos se procesen
      expect(events, equals([event1, event2, event3]));
    });

    test('should handle multiple subscribers', () async {
      // Arrange
      const testEvent = 'test_event';
      final events1 = <String>[];
      final events2 = <String>[];
      final subscription1 = eventBus.events.listen(events1.add);
      final subscription2 = eventBus.events.listen(events2.add);
      subscriptions.addAll([subscription1, subscription2]);

      // Act
      eventBus.emit(testEvent);

      // Assert
      await Future.delayed(Duration.zero); // Permitir que el evento se procese
      expect(events1, contains(testEvent));
      expect(events2, contains(testEvent));
    });

    test('should not emit events after dispose', () async {
      // Arrange
      const testEvent = 'test_event';
      final events = <String>[];
      final subscription = eventBus.events.listen(events.add);
      subscriptions.add(subscription);

      // Act
      eventBus.dispose();
      expect(() => eventBus.emit(testEvent), throwsStateError);

      // Assert
      await Future.delayed(Duration.zero); // Permitir que el evento se procese
      expect(events, isEmpty);
    });

    test('should have correct app events constants', () {
      // Assert
      expect(AppEvents.activityCreated, equals('activity_created'));
      expect(AppEvents.habitCreated, equals('habit_created'));
      expect(AppEvents.timeBlockCreated, equals('timeblock_created'));
      expect(AppEvents.dataChanged, equals('data_changed'));
    });
  });
}
