import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:temposage/core/constants/app_animations.dart';
import 'package:temposage/core/animations/app_animations.dart' as animations;

void main() {
  group('AppAnimations (constants) Tests', () {
    test('debería tener duraciones definidas correctamente', () {
      // Assert
      expect(AppAnimations.fastest, const Duration(milliseconds: 150));
      expect(AppAnimations.fast, const Duration(milliseconds: 250));
      expect(AppAnimations.normal, const Duration(milliseconds: 350));
      expect(AppAnimations.slow, const Duration(milliseconds: 500));
      expect(AppAnimations.slower, const Duration(milliseconds: 750));
    });

    test('debería tener curvas definidas correctamente', () {
      // Assert
      expect(AppAnimations.defaultCurve, Curves.easeInOut);
      expect(AppAnimations.bouncyCurve, Curves.elasticOut);
      expect(AppAnimations.smoothCurve, Curves.easeOutCubic);
      expect(AppAnimations.sharpCurve, Curves.easeInOutQuart);
    });

    test('debería crear PageRouteBuilder con configuración correcta', () {
      // Arrange
      final page = const Scaffold(body: Text('Test'));

      // Act
      final route = AppAnimations.pageTransition(page: page);

      // Assert
      expect(route, isA<PageRouteBuilder>());
      expect(route.transitionDuration, AppAnimations.normal);
    });

    test('debería crear PageRouteBuilder con curva personalizada', () {
      // Arrange
      final page = const Scaffold(body: Text('Test'));
      final customCurve = Curves.easeIn;

      // Act
      final route = AppAnimations.pageTransition(
        page: page,
        curve: customCurve,
      );

      // Assert
      expect(route, isA<PageRouteBuilder>());
    });

    test('debería crear PageRouteBuilder con duración personalizada', () {
      // Arrange
      final page = const Scaffold(body: Text('Test'));
      final customDuration = const Duration(milliseconds: 200);

      // Act
      final route = AppAnimations.pageTransition(
        page: page,
        duration: customDuration,
      );

      // Assert
      expect(route, isA<PageRouteBuilder>());
      expect(route.transitionDuration, customDuration);
    });

    test('debería calcular intervalos escalonados correctamente', () {
      // Arrange
      const itemCount = 3;
      const startInterval = 0.0;
      const endInterval = 1.0;

      // Act
      final interval1 = AppAnimations.getStaggeredInterval(
        0,
        itemCount: itemCount,
        startInterval: startInterval,
        endInterval: endInterval,
      );
      final interval2 = AppAnimations.getStaggeredInterval(
        1,
        itemCount: itemCount,
        startInterval: startInterval,
        endInterval: endInterval,
      );
      final interval3 = AppAnimations.getStaggeredInterval(
        2,
        itemCount: itemCount,
        startInterval: startInterval,
        endInterval: endInterval,
      );

      // Assert - Verificar que los intervalos se crean correctamente
      // Evaluamos la curva en diferentes puntos para verificar el comportamiento
      expect(interval1.transform(0.0), closeTo(0.0, 0.001));
      expect(interval1.transform(0.5), greaterThan(0.0));
      expect(interval1.transform(1.0), lessThanOrEqualTo(1.0));
      expect(interval2.transform(0.0), closeTo(0.0, 0.001));
      expect(interval3.transform(1.0), closeTo(1.0, 0.001));
    });

    test('debería calcular intervalos escalonados con rangos personalizados', () {
      // Arrange
      const itemCount = 2;
      const startInterval = 0.2;
      const endInterval = 0.8;

      // Act
      final interval1 = AppAnimations.getStaggeredInterval(
        0,
        itemCount: itemCount,
        startInterval: startInterval,
        endInterval: endInterval,
      );
      final interval2 = AppAnimations.getStaggeredInterval(
        1,
        itemCount: itemCount,
        startInterval: startInterval,
        endInterval: endInterval,
      );

      // Assert - Verificar que los intervalos se crean correctamente
      // Evaluamos la curva en diferentes puntos para verificar el comportamiento
      expect(interval1.transform(0.0), closeTo(0.0, 0.001));
      expect(interval1.transform(1.0), lessThanOrEqualTo(1.0));
      expect(interval2.transform(0.0), closeTo(0.0, 0.001));
      expect(interval2.transform(1.0), lessThanOrEqualTo(1.0));
    });
  });

  group('AppAnimations (animations) Tests', () {
    late AnimationController controller;
    late TestVSync vsync;

    setUp(() {
      TestWidgetsFlutterBinding.ensureInitialized();
      vsync = TestVSync();
      controller = AnimationController(
        vsync: vsync,
        duration: const Duration(seconds: 1),
      );
    });

    tearDown(() {
      controller.dispose();
    });

    test('debería crear animación slideInFromBottom', () {
      // Act
      final animation = animations.AppAnimations.slideInFromBottom(controller);

      // Assert
      expect(animation, isA<Animation<Offset>>());
      expect(animation.value, const Offset(0, 1));
    });

    test('debería crear animación slideInFromTop', () {
      // Act
      final animation = animations.AppAnimations.slideInFromTop(controller);

      // Assert
      expect(animation, isA<Animation<Offset>>());
      expect(animation.value, const Offset(0, -1));
    });

    test('debería crear animación slideInFromLeft', () {
      // Act
      final animation = animations.AppAnimations.slideInFromLeft(controller);

      // Assert
      expect(animation, isA<Animation<Offset>>());
      expect(animation.value, const Offset(-1, 0));
    });

    test('debería crear animación slideInFromRight', () {
      // Act
      final animation = animations.AppAnimations.slideInFromRight(controller);

      // Assert
      expect(animation, isA<Animation<Offset>>());
      expect(animation.value, const Offset(1, 0));
    });

    test('debería crear animación scaleIn', () {
      // Act
      final animation = animations.AppAnimations.scaleIn(controller);

      // Assert
      expect(animation, isA<Animation<double>>());
      expect(animation.value, 0.0);
    });

    test('debería crear animación scaleOut', () {
      // Act
      final animation = animations.AppAnimations.scaleOut(controller);

      // Assert
      expect(animation, isA<Animation<double>>());
      expect(animation.value, 1.0);
    });

    test('debería crear animación rotate', () {
      // Act
      final animation = animations.AppAnimations.rotate(controller);

      // Assert
      expect(animation, isA<Animation<double>>());
      expect(animation.value, 0.0);
    });

    test('debería crear animación fadeIn', () {
      // Act
      final animation = animations.AppAnimations.fadeIn(controller);

      // Assert
      expect(animation, isA<Animation<double>>());
      expect(animation.value, 0.0);
    });

    test('debería crear animación fadeOut', () {
      // Act
      final animation = animations.AppAnimations.fadeOut(controller);

      // Assert
      expect(animation, isA<Animation<double>>());
      expect(animation.value, 1.0);
    });

    test('debería crear animación bounce', () {
      // Act
      final animation = animations.AppAnimations.bounce(controller);

      // Assert
      expect(animation, isA<Animation<double>>());
      expect(animation.value, 0.0);
    });

    test('debería crear animación pulse', () {
      // Act
      final animation = animations.AppAnimations.pulse(controller);

      // Assert
      expect(animation, isA<Animation<double>>());
      expect(animation.value, 1.0);
    });

    test('debería crear animación staggeredList', () {
      // Act
      final animation = animations.AppAnimations.staggeredList(controller, 0);

      // Assert
      expect(animation, isA<Animation<double>>());
      expect(animation.value, 0.0);
    });

    test('debería crear animación buttonPress', () {
      // Act
      final animation = animations.AppAnimations.buttonPress(controller);

      // Assert
      expect(animation, isA<Animation<double>>());
      expect(animation.value, 1.0);
    });

    test('debería crear animación cardHover', () {
      // Act
      final animation = animations.AppAnimations.cardHover(controller);

      // Assert
      expect(animation, isA<Animation<double>>());
      expect(animation.value, 1.0);
    });

    test('debería crear animación textReveal', () {
      // Act
      final animation = animations.AppAnimations.textReveal(controller);

      // Assert
      expect(animation, isA<Animation<double>>());
      expect(animation.value, 0.0);
    });

    test('debería crear animación loadingSpinner', () {
      // Act
      final animation = animations.AppAnimations.loadingSpinner(controller);

      // Assert
      expect(animation, isA<Animation<double>>());
      expect(animation.value, 0.0);
    });

    test('debería crear animación pageTransition', () {
      // Act
      final animation = animations.AppAnimations.pageTransition(controller);

      // Assert
      expect(animation, isA<Animation<double>>());
      expect(animation.value, 0.0);
    });

    test('debería crear animación notificationSlide', () {
      // Act
      final animation = animations.AppAnimations.notificationSlide(controller);

      // Assert
      expect(animation, isA<Animation<double>>());
      expect(animation.value, 0.0);
    });

    test('debería crear animación voiceWave', () {
      // Act
      final animation = animations.AppAnimations.voiceWave(controller);

      // Assert
      expect(animation, isA<Animation<double>>());
      expect(animation.value, 0.0);
    });
  });
}

class TestVSync extends TickerProvider {
  TestVSync();

  @override
  Ticker createTicker(TickerCallback onTick) {
    return Ticker(onTick);
  }
}

