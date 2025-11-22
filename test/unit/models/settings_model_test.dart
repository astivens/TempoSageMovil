import 'package:flutter_test/flutter_test.dart';
import 'package:temposage/features/settings/data/models/settings_model.dart';

void main() {
  group('SettingsModel Tests', () {
    test('debería crear SettingsModel con valores por defecto', () {
      // Act
      const settings = SettingsModel();

      // Assert
      expect(settings.darkMode, isFalse);
      expect(settings.notificationsEnabled, isTrue);
      expect(settings.notificationSound, 0);
      expect(settings.vibrationEnabled, isTrue);
      expect(settings.fontSizeScale, 1);
      expect(settings.highContrastMode, isFalse);
      expect(settings.reducedAnimations, isFalse);
      expect(settings.language, 'es');
    });

    test('debería crear SettingsModel con valores personalizados', () {
      // Act
      const settings = SettingsModel(
        darkMode: true,
        notificationsEnabled: false,
        notificationSound: 2,
        vibrationEnabled: false,
        fontSizeScale: 2,
        highContrastMode: true,
        reducedAnimations: true,
        language: 'en',
      );

      // Assert
      expect(settings.darkMode, isTrue);
      expect(settings.notificationsEnabled, isFalse);
      expect(settings.notificationSound, 2);
      expect(settings.vibrationEnabled, isFalse);
      expect(settings.fontSizeScale, 2);
      expect(settings.highContrastMode, isTrue);
      expect(settings.reducedAnimations, isTrue);
      expect(settings.language, 'en');
    });

    test('copyWith debería crear una copia con valores modificados', () {
      // Arrange
      const original = SettingsModel();

      // Act
      final modified = original.copyWith(
        darkMode: true,
        language: 'en',
      );

      // Assert
      expect(modified.darkMode, isTrue);
      expect(modified.language, 'en');
      expect(modified.notificationsEnabled, original.notificationsEnabled);
      expect(modified.notificationSound, original.notificationSound);
    });

    test('copyWith debería mantener valores originales cuando no se proporcionan',
        () {
      // Arrange
      const original = SettingsModel(
        darkMode: true,
        language: 'en',
      );

      // Act
      final copy = original.copyWith();

      // Assert
      expect(copy.darkMode, original.darkMode);
      expect(copy.language, original.language);
      expect(copy.notificationsEnabled, original.notificationsEnabled);
    });
  });
}

