import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_styles.dart';
import '../../../../core/services/service_locator.dart';
import '../../../../core/widgets/page_transitions.dart';
import '../../../../core/utils/error_handler.dart';
import '../../data/models/time_block_model.dart';
import '../widgets/time_block_timeline.dart';

/// Pantalla que muestra los bloques de tiempo organizados en una línea de tiempo.
/// Permite visualizar, gestionar y sincronizar bloques de tiempo con hábitos.
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

  // Formato para visualización de tiempo
  final _timeFormat = DateFormat('HH:mm');

  // Estado
  List<TimeBlockModel> _timeBlocks = [];
  bool _isLoading = true;
  String _activeSection = 'today';

  @override
  void initState() {
    super.initState();
    _loadTimeBlocks();
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
  /// Sincroniza automáticamente los hábitos como bloques de tiempo
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

  /// Asegura que los hábitos del usuario estén representados como bloques de tiempo
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
    return Scaffold(
      appBar: AppBar(
        title: Hero(
          tag: 'timeblock_title_${block.id}',
          child: Material(
            color: Colors.transparent,
            child: Text(
              block.title,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
        backgroundColor: AppColors.surface0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Hero(
              tag: 'timeblock_${block.id}',
              child: Card(
                margin: const EdgeInsets.all(16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        block.title,
                        style: AppStyles.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${_timeFormat.format(block.startTime)} - ${_timeFormat.format(block.endTime)}',
                        style: AppStyles.bodyMedium,
                      ),
                      ...[
                        const SizedBox(height: 8),
                        Text(
                          block.description,
                          style: AppStyles.bodyMedium,
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
    final confirmed = await _showDeleteConfirmationDialog(block);

    if (confirmed == true) {
      try {
        await _repository.deleteTimeBlock(block.id);
        _loadTimeBlocks();

        if (!mounted) return;
        ErrorHandler.showSuccessSnackBar(context, '${block.title} eliminado');
      } catch (e) {
        ErrorHandler.logError('Error al eliminar timeblock', e, null);

        if (!mounted) return;
        ErrorHandler.showErrorSnackBar(
            context, 'No se pudo eliminar el bloque de tiempo');
      }
    }
  }

  /// Muestra un diálogo de confirmación para eliminar un bloque
  Future<bool?> _showDeleteConfirmationDialog(TimeBlockModel block) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar bloque'),
        content:
            Text('¿Estás seguro de que quieres eliminar "${block.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.base,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : TimeBlockTimeline(
                      timeBlocks: _timeBlocks,
                      onTimeBlockTap: _handleTimeBlockTap,
                      onTimeBlockDelete: _handleTimeBlockDelete,
                    ),
            ),
          ],
        ),
      ),
    );
  }

  /// Construye la sección de encabezado con título y pestañas
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Time Blocks',
            style: AppStyles.titleLarge.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildTabSelector(),
        ],
      ),
    );
  }

  /// Construye el selector de pestañas (hoy, mañana, próximos días)
  Widget _buildTabSelector() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface0,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          _buildTabButton('today', 'Today'),
          _buildTabButton('tomorrow', 'Tomorrow'),
          _buildTabButton('upcoming', 'Upcoming'),
        ],
      ),
    );
  }

  /// Construye un botón de pestaña individual
  Widget _buildTabButton(String section, String label) {
    final isActive = _activeSection == section;

    return Expanded(
      child: InkWell(
        onTap: () => _setActiveSection(section),
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: 8,
            horizontal: 16,
          ),
          decoration: BoxDecoration(
            color: isActive ? AppColors.mauve : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isActive ? Colors.white : AppColors.overlay0,
              fontWeight: isActive ? FontWeight.w500 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}
