import 'package:flutter_test/flutter_test.dart';
import 'package:temposage/core/services/event_bus.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('EventBus Integration Tests', () {
    test('should subscribe and receive events', () async {
      final eventBus = EventBus();
      String? received;
      final subscription = eventBus.events.listen((event) {
        received = event;
      });

      eventBus.emit('test_event');
      await Future.delayed(const Duration(milliseconds: 10));
      expect(received, equals('test_event'));
      await subscription.cancel();
    });

    test('should cancel subscription', () async {
      final eventBus = EventBus();
      String? received;
      final subscription = eventBus.events.listen((event) {
        received = event;
      });

      await subscription.cancel();
      eventBus.emit('test_event');
      await Future.delayed(const Duration(milliseconds: 10));
      expect(received, isNull);
    });
  });
}
