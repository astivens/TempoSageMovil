import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:temposage/features/settings/presentation/providers/settings_provider.dart';
import 'package:temposage/features/settings/data/services/settings_service.dart';
import 'package:temposage/features/settings/data/models/settings_model.dart';

class MockSettingsService extends Mock implements SettingsService {}

void main() {
  setUpAll(() {
    registerFallbackValue(const SettingsModel());
  });

  group('SettingsProvider Tests', () {
    late MockSettingsService mockSettingsService;
    late SettingsProvider settingsProvider;

    setUp(() {
      mockSettingsService = MockSettingsService();
      when(() => mockSettingsService.settings).thenReturn(const SettingsModel());
      settingsProvider = SettingsProvider(mockSettingsService);
    });

    test('debería inicializar con settings del servicio', () {
      expect(settingsProvider.settings, isA<SettingsModel>());
    });

    test('debería alternar modo oscuro', () async {
      when(() => mockSettingsService.updateSettings(any())).thenAnswer((_) async {});

      await settingsProvider.toggleDarkMode(true);

      verify(() => mockSettingsService.updateSettings(any())).called(1);
      expect(settingsProvider.settings.darkMode, isTrue);
    });

    test('debería alternar notificaciones', () async {
      when(() => mockSettingsService.updateSettings(any())).thenAnswer((_) async {});

      await settingsProvider.toggleNotifications(false);

      verify(() => mockSettingsService.updateSettings(any())).called(1);
      expect(settingsProvider.settings.notificationsEnabled, isFalse);
    });

    test('debería alternar vibración', () async {
      when(() => mockSettingsService.updateSettings(any())).thenAnswer((_) async {});

      await settingsProvider.toggleVibration(true);

      verify(() => mockSettingsService.updateSettings(any())).called(1);
      expect(settingsProvider.settings.vibrationEnabled, isTrue);
    });

    test('debería actualizar tamaño de fuente', () async {
      when(() => mockSettingsService.updateSettings(any())).thenAnswer((_) async {});

      await settingsProvider.updateFontSize(3);

      verify(() => mockSettingsService.updateSettings(any())).called(1);
      expect(settingsProvider.settings.fontSizeScale, equals(3));
    });

    test('debería alternar modo de alto contraste', () async {
      when(() => mockSettingsService.updateSettings(any())).thenAnswer((_) async {});

      await settingsProvider.toggleHighContrast(true);

      verify(() => mockSettingsService.updateSettings(any())).called(1);
      expect(settingsProvider.settings.highContrastMode, isTrue);
    });

    test('debería alternar animaciones reducidas', () async {
      when(() => mockSettingsService.updateSettings(any())).thenAnswer((_) async {});

      await settingsProvider.toggleReducedAnimations(true);

      verify(() => mockSettingsService.updateSettings(any())).called(1);
      expect(settingsProvider.settings.reducedAnimations, isTrue);
    });

    test('debería actualizar idioma', () async {
      when(() => mockSettingsService.updateSettings(any())).thenAnswer((_) async {});

      await settingsProvider.updateLanguage('en');

      verify(() => mockSettingsService.updateSettings(any())).called(1);
      expect(settingsProvider.settings.language, equals('en'));
    });

    test('debería notificar a los listeners cuando se actualiza', () async {
      when(() => mockSettingsService.updateSettings(any())).thenAnswer((_) async {});
      
      bool notified = false;
      settingsProvider.addListener(() {
        notified = true;
      });

      await settingsProvider.toggleDarkMode(true);

      expect(notified, isTrue);
    });
  });
}

