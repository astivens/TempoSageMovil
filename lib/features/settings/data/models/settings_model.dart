import 'package:hive/hive.dart';

part 'settings_model.g.dart';

@HiveType(typeId: 4)
class SettingsModel {
  @HiveField(0)
  final bool darkMode;

  @HiveField(1)
  final bool notificationsEnabled;

  @HiveField(2)
  final int notificationSound;

  @HiveField(3)
  final bool vibrationEnabled;

  @HiveField(4)
  final int fontSizeScale;

  @HiveField(5)
  final bool highContrastMode;

  @HiveField(6)
  final bool reducedAnimations;

  @HiveField(7)
  final String language;

  const SettingsModel({
    this.darkMode = false,
    this.notificationsEnabled = true,
    this.notificationSound = 0,
    this.vibrationEnabled = true,
    this.fontSizeScale = 1,
    this.highContrastMode = false,
    this.reducedAnimations = false,
    this.language = 'es',
  });

  SettingsModel copyWith({
    bool? darkMode,
    bool? notificationsEnabled,
    int? notificationSound,
    bool? vibrationEnabled,
    int? fontSizeScale,
    bool? highContrastMode,
    bool? reducedAnimations,
    String? language,
  }) {
    return SettingsModel(
      darkMode: darkMode ?? this.darkMode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      notificationSound: notificationSound ?? this.notificationSound,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      fontSizeScale: fontSizeScale ?? this.fontSizeScale,
      highContrastMode: highContrastMode ?? this.highContrastMode,
      reducedAnimations: reducedAnimations ?? this.reducedAnimations,
      language: language ?? this.language,
    );
  }
}
