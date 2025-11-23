import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:temposage/core/services/csv_service.dart';
import 'package:temposage/core/models/productive_block.dart';
import 'package:temposage/features/activities/data/models/activity_model_adapter.dart';
import 'package:temposage/features/habits/data/models/habit_model.dart';
import 'package:hive/hive.dart';
import 'package:integration_test/integration_test.dart';
import 'package:temposage/features/timeblocks/data/models/time_block_model.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late CSVService csvService;
  late Directory tempDir;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp();
    Hive.init(tempDir.path);
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(ActivityModelAdapter());
    }
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(HabitModelAdapter());
    }
    if (!Hive.isAdapterRegistered(6)) {
      Hive.registerAdapter(TimeBlockModelAdapter());
    }
  });

  setUp(() {
    csvService = CSVService();
  });

  tearDownAll(() async {
    await Hive.close();
    await tempDir.delete(recursive: true);
  });

  test('should load top 3 productive blocks', () async {
    final box = await Hive.openBox<TimeBlockModel>('productive_blocks');
    await box.clear();
    await box.addAll([
      TimeBlockModel.create(
        title: 'Block 1',
        description: 'Test block 1',
        startTime: DateTime.now().subtract(const Duration(hours: 2)),
        endTime: DateTime.now().subtract(const Duration(hours: 1)),
        category: 'work',
        color: '#FF0000',
      ),
      TimeBlockModel.create(
        title: 'Block 2',
        description: 'Test block 2',
        startTime: DateTime.now().subtract(const Duration(hours: 4)),
        endTime: DateTime.now().subtract(const Duration(hours: 3)),
        category: 'personal',
        color: '#00FF00',
      ),
      TimeBlockModel.create(
        title: 'Block 3',
        description: 'Test block 3',
        startTime: DateTime.now().subtract(const Duration(hours: 6)),
        endTime: DateTime.now().subtract(const Duration(hours: 5)),
        category: 'study',
        color: '#0000FF',
      ),
    ]);
    final blocks = await csvService.loadTop3Blocks();
    expect(blocks, isA<List<ProductiveBlock>>());
    expect(blocks.length, greaterThan(0));
  });

  test('should load all blocks stats', () async {
    final box = await Hive.openBox<TimeBlockModel>('productive_blocks');
    await box.clear();
    await box.addAll([
      TimeBlockModel.create(
        title: 'Block 4',
        description: 'Test block 4',
        startTime: DateTime.now().subtract(const Duration(hours: 8)),
        endTime: DateTime.now().subtract(const Duration(hours: 7)),
        category: 'work',
        color: '#FF00FF',
      ),
      TimeBlockModel.create(
        title: 'Block 5',
        description: 'Test block 5',
        startTime: DateTime.now().subtract(const Duration(hours: 10)),
        endTime: DateTime.now().subtract(const Duration(hours: 9)),
        category: 'personal',
        color: '#00FFFF',
      ),
    ]);
    final blocks = await csvService.loadAllBlocksStats();
    expect(blocks, isA<List<ProductiveBlock>>());
    expect(blocks.length, greaterThan(0));
  });
}
