import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/navigation_service.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      title: '¡Bienvenido a TempoSage!',
      description:
          'Tu asistente inteligente para gestionar tiempo, hábitos y productividad.',
      icon: Icons.schedule,
      color: AppColors.latte.blue,
    ),
    OnboardingPage(
      title: 'Gestiona tus Actividades',
      description:
          'Organiza tus tareas, crea horarios óptimos y recibe recordatorios inteligentes.',
      icon: Icons.assignment,
      color: AppColors.latte.green,
    ),
    OnboardingPage(
      title: 'Construye Hábitos Saludables',
      description:
          'Crea rutinas diarias, haz seguimiento de tu progreso y alcanza tus metas.',
      icon: Icons.auto_awesome,
      color: AppColors.latte.mauve,
    ),
    OnboardingPage(
      title: 'Bloques de Tiempo',
      description:
          'Planifica tu día con bloques de tiempo dedicados y optimiza tu productividad.',
      icon: Icons.view_timeline,
      color: AppColors.latte.peach,
    ),
    OnboardingPage(
      title: 'IA Personalizada',
      description:
          'Recibe sugerencias inteligentes basadas en tus patrones y preferencias.',
      icon: Icons.psychology,
      color: AppColors.latte.yellow,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _completeOnboarding() {
    NavigationService.replaceTo('/home');
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? AppColors.mocha.base : AppColors.latte.base,
      body: SafeArea(
        child: Column(
          children: [
            // Indicador de progreso
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  TextButton(
                    onPressed: _completeOnboarding,
                    child: Text(
                      'Omitir',
                      style: TextStyle(
                        color: isDarkMode
                            ? AppColors.mocha.subtext1
                            : AppColors.latte.subtext1,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${_currentPage + 1} de ${_pages.length}',
                    style: TextStyle(
                      color: isDarkMode
                          ? AppColors.mocha.subtext1
                          : AppColors.latte.subtext1,
                    ),
                  ),
                ],
              ),
            ),

            // Contenido principal
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Icono
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: page.color.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            page.icon,
                            size: 60,
                            color: page.color,
                          ),
                        ),
                        const SizedBox(height: 48),

                        // Título
                        Text(
                          page.title,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode
                                ? AppColors.mocha.text
                                : AppColors.latte.text,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),

                        // Descripción
                        Text(
                          page.description,
                          style: TextStyle(
                            fontSize: 16,
                            color: isDarkMode
                                ? AppColors.mocha.subtext1
                                : AppColors.latte.subtext1,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Indicadores de página
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: _pages.asMap().entries.map((entry) {
                return Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentPage == entry.key
                        ? (isDarkMode
                            ? AppColors.mocha.blue
                            : AppColors.latte.blue)
                        : (isDarkMode
                            ? AppColors.mocha.surface1
                            : AppColors.latte.surface1),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),

            // Botones de navegación
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  if (_currentPage > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _previousPage,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: BorderSide(
                            color: isDarkMode
                                ? AppColors.mocha.blue
                                : AppColors.latte.blue,
                          ),
                        ),
                        child: Text(
                          'Anterior',
                          style: TextStyle(
                            color: isDarkMode
                                ? AppColors.mocha.blue
                                : AppColors.latte.blue,
                          ),
                        ),
                      ),
                    ),
                  if (_currentPage > 0) const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _nextPage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDarkMode
                            ? AppColors.mocha.blue
                            : AppColors.latte.blue,
                        foregroundColor: isDarkMode
                            ? AppColors.mocha.base
                            : AppColors.latte.base,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        _currentPage == _pages.length - 1
                            ? 'Comenzar'
                            : 'Siguiente',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OnboardingPage {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  OnboardingPage({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}
