import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../../core/constants/constants.dart';
import '../providers/settings_provider.dart';
import '../screens/theme_settings_screen.dart';
import '../widgets/settings_section.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AccessibleScaffold(
      title: 'Ajustes',
      showBackButton: true,
      body: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, child) {
          return ListView(
            padding: const EdgeInsets.all(AccessibilityStyles.spacingMedium),
            children: [
              SettingsSection(
                title: 'Apariencia',
                items: [
                  SettingsItem(
                    icon: Icons.color_lens,
                    title: 'Tema',
                    subtitle: 'Personaliza los colores y apariencia',
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
                    title: 'Modo oscuro',
                    onChanged: (value) {
                      settingsProvider.toggleDarkMode(value);
                    },
                    value: settingsProvider.settings.darkMode,
                  ),
                  SettingsItem(
                    icon: Icons.contrast,
                    title: 'Alto Contraste',
                    value: settingsProvider.settings.highContrastMode,
                    onChanged: (value) =>
                        settingsProvider.toggleHighContrast(value),
                  ),
                  _buildSliderTile(
                    context: context,
                    title: 'Tamaño de Texto',
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
                title: 'Notificaciones',
                items: [
                  SettingsItem(
                    icon: Icons.notifications,
                    title: 'Notificaciones',
                    value: settingsProvider.settings.notificationsEnabled,
                    onChanged: (value) =>
                        settingsProvider.toggleNotifications(value),
                  ),
                  SettingsItem(
                    icon: Icons.vibration,
                    title: 'Vibración',
                    value: settingsProvider.settings.vibrationEnabled,
                    onChanged: (value) =>
                        settingsProvider.toggleVibration(value),
                  ),
                ],
              ),
              const SizedBox(height: AccessibilityStyles.spacingLarge),
              SettingsSection(
                title: 'Accesibilidad',
                items: [
                  SettingsItem(
                    icon: Icons.animation,
                    title: 'Animaciones Reducidas',
                    value: settingsProvider.settings.reducedAnimations,
                    onChanged: (value) =>
                        settingsProvider.toggleReducedAnimations(value),
                  ),
                ],
              ),
              const SizedBox(height: AccessibilityStyles.spacingLarge),
              SettingsSection(
                title: 'Idioma',
                items: [
                  _buildLanguageTile(
                    context: context,
                    title: 'Español',
                    value: 'es',
                    currentValue: settingsProvider.settings.language,
                    onChanged: (value) =>
                        settingsProvider.updateLanguage(value),
                  ),
                  _buildLanguageTile(
                    context: context,
                    title: 'English',
                    value: 'en',
                    currentValue: settingsProvider.settings.language,
                    onChanged: (value) =>
                        settingsProvider.updateLanguage(value),
                  ),
                ],
              ),
              const SizedBox(height: AccessibilityStyles.spacingLarge),
              // Botón de guardar (para efectos visuales, los cambios ya se guardan automáticamente)
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AccessibilityStyles.spacingLarge),
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Configuración guardada'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                    // Volver a la pantalla anterior
                    Navigator.of(context).pop();
                  },
                  child: const Text('Guardar y volver'),
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
