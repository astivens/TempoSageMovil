import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:temposage/features/settings/data/services/settings_service.dart';
import 'package:temposage/features/settings/data/models/settings_model.dart';
import 'dart:io';

void main() {
  group('SettingsService Tests', () {
    late SettingsService settingsService;
    late Directory tempDir;

    setUpAll(() async {
      tempDir = await Directory.systemTemp.createTemp();
      Hive.init(tempDir.path);
      if (!Hive.isAdapterRegistered(4)) {
        Hive.registerAdapter(SettingsModelAdapter());
      }
    });

    setUp(() async {
      settingsService = SettingsService();
      await Hive.deleteBoxFromDisk('settings');
      await settingsService.init();
    });

    tearDown(() async {
      await Hive.deleteBoxFromDisk('settings');
    });

    tearDownAll(() async {
      await Hive.close();
      await tempDir.delete(recursive: true);
    });

    test('debería inicializar con settings por defecto', () async {
      final settings = settingsService.settings;
      expect(settings, isA<SettingsModel>());
    });

    test('debería obtener settings actuales', () async {
      final settings = settingsService.settings;
      expect(settings, isNotNull);
    });

    test('debería actualizar settings correctamente', () async {
      final newSettings = const SettingsModel(
        darkMode: true,
        notificationsEnabled: true,
        fontSizeScale: 2,
        highContrastMode: true,
        reducedAnimations: false,
        language: 'es',
      );

      await settingsService.updateSettings(newSettings);
      final updatedSettings = settingsService.settings;

      expect(updatedSettings.darkMode, isTrue);
      expect(updatedSettings.notificationsEnabled, isTrue);
      expect(updatedSettings.fontSizeScale, equals(2));
      expect(updatedSettings.highContrastMode, isTrue);
      expect(updatedSettings.reducedAnimations, isFalse);
      expect(updatedSettings.language, equals('es'));
    });

    test('debería alternar modo oscuro', () async {
      await settingsService.toggleDarkMode(true);
      expect(settingsService.settings.darkMode, isTrue);

      await settingsService.toggleDarkMode(false);
      expect(settingsService.settings.darkMode, isFalse);
    });

    test('debería alternar notificaciones', () async {
      await settingsService.toggleNotifications(true);
      expect(settingsService.settings.notificationsEnabled, isTrue);

      await settingsService.toggleNotifications(false);
      expect(settingsService.settings.notificationsEnabled, isFalse);
    });

    test('debería actualizar tamaño de fuente', () async {
      await settingsService.updateFontSize(3);
      expect(settingsService.settings.fontSizeScale, equals(3));

      await settingsService.updateFontSize(1);
      expect(settingsService.settings.fontSizeScale, equals(1));
    });

    test('debería alternar modo de alto contraste', () async {
      await settingsService.toggleHighContrast(true);
      expect(settingsService.settings.highContrastMode, isTrue);

      await settingsService.toggleHighContrast(false);
      expect(settingsService.settings.highContrastMode, isFalse);
    });

    test('debería alternar animaciones reducidas', () async {
      await settingsService.toggleReducedAnimations(true);
      expect(settingsService.settings.reducedAnimations, isTrue);

      await settingsService.toggleReducedAnimations(false);
      expect(settingsService.settings.reducedAnimations, isFalse);
    });

    test('debería actualizar idioma', () async {
      await settingsService.updateLanguage('en');
      expect(settingsService.settings.language, equals('en'));

      await settingsService.updateLanguage('es');
      expect(settingsService.settings.language, equals('es'));
    });

    test('debería mantener otras configuraciones al actualizar una sola', () async {
      final initialSettings = const SettingsModel(
        darkMode: true,
        notificationsEnabled: true,
        fontSizeScale: 2,
        language: 'es',
      );

      await settingsService.updateSettings(initialSettings);
      await settingsService.updateFontSize(3);

      final updatedSettings = settingsService.settings;
      expect(updatedSettings.fontSizeScale, equals(3));
      expect(updatedSettings.darkMode, isTrue);
      expect(updatedSettings.notificationsEnabled, isTrue);
      expect(updatedSettings.language, equals('es'));
    });
  });
}

