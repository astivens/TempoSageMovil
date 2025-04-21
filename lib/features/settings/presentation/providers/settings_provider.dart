import 'package:flutter/material.dart';
import '../../data/models/settings_model.dart';
import '../../data/services/settings_service.dart';

class SettingsProvider extends ChangeNotifier {
  final SettingsService _settingsService;
  SettingsModel _settings;

  SettingsProvider(this._settingsService)
      : _settings = _settingsService.settings;

  SettingsModel get settings => _settings;

  Future<void> toggleDarkMode(bool value) async {
    _settings = _settings.copyWith(darkMode: value);
    await _settingsService.updateSettings(_settings);
    notifyListeners();
  }

  Future<void> toggleNotifications(bool value) async {
    _settings = _settings.copyWith(notificationsEnabled: value);
    await _settingsService.updateSettings(_settings);
    notifyListeners();
  }

  Future<void> toggleVibration(bool value) async {
    _settings = _settings.copyWith(vibrationEnabled: value);
    await _settingsService.updateSettings(_settings);
    notifyListeners();
  }

  Future<void> updateFontSize(int scale) async {
    _settings = _settings.copyWith(fontSizeScale: scale);
    await _settingsService.updateSettings(_settings);
    notifyListeners();
  }

  Future<void> toggleHighContrast(bool value) async {
    _settings = _settings.copyWith(highContrastMode: value);
    await _settingsService.updateSettings(_settings);
    notifyListeners();
  }

  Future<void> toggleReducedAnimations(bool value) async {
    _settings = _settings.copyWith(reducedAnimations: value);
    await _settingsService.updateSettings(_settings);
    notifyListeners();
  }

  Future<void> updateLanguage(String language) async {
    _settings = _settings.copyWith(language: language);
    await _settingsService.updateSettings(_settings);
    notifyListeners();
  }
}
