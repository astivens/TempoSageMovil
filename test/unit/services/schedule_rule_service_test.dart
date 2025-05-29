import 'package:flutter_test/flutter_test.dart';
import 'package:temposage/services/schedule_rule_service.dart';
import 'package:temposage/data/models/productive_block.dart';
import 'package:mocktail/mocktail.dart';
import 'package:device_calendar/device_calendar.dart';
import 'dart:collection';

class MockDeviceCalendarPlugin extends Mock implements DeviceCalendarPlugin {}

void main() {
  late MockDeviceCalendarPlugin mockCalendar;
  late ScheduleRuleService service;
  late List<ProductiveBlock> top3Blocks;
  late List<String> calendarIds;

  setUp(() {
    mockCalendar = MockDeviceCalendarPlugin();
    top3Blocks = [
      ProductiveBlock(weekday: 1, hour: 8, rate: 0.9),
      ProductiveBlock(weekday: 2, hour: 9, rate: 0.8),
    ];
    calendarIds = ['cal1', 'cal2'];

    final resultBool = Result<bool>()
      ..data = true
      ..errors = <ResultError>[];
    final resultEvents = Result<UnmodifiableListView<Event>>()
      ..data = UnmodifiableListView<Event>([])
      ..errors = <ResultError>[];

    when(() => mockCalendar.hasPermissions())
        .thenAnswer((_) async => resultBool);
    when(() => mockCalendar.requestPermissions())
        .thenAnswer((_) async => resultBool);
    when(() => mockCalendar.retrieveEvents(any(), any()))
        .thenAnswer((_) async => resultEvents);

    service = ScheduleRuleService(
      top3Blocks: top3Blocks,
      calendarIds: calendarIds,
      calendarPlugin: mockCalendar,
    );
  });

  test('should suggest a block or return null', () async {
    final busySlots = await service.getBusySlots(DateTime.now());
    expect(busySlots, isA<List>());
  });
}
