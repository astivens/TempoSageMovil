import 'package:hive_flutter/hive_flutter.dart';
import '../models/settings_model.dart';

class SettingsService {
  static const String _boxName = 'settings';
  late Box<SettingsModel> _settingsBox;

  Future<void> init() async {
    _settingsBox = await Hive.openBox<SettingsModel>(_boxName);
    if (_settingsBox.isEmpty) {
      await _settingsBox.put('settings', const SettingsModel());
    }
  }

  SettingsModel get settings =>
      _settingsBox.get('settings') ?? const SettingsModel();

  Future<void> updateSettings(SettingsModel newSettings) async {
    await _settingsBox.put('settings', newSettings);
  }

  Future<void> toggleDarkMode(bool value) async {
    final currentSettings = settings;
    await updateSettings(currentSettings.copyWith(darkMode: value));
  }

  Future<void> toggleNotifications(bool value) async {
    final currentSettings = settings;
    await updateSettings(currentSettings.copyWith(notificationsEnabled: value));
  }

  Future<void> updateFontSize(int scale) async {
    final currentSettings = settings;
    await updateSettings(currentSettings.copyWith(fontSizeScale: scale));
  }

  Future<void> toggleHighContrast(bool value) async {
    final currentSettings = settings;
    await updateSettings(currentSettings.copyWith(highContrastMode: value));
  }

  Future<void> toggleReducedAnimations(bool value) async {
    final currentSettings = settings;
    await updateSettings(currentSettings.copyWith(reducedAnimations: value));
  }

  Future<void> updateLanguage(String language) async {
    final currentSettings = settings;
    await updateSettings(currentSettings.copyWith(language: language));
  }
}
