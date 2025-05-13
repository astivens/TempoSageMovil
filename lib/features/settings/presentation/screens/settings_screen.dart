import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../../core/constants/constants.dart';
import '../../../../core/services/service_locator.dart';
import '../providers/settings_provider.dart';
import '../screens/theme_settings_screen.dart';
import '../widgets/settings_section.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AccessibleScaffold(
      title: l10n.settings,
      showBackButton: true,
      body: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, child) {
          return ListView(
            padding: const EdgeInsets.all(AccessibilityStyles.spacingMedium),
            children: [
              SettingsSection(
                title: l10n.appearance,
                items: [
                  SettingsItem(
                    icon: Icons.color_lens,
                    title: l10n.theme,
                    subtitle: l10n.themeDescription,
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ThemeSettingsScreen(),
                        ),
                      );
                    },
                  ),
                  SettingsItem(
                    icon: Icons.dark_mode,
                    title: l10n.darkMode,
                    onChanged: (value) {
                      settingsProvider.toggleDarkMode(value);
                    },
                    value: settingsProvider.settings.darkMode,
                  ),
                  SettingsItem(
                    icon: Icons.contrast,
                    title: l10n.highContrast,
                    value: settingsProvider.settings.highContrastMode,
                    onChanged: (value) =>
                        settingsProvider.toggleHighContrast(value),
                  ),
                  _buildSliderTile(
                    context: context,
                    title: l10n.fontSize,
                    value: settingsProvider.settings.fontSizeScale.toDouble(),
                    min: 1,
                    max: 2,
                    divisions: 4,
                    onChanged: (value) =>
                        settingsProvider.updateFontSize(value.toInt()),
                  ),
                ],
              ),
              const SizedBox(height: AccessibilityStyles.spacingLarge),
              SettingsSection(
                title: l10n.notifications,
                items: [
                  SettingsItem(
                    icon: Icons.notifications,
                    title: l10n.notifications,
                    value: settingsProvider.settings.notificationsEnabled,
                    onChanged: (value) =>
                        settingsProvider.toggleNotifications(value),
                  ),
                  SettingsItem(
                    icon: Icons.vibration,
                    title: l10n.vibration,
                    value: settingsProvider.settings.vibrationEnabled,
                    onChanged: (value) =>
                        settingsProvider.toggleVibration(value),
                  ),
                  SettingsItem(
                    icon: Icons.notification_important,
                    title: 'Probar notificaciones',
                    subtitle: 'Envía una notificación de prueba inmediata',
                    onTap: () async {
                      try {
                        // Mostrar indicador de carga
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Enviando notificación de prueba...'),
                            duration: Duration(seconds: 1),
                          ),
                        );

                        // Enviar notificación de prueba
                        await ServiceLocator.instance.notificationService
                            .showTestNotification();

                        // Mostrar mensaje de éxito
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  'Notificación de prueba enviada. Revisa la barra de notificaciones.'),
                              duration: Duration(seconds: 3),
                            ),
                          );
                        }
                      } catch (e) {
                        // Mostrar error si ocurre
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error al enviar notificación: $e'),
                              backgroundColor: Colors.red,
                              duration: const Duration(seconds: 5),
                            ),
                          );
                        }
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: AccessibilityStyles.spacingLarge),
              SettingsSection(
                title: l10n.accessibility,
                items: [
                  SettingsItem(
                    icon: Icons.animation,
                    title: l10n.reducedAnimations,
                    value: settingsProvider.settings.reducedAnimations,
                    onChanged: (value) =>
                        settingsProvider.toggleReducedAnimations(value),
                  ),
                ],
              ),
              const SizedBox(height: AccessibilityStyles.spacingLarge),
              SettingsSection(
                title: l10n.language,
                items: [
                  _buildLanguageTile(
                    context: context,
                    title: l10n.spanish,
                    value: 'es',
                    currentValue: settingsProvider.settings.language,
                    onChanged: (value) =>
                        settingsProvider.updateLanguage(value),
                  ),
                  _buildLanguageTile(
                    context: context,
                    title: l10n.english,
                    value: 'en',
                    currentValue: settingsProvider.settings.language,
                    onChanged: (value) =>
                        settingsProvider.updateLanguage(value),
                  ),
                ],
              ),
              const SizedBox(height: AccessibilityStyles.spacingLarge),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AccessibilityStyles.spacingLarge),
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(l10n.settingsSaved),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                    Navigator.of(context).pop();
                  },
                  child: Text(l10n.saveAndReturn),
                ),
              ),
              const SizedBox(height: AccessibilityStyles.spacingLarge),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSliderTile({
    required BuildContext context,
    required String title,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required ValueChanged<double> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.all(AccessibilityStyles.spacingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AccessibilityStyles.accessibleBodyLarge,
          ),
          Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageTile({
    required BuildContext context,
    required String title,
    required String value,
    required String currentValue,
    required ValueChanged<String> onChanged,
  }) {
    return ListTile(
      title: Text(
        title,
        style: AccessibilityStyles.accessibleBodyLarge,
      ),
      trailing: Radio<String>(
        value: value,
        groupValue: currentValue,
        onChanged: (value) => onChanged(value!),
      ),
    );
  }
}
