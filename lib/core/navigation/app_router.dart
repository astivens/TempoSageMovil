import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:temposage/features/activities/presentation/screens/activities_screen.dart';
import 'package:temposage/features/habits/presentation/screens/habits_screen.dart';
import 'package:temposage/features/timeblocks/presentation/screens/time_blocks_screen.dart';
import 'package:temposage/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:temposage/features/dashboard/presentation/screens/ml_recommendations_test_screen.dart';
import 'package:temposage/features/dashboard/presentation/screens/ml_model_diagnostic_screen.dart';
import 'package:temposage/features/chat/presentation/pages/chat_page.dart';

class AppRouter {
  static const String activities = '/activities';
  static const String timeBlocks = '/timeblocks';
  static const String habits = '/habits';
  static const String home = '/home';
  static const String testRecommendation = '/test-recommendation';
  static const String mlDiagnostic = '/ml-diagnostic';
  static const String chatAI = '/chat-ai';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(builder: (_) => const DashboardScreen());
      case activities:
        return MaterialPageRoute(builder: (_) => const ActivitiesScreen());
      case timeBlocks:
        return MaterialPageRoute(builder: (_) => const TimeBlocksScreen());
      case habits:
        return MaterialPageRoute(builder: (_) => const HabitsScreen());
      case testRecommendation:
        return MaterialPageRoute(
            builder: (_) => const MLRecommendationsTestScreen());
      case mlDiagnostic:
        if (kDebugMode) {
          return MaterialPageRoute(
              builder: (_) => const MLModelDiagnosticScreen());
        } else {
          return MaterialPageRoute(
            builder: (_) => Scaffold(
              body: Center(
                child: Text('Esta ruta solo está disponible en modo debug'),
              ),
            ),
          );
        }
      case chatAI:
        return MaterialPageRoute(builder: (_) => const ChatAIPage());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}
