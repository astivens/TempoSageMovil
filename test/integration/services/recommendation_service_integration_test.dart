import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:temposage/core/services/recommendation_service.dart';
import 'package:temposage/features/activities/data/repositories/activity_repository.dart';
import 'package:temposage/features/activities/data/models/activity_model.dart';
import 'package:temposage/features/activities/data/models/activity_model_adapter.dart';
import 'package:temposage/features/timeblocks/data/repositories/time_block_repository.dart';
import 'package:hive/hive.dart';
import 'package:integration_test/integration_test.dart';
import 'package:temposage/features/timeblocks/data/models/time_block_model.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  late RecommendationService service;
  late ActivityRepository activityRepository;
  late Directory tempDir;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp();
    Hive.init(tempDir.path);
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(ActivityModelAdapter());
    }
    if (!Hive.isAdapterRegistered(6)) {
      Hive.registerAdapter(TimeBlockModelAdapter());
    }
  });

  setUp(() {
    activityRepository =
        ActivityRepository(timeBlockRepository: TimeBlockRepository());
    service = RecommendationService();
  });

  tearDownAll(() async {
    await Hive.close();
    await tempDir.delete(recursive: true);
  });

  test('should generate recommendations from real activity data', () async {
    final activity = ActivityModel(
      id: '1',
      title: 'Test Activity',
      description: 'Test description',
      category: 'Work',
      startTime: DateTime.now(),
      endTime: DateTime.now().add(const Duration(hours: 1)),
    );
    await activityRepository.addActivity(activity);
    final timeBlockBox = await Hive.openBox<TimeBlockModel>('timeblocks');
    await timeBlockBox.clear();
    await timeBlockBox.add(TimeBlockModel.create(
      title: 'Test Activity',
      description: 'Test block',
      startTime: DateTime.now(),
      endTime: DateTime.now().add(const Duration(hours: 1)),
      category: 'Work',
      color: '#FF0000',
    ));
    final recommendations = await service.getRecommendations();
    expect(recommendations, isA<List<dynamic>>());
    expect(recommendations.isNotEmpty, true);
  });
}
