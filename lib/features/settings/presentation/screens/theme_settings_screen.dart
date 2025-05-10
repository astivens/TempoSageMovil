import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/theme_extensions.dart';
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

    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: const CustomAppBar(
        title: 'Tema',
        showBackButton: true,
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
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: context.textColor,
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
                        color: context.primaryColor,
                      ),
                      title: Text(
                        'Modo oscuro',
                        style: TextStyle(color: context.textColor),
                      ),
                      subtitle: Text(
                        'Cambia los colores a un tema oscuro',
                        style: TextStyle(color: context.subtextColor),
                      ),
                      trailing: Switch(
                        value: themeManager.isDarkMode,
                        onChanged: (value) {
                          settingsProvider.toggleDarkMode(value);
                        },
                        activeColor: context.primaryColor,
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
                          color: context.isDarkMode
                              ? AppColors.mocha.mantle
                              : AppColors.latte.mantle,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: context.primaryColor.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Vista previa del tema',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(
                                    color: context.textColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Así es como se verá tu aplicación',
                              style: TextStyle(color: context.textColor),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildColorPreview(
                                    context, context.primaryColor, 'Principal'),
                                _buildColorPreview(context,
                                    context.secondaryColor, 'Secundario'),
                                _buildColorPreview(
                                    context, context.errorColor, 'Error'),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Sección de accesibilidad
              Text(
                'Accesibilidad',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: context.textColor,
                      fontWeight: FontWeight.bold,
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
                        color: context.primaryColor,
                      ),
                      title: Text(
                        'Alto contraste',
                        style: TextStyle(color: context.textColor),
                      ),
                      subtitle: Text(
                        'Mejora la visibilidad de los elementos',
                        style: TextStyle(color: context.subtextColor),
                      ),
                      trailing: Switch(
                        value: themeManager.isHighContrast,
                        onChanged: (value) {
                          settingsProvider.toggleHighContrast(value);
                        },
                        activeColor: context.primaryColor,
                      ),
                    ),

                    const Divider(),

                    // Tamaño de fuente
                    ListTile(
                      leading: Icon(
                        Icons.text_fields,
                        color: context.primaryColor,
                      ),
                      title: Text(
                        'Tamaño de fuente',
                        style: TextStyle(color: context.textColor),
                      ),
                      subtitle: Text(
                        'Escala el texto de la aplicación',
                        style: TextStyle(color: context.subtextColor),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        children: [
                          const Text('A', style: TextStyle(fontSize: 14)),
                          Expanded(
                            child: Slider(
                              value: themeManager.textScaleFactor,
                              min: 0.8,
                              max: 1.5,
                              divisions: 7,
                              onChanged: (value) {
                                settingsProvider.updateFontSize(value.round());
                              },
                              activeColor: context.primaryColor,
                            ),
                          ),
                          const Text('A', style: TextStyle(fontSize: 24)),
                        ],
                      ),
                    ),

                    const Divider(),

                    // Animaciones reducidas
                    ListTile(
                      leading: Icon(
                        Icons.animation,
                        color: context.primaryColor,
                      ),
                      title: Text(
                        'Reducir animaciones',
                        style: TextStyle(color: context.textColor),
                      ),
                      subtitle: Text(
                        'Minimiza los efectos visuales',
                        style: TextStyle(color: context.subtextColor),
                      ),
                      trailing: Switch(
                        value: settingsProvider.settings.reducedAnimations,
                        onChanged: (value) {
                          settingsProvider.toggleReducedAnimations(value);
                        },
                        activeColor: context.primaryColor,
                      ),
                    ),
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
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(
              color: context.isDarkMode ? Colors.white30 : Colors.black12,
              width: 1,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: context.subtextColor,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
