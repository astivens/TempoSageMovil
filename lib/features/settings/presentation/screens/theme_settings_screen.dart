import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/theme_manager.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/themed_widget_wrapper.dart';
import '../../presentation/providers/settings_provider.dart';

/// Pantalla de configuración de temas
///
/// Permite al usuario personalizar la apariencia visual de la aplicación
class ThemeSettingsScreen extends StatelessWidget {
  const ThemeSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final themeManager = Provider.of<ThemeManager>(context);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomAppBar(
        title: 'Tema',
        showBackButton: true,
        titleStyle: TextStyle(
          color: theme.colorScheme.onBackground,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sección de selección de tema
              Text(
                'Apariencia',
                style: TextStyle(
                  color: theme.colorScheme.onBackground,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Opciones de tema
              ThemedContainer(
                child: Column(
                  children: [
                    // Modo oscuro
                    ListTile(
                      leading: Icon(
                        Icons.dark_mode,
                        color: theme.colorScheme.primary,
                      ),
                      title: Text(
                        'Modo oscuro',
                        style: TextStyle(
                          color: theme.colorScheme.onBackground,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      subtitle: Text(
                        'Cambia los colores a un tema oscuro',
                        style: TextStyle(
                          color:
                              theme.colorScheme.onBackground.withOpacity(0.7),
                        ),
                      ),
                      trailing: Switch(
                        value: themeManager.isDarkMode,
                        onChanged: (value) {
                          settingsProvider.toggleDarkMode(value);
                        },
                        activeColor: theme.colorScheme.primary,
                      ),
                    ),

                    const Divider(),

                    // Vista previa del tema actual
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 8.0),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: theme.cardColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: theme.colorScheme.primary.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Vista previa del tema',
                              style: TextStyle(
                                color: theme.colorScheme.onBackground,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildColorPreview(
                                  context,
                                  theme.colorScheme.primary,
                                  'Principal',
                                ),
                                _buildColorPreview(
                                  context,
                                  theme.colorScheme.secondary,
                                  'Secundario',
                                ),
                                _buildColorPreview(
                                  context,
                                  theme.colorScheme.background,
                                  'Fondo',
                                ),
                                _buildColorPreview(
                                  context,
                                  theme.colorScheme.error,
                                  'Error',
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              ThemedContainer(
                child: Column(
                  children: [
                    // Modo alto contraste
                    ListTile(
                      leading: Icon(
                        Icons.contrast,
                        color: theme.colorScheme.primary,
                      ),
                      title: Text(
                        'Alto contraste',
                        style: TextStyle(
                          color: theme.colorScheme.onBackground,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      subtitle: Text(
                        'Mejora la visibilidad de los elementos',
                        style: TextStyle(
                          color:
                              theme.colorScheme.onBackground.withOpacity(0.7),
                        ),
                      ),
                      trailing: Switch(
                        value: themeManager.isHighContrast,
                        onChanged: (value) {
                          settingsProvider.toggleHighContrast(value);
                        },
                        activeColor: theme.colorScheme.primary,
                      ),
                    ),

                    const Divider(),

                    // Tamaño de fuente
                    ListTile(
                      leading: Icon(
                        Icons.text_fields,
                        color: theme.colorScheme.primary,
                      ),
                      title: Text(
                        'Tamaño de fuente',
                        style: TextStyle(
                          color: theme.colorScheme.onBackground,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      subtitle: Text(
                        'Escala el texto de la aplicación',
                        style: TextStyle(
                          color:
                              theme.colorScheme.onBackground.withOpacity(0.7),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        children: [
                          Text('A',
                              style: TextStyle(
                                  fontSize: 14,
                                  color: theme.colorScheme.onBackground)),
                          Expanded(
                            child: Slider(
                              value: themeManager.textScaleFactor,
                              min: 1.0,
                              max: 2.0,
                              divisions: 4,
                              onChanged: (value) {
                                settingsProvider.updateFontSize(value.toInt());
                              },
                              activeColor: theme.colorScheme.primary,
                            ),
                          ),
                          Text('A',
                              style: TextStyle(
                                  fontSize: 24,
                                  color: theme.colorScheme.onBackground)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Construye una vista previa de un color del tema
  Widget _buildColorPreview(BuildContext context, Color color, String label) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(
              color: theme.colorScheme.onBackground.withOpacity(0.2),
              width: 1,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: theme.colorScheme.onBackground,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
