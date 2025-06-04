import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'dart:async';
import '../../../../core/constants/app_styles.dart';
import '../../../../core/services/service_locator.dart';
import '../../../../core/services/event_bus.dart';
import '../../../../core/widgets/page_transitions.dart';
import '../../../../core/utils/error_handler.dart';
import '../../data/models/time_block_model.dart';
import '../widgets/time_block_timeline.dart';

/// Pantalla que muestra los bloques de tiempo organizados en una línea de tiempo.
/// Permite visualizar, gestionar y sincronizar bloques de tiempo con hábitos y actividades.
class TimeBlocksScreen extends StatefulWidget {
  const TimeBlocksScreen({super.key});

  @override
  State<TimeBlocksScreen> createState() => _TimeBlocksScreenState();
}

class _TimeBlocksScreenState extends State<TimeBlocksScreen> {
  // Dependencias
  final _repository = ServiceLocator.instance.timeBlockRepository;
  final _habitToTimeBlockService =
      ServiceLocator.instance.habitToTimeBlockService;
  final _activityToTimeBlockService =
      ServiceLocator.instance.activityToTimeBlockService;

  // Formato para visualización de tiempo
  final _timeFormat = DateFormat('HH:mm');

  // Estado
  List<TimeBlockModel> _timeBlocks = [];
  bool _isLoading = true;
  String _activeSection = 'today';
  StreamSubscription<String>? _eventSubscription;

  @override
  void initState() {
    super.initState();
    _loadTimeBlocks();
    _setupEventListener();
  }

  @override
  void dispose() {
    _eventSubscription?.cancel();
    super.dispose();
  }

  void _setupEventListener() {
    _eventSubscription = EventBus().events.listen((event) {
      debugPrint('🎧 TimeBlocksScreen recibió evento: $event');
      if (event == AppEvents.timeBlockCreated ||
          event == AppEvents.habitCreated ||
          event == AppEvents.activityCreated ||
          event == AppEvents.dataChanged) {
        debugPrint('🔄 Actualizando lista de timeblocks...');
        _loadTimeBlocks();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Evitar múltiples cargas innecesarias
    if (_timeBlocks.isEmpty) {
      _loadTimeBlocks();
    }
  }

  /// Carga los bloques de tiempo para la sección activa (hoy, mañana, próximos días)
  /// Sincroniza automáticamente los hábitos y actividades como bloques de tiempo
  Future<void> _loadTimeBlocks() async {
    if (!mounted) return;

    setState(() => _isLoading = true);

    try {
      // Determinar la fecha objetivo basada en la sección activa
      final targetDate = _getTargetDateForActiveSection();

      // Normalizar la fecha para comparaciones consistentes (sin tiempo)
      final normalizedDate =
          DateTime(targetDate.year, targetDate.month, targetDate.day);

      debugPrint(
          'Cargando timeblocks para: ${normalizedDate.toIso8601String()}');

      // Asegurar que los hábitos estén sincronizados como bloques de tiempo
      await _ensureHabitTimeBlocksExist(normalizedDate);

      // Asegurar que las actividades estén sincronizadas como bloques de tiempo
      await _ensureActivityTimeBlocksExist(normalizedDate);

      // Obtener todos los bloques para la fecha seleccionada
      final blocks = await _repository.getTimeBlocksByDate(normalizedDate);
      debugPrint('Timeblocks encontrados: ${blocks.length}');

      // Ordenar los bloques por hora de inicio
      blocks.sort((a, b) => a.startTime.compareTo(b.startTime));

      // Actualizar la UI con los bloques
      if (mounted) {
        setState(() {
          _timeBlocks = blocks;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error cargando timeblocks: $e');

      if (mounted) {
        setState(() => _isLoading = false);
        ErrorHandler.showErrorSnackBar(
            context, 'No se pudieron cargar los bloques de tiempo');
      }
    }
  }

  /// Obtiene la fecha objetivo basada en la sección activa seleccionada
  DateTime _getTargetDateForActiveSection() {
    final now = DateTime.now();

    switch (_activeSection) {
      case 'tomorrow':
        return now.add(const Duration(days: 1));
      case 'upcoming':
        return now.add(const Duration(days: 2));
      default: // 'today'
        return now;
    }
  }

  /// Asegurar que los hábitos del usuario estén representados como bloques de tiempo
  /// Solo crea nuevos bloques si aún no existen para la fecha especificada
  Future<void> _ensureHabitTimeBlocksExist(DateTime date) async {
    try {
      debugPrint(
          'Verificando bloques de tiempo para hábitos en ${date.toIso8601String()}');

      // Verificar si ya existen bloques de tiempo generados desde hábitos
      final existingBlocks = await _repository.getTimeBlocksByDate(date);
      final habitBlocksExist = existingBlocks.any((block) =>
          block.title.contains('Hábito:') ||
          block.description.contains('Hábito generado automáticamente'));

      if (habitBlocksExist) {
        debugPrint(
            'Bloques de hábitos ya existen para esta fecha. Omitiendo sincronización.');
        return;
      }

      // Convertir hábitos a bloques de tiempo si no existen
      debugPrint('Creando bloques de tiempo desde hábitos');
      final newBlocks =
          await _habitToTimeBlockService.convertHabitsToTimeBlocks(date);

      // Registrar estadísticas
      if (newBlocks.isNotEmpty) {
        debugPrint(
            'Creados ${newBlocks.length} bloques de tiempo desde hábitos');
      } else {
        debugPrint(
            'No se crearon bloques de tiempo (no hay hábitos para esta fecha)');
      }
    } catch (e) {
      ErrorHandler.logError(
          'Error sincronizando hábitos con timeblocks', e, null);
      // No propagamos el error para no interrumpir la carga de bloques existentes
      // pero mostramos una alerta al usuario
      if (mounted) {
        ErrorHandler.showErrorSnackBar(
            context, 'No se pudieron sincronizar todos los hábitos');
      }
    }
  }

  /// Asegurar que las actividades del usuario estén representadas como bloques de tiempo
  /// Solo crea nuevos bloques si aún no existen para la fecha especificada
  Future<void> _ensureActivityTimeBlocksExist(DateTime date) async {
    try {
      debugPrint(
          'Verificando bloques de tiempo para actividades en ${date.toIso8601String()}');

      // Convertir actividades a bloques de tiempo
      debugPrint('Creando bloques de tiempo desde actividades');
      final newBlocks =
          await _activityToTimeBlockService.convertActivitiesToTimeBlocks(date);

      // Registrar estadísticas
      if (newBlocks.isNotEmpty) {
        debugPrint(
            'Creados ${newBlocks.length} bloques de tiempo desde actividades');
      } else {
        debugPrint(
            'No se crearon bloques de tiempo (no hay actividades para esta fecha)');
      }
    } catch (e) {
      ErrorHandler.logError(
          'Error sincronizando actividades con timeblocks', e, null);
      // No propagamos el error para no interrumpir la carga de bloques existentes
      // pero mostramos una alerta al usuario
      if (mounted) {
        ErrorHandler.showErrorSnackBar(
            context, 'No se pudieron sincronizar todas las actividades');
      }
    }
  }

  /// Cambia entre las diferentes secciones (hoy, mañana, próximos días)
  void _setActiveSection(String section) {
    if (_activeSection != section) {
      setState(() {
        _activeSection = section;
      });
      _loadTimeBlocks();
    }
  }

  /// Muestra la pantalla de detalle de un bloque de tiempo
  void _handleTimeBlockTap(TimeBlockModel block) {
    Navigator.of(context).push(
      HeroPageTransition(
        page: _buildTimeBlockDetailScreen(block),
        heroTag: 'timeblock_${block.id}',
      ),
    );
  }

  /// Construye la pantalla de detalle para un bloque de tiempo
  Widget _buildTimeBlockDetailScreen(TimeBlockModel block) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Hero(
          tag: 'timeblock_title_${block.id}',
          child: Material(
            color: Colors.transparent,
            child: Text(
              block.title,
              style: TextStyle(
                color: theme.colorScheme.onBackground,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        backgroundColor: theme.scaffoldBackgroundColor,
        iconTheme: IconThemeData(color: theme.colorScheme.onBackground),
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Hero(
              tag: 'timeblock_${block.id}',
              child: Card(
                margin: const EdgeInsets.all(16),
                elevation: 4,
                color: theme.cardColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: theme.colorScheme.primary.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        block.title,
                        style: TextStyle(
                          color: theme.colorScheme.onBackground,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            color: theme.colorScheme.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${_timeFormat.format(block.startTime)} - ${_timeFormat.format(block.endTime)}',
                            style: TextStyle(
                              color: theme.colorScheme.onBackground,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      if (block.description.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Divider(
                            color: theme.colorScheme.onBackground
                                .withOpacity(0.1)),
                        const SizedBox(height: 16),
                        Text(
                          block.description,
                          style: TextStyle(
                            color:
                                theme.colorScheme.onBackground.withOpacity(0.8),
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Gestiona la eliminación de un bloque de tiempo
  Future<void> _handleTimeBlockDelete(TimeBlockModel block) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteTimeBlock),
        content: Text(l10n.deleteTimeBlockConfirmation(block.title)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _repository.deleteTimeBlock(block.id);
        _loadTimeBlocks();

        if (!mounted) return;
        ErrorHandler.showSuccessSnackBar(
          context,
          l10n.timeBlockDeleted(block.title),
        );
      } catch (e) {
        ErrorHandler.logError('Error al eliminar timeblock', e, null);

        if (!mounted) return;
        ErrorHandler.showErrorSnackBar(
          context,
          l10n.timeBlockDeleteError,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildSectionSelector(theme),
                Expanded(
                  child: _timeBlocks.isEmpty
                      ? Center(
                          child: Text(
                            _activeSection == 'today'
                                ? l10n.timeBlocksNoBlocksToday
                                : l10n.timeBlocksNoBlocksSelected,
                            style: AppStyles.bodyLarge.copyWith(
                              color:
                                  theme.colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                        )
                      : TimeBlockTimeline(
                          timeBlocks: _timeBlocks,
                          onTimeBlockTap: _handleTimeBlockTap,
                          onTimeBlockDelete: _handleTimeBlockDelete,
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildSectionSelector(ThemeData theme) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildSectionButton(
            theme,
            'today',
            l10n.timeBlocksToday,
            Icons.today,
          ),
          _buildSectionButton(
            theme,
            'tomorrow',
            l10n.timeBlocksTomorrow,
            Icons.event,
          ),
          _buildSectionButton(
            theme,
            'upcoming',
            l10n.timeBlocksUpcoming,
            Icons.calendar_month,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionButton(
    ThemeData theme,
    String section,
    String label,
    IconData icon,
  ) {
    final isSelected = _activeSection == section;
    // Usar un color con mejor contraste para los elementos no seleccionados
    final color =
        isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface;

    return TextButton.icon(
      onPressed: () {
        _setActiveSection(section);
      },
      icon: Icon(icon, color: color, size: 20),
      label: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      style: TextButton.styleFrom(
        backgroundColor: isSelected
            ? theme.colorScheme.primaryContainer.withOpacity(0.2)
            : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
