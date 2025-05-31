import 'package:flutter_test/flutter_test.dart';
import 'package:temposage/services/activity_recommendation_controller.dart';
import 'package:hive/hive.dart';
import 'dart:io';
import 'package:temposage/features/auth/data/models/user_model.dart';
import 'package:temposage/features/activities/data/models/activity_model_adapter.dart';
import 'package:temposage/features/timeblocks/data/models/time_block_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    final dir = await Directory.systemTemp.createTemp();
    Hive.init(dir.path);
    Hive.registerAdapter(UserModelAdapter());
    Hive.registerAdapter(ActivityModelAdapter());
    Hive.registerAdapter(TimeBlockModelAdapter());
    // Agrega aquí otros adapters si los necesitas
  });
  group('ActivityRecommendationController', () {
    late ActivityRecommendationController controller;

    setUp(() {
      controller = ActivityRecommendationController();
    });

    test('should initialize and set model as initialized', () async {
      await controller.initialize();
      expect(controller.isModelInitialized, true);
      expect(controller.isLoading, false);
    });

    test('should generate recommendations', () async {
      await controller.initialize();
      await controller.getRecommendations();
      expect(controller.recommendations, isA<List<String>>());
      expect(controller.isLoading, false);
    });

    test('should create activity from recommendation', () async {
      await controller.initialize();
      final activity = await controller
          .createActivityFromRecommendation('Ejercicio matutino');
      expect(activity, isNotNull);
    });
  });
}
