import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../../core/constants/constants.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AccessibleScaffold(
      title: 'Ajustes',
      body: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, child) {
          return ListView(
            padding: const EdgeInsets.all(AccessibilityStyles.spacingMedium),
            children: [
              _buildSection(
                title: 'Apariencia',
                children: [
                  _buildSwitchTile(
                    title: 'Modo Oscuro',
                    value: settingsProvider.settings.darkMode,
                    onChanged: (value) =>
                        settingsProvider.toggleDarkMode(value),
                  ),
                  _buildSwitchTile(
                    title: 'Alto Contraste',
                    value: settingsProvider.settings.highContrastMode,
                    onChanged: (value) =>
                        settingsProvider.toggleHighContrast(value),
                  ),
                  _buildSliderTile(
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
              _buildSection(
                title: 'Notificaciones',
                children: [
                  _buildSwitchTile(
                    title: 'Notificaciones',
                    value: settingsProvider.settings.notificationsEnabled,
                    onChanged: (value) =>
                        settingsProvider.toggleNotifications(value),
                  ),
                  _buildSwitchTile(
                    title: 'Vibración',
                    value: settingsProvider.settings.vibrationEnabled,
                    onChanged: (value) =>
                        settingsProvider.toggleVibration(value),
                  ),
                ],
              ),
              const SizedBox(height: AccessibilityStyles.spacingLarge),
              _buildSection(
                title: 'Accesibilidad',
                children: [
                  _buildSwitchTile(
                    title: 'Animaciones Reducidas',
                    value: settingsProvider.settings.reducedAnimations,
                    onChanged: (value) =>
                        settingsProvider.toggleReducedAnimations(value),
                  ),
                ],
              ),
              const SizedBox(height: AccessibilityStyles.spacingLarge),
              _buildSection(
                title: 'Idioma',
                children: [
                  _buildLanguageTile(
                    title: 'Español',
                    value: 'es',
                    currentValue: settingsProvider.settings.language,
                    onChanged: (value) =>
                        settingsProvider.updateLanguage(value),
                  ),
                  _buildLanguageTile(
                    title: 'English',
                    value: 'en',
                    currentValue: settingsProvider.settings.language,
                    onChanged: (value) =>
                        settingsProvider.updateLanguage(value),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return AccessibleCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(AccessibilityStyles.spacingMedium),
            child: Text(
              title,
              style: AccessibilityStyles.accessibleTitleLarge,
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      title: Text(
        title,
        style: AccessibilityStyles.accessibleBodyLarge,
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildSliderTile({
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
