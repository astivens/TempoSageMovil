import 'package:flutter_test/flutter_test.dart';
import 'package:temposage/core/services/schedule_rule_service.dart';
import 'package:temposage/core/models/productive_block.dart';
import 'package:temposage/features/activities/data/models/activity_model_adapter.dart';
import 'package:temposage/features/habits/data/models/habit_model.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  late ScheduleRuleService service;
  late List<ProductiveBlock> top3Blocks;

  setUpAll(() async {
    final dir = await getApplicationDocumentsDirectory();
    Hive.init(dir.path);
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(ActivityModelAdapter());
    }
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(HabitModelAdapter());
    }
  });

  setUp(() {
    top3Blocks = [
      ProductiveBlock(weekday: 1, hour: 8, completionRate: 0.9),
      ProductiveBlock(weekday: 2, hour: 9, completionRate: 0.8),
    ];
    service = ScheduleRuleService();
  });

  test('should suggest a productive block', () async {
    final suggestion = await service.suggestBlock(
      productiveBlocks: top3Blocks,
      referenceDate: DateTime.now(),
    );
    expect(suggestion, isNotNull);
  });
}
