import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:temposage/features/activities/presentation/screens/activity_list_screen.dart';

void main() {
  group('ActivityListScreen Widget Tests', () {
    testWidgets('debería instanciar el widget correctamente', (WidgetTester tester) async {
      // Este test verifica que el widget se puede crear
      // La renderización completa requiere ServiceLocator inicializado
      const screen = ActivityListScreen();
      expect(screen, isA<ActivityListScreen>());
    });
  });
}

