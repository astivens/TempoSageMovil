import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../../core/services/service_locator.dart';
import '../../../../core/services/event_bus.dart';
import '../../../dashboard/presentation/screens/dashboard_screen.dart';
import '../../../activities/presentation/screens/activities_screen.dart';
import '../../../habits/presentation/screens/habits_screen.dart'
    hide AddHabitDialog;
import '../../../habits/presentation/widgets/add_habit_dialog.dart';
import '../../../habits/data/models/habit_model.dart';
import '../../../habits/domain/entities/habit.dart';
import '../../../timeblocks/presentation/screens/time_blocks_screen.dart';
import '../../../dashboard/controllers/dashboard_controller.dart';
import '../../../chat/presentation/pages/chat_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    DashboardScreen(),
    ActivitiesScreen(),
    HabitsScreen(),
    TimeBlocksScreen(),
    ChatAIPage(),
  ];

  final List<String> _screenTitles = const [
    'Dashboard',
    'Actividades',
    'Hábitos',
    'Bloques de Tiempo',
    'Chat con IA',
  ];

  void _onItemTapped(int index) {
    if (index >= 0 && index < _screens.length) {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  void _openSettings() {
    Navigator.pushNamed(context, '/settings');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar.main(
        title: _screenTitles[_selectedIndex],
        actions: [
          IconButton(
            onPressed: _openSettings,
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Configuración',
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      floatingActionButton: _selectedIndex == 4
          ? null // No mostrar FAB en la pantalla de Chat IA
          : _selectedIndex == 0
              ? ExpandableFab(
                  icon: const Icon(Icons.add),
                  closeIcon: const Icon(Icons.close),
                  openFabTooltip: 'Crear nuevo',
                  closeFabTooltip: 'Cerrar menú',
                  children: _getFabActions(),
                )
              : FloatingActionButton(
                  onPressed: () {
                    switch (_selectedIndex) {
                      case 1: // Actividades
                        _navigateToCreate('activity');
                        break;
                      case 2: // Hábitos
                        _navigateToCreate('habit');
                        break;
                      case 3: // Bloques de Tiempo
                        _navigateToCreate('timeblock');
                        break;
                    }
                  },
                  child: const Icon(Icons.add),
                ),
      bottomNavigationBar: BottomNavigation.tempoSage(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  void _navigateToCreate(String type) async {
    debugPrint('🎯 Navegando para crear: $type');

    switch (type) {
      case 'activity':
        final result = await Navigator.pushNamed(context, '/create-activity');
        debugPrint('📊 Resultado creación actividad: $result');
        // Refrescar dashboard si se creó una actividad
        if (result == true && mounted) {
          EventBus().emit(AppEvents.activityCreated);
          _refreshDashboardIfNeeded();
        }
        break;
      case 'habit':
        debugPrint('🔧 Mostrando diálogo para crear hábito...');
        final result = await showDialog<HabitModel>(
          context: context,
          builder: (context) => const AddHabitDialog(),
        );

        debugPrint(
            '📝 Resultado del diálogo de hábito: ${result != null ? result.title : 'null'}');

        if (result != null) {
          try {
            debugPrint('💾 Guardando hábito: ${result.title}');
            debugPrint(
                '📅 Días seleccionados: ${result.daysOfWeek.join(', ')}');
            debugPrint('⏰ Hora: ${result.time}');

            // Convertir HabitModel a Habit entity
            final habitEntity = Habit(
              id: result.id,
              name: result.title,
              description: result.description,
              daysOfWeek: result.daysOfWeek,
              category: result.category,
              reminder: result.reminder,
              time: result.time,
              isDone: result.isCompleted,
              dateCreation: result.dateCreation,
            );

            // Guardar el hábito en el repositorio
            final habitRepository = ServiceLocator.instance.habitRepository;
            await habitRepository.addHabit(habitEntity);

            debugPrint('✅ Hábito guardado exitosamente en el repositorio');

            // Emitir evento específico de hábito creado
            EventBus().emit(AppEvents.habitCreated);

            // Refrescar dashboard después de crear el hábito
            debugPrint('🔄 Solicitando refresh del dashboard...');
            _refreshDashboardIfNeeded();

            // Esperar un poco para asegurar que se procese
            await Future.delayed(const Duration(milliseconds: 500));

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Hábito "${result.title}" creado exitosamente'),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                ),
              );
            }
          } catch (e) {
            debugPrint('❌ Error creando hábito: $e');
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error al crear el hábito: $e'),
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
              );
            }
          }
        }
        break;
      case 'timeblock':
        final result = await Navigator.pushNamed(context, '/create-timeblock');
        debugPrint('⏰ Resultado creación timeblock: $result');
        // Refrescar dashboard si se creó un timeblock
        if (result == true && mounted) {
          EventBus().emit(AppEvents.timeBlockCreated);
          _refreshDashboardIfNeeded();
        }
        break;
    }
  }

  // Método para refrescar el dashboard cuando estamos en esa pestaña
  void _refreshDashboardIfNeeded() {
    debugPrint(
        '🔍 Verificando si necesita refresh... índice actual: $_selectedIndex');

    // Siempre refrescar el dashboard cuando se crea algo nuevo
    try {
      debugPrint('📊 Refrescando dashboard desde HomeScreen...');
      final dashboardController =
          Provider.of<DashboardController>(context, listen: false);
      dashboardController.refreshDashboard();
    } catch (e) {
      debugPrint('❌ Error al refrescar dashboard: $e');
    }

    // Emitir evento para que todas las pantallas se actualicen
    EventBus().emit(AppEvents.dataChanged);
    debugPrint('📡 Evento de cambio de datos emitido');
  }

  List<Widget> _getFabActions() {
    // Solo para Dashboard - opciones múltiples
    return [
      ActionButton(
        onPressed: () => _navigateToCreate('activity'),
        icon: const Icon(Icons.assignment_outlined),
        tooltip: 'Nueva Actividad',
      ),
      ActionButton(
        onPressed: () => _navigateToCreate('habit'),
        icon: const Icon(Icons.auto_awesome_outlined),
        tooltip: 'Nuevo Hábito',
      ),
      ActionButton(
        onPressed: () => _navigateToCreate('timeblock'),
        icon: const Icon(Icons.schedule_outlined),
        tooltip: 'Nuevo Bloque',
      ),
    ];
  }
}
