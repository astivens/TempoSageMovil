import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_styles.dart';
import '../../../../core/services/service_locator.dart';
import '../../../../core/widgets/page_transition.dart';
import '../../data/models/time_block_model.dart';
import '../widgets/time_block_timeline.dart';

class TimeBlocksScreen extends StatefulWidget {
  const TimeBlocksScreen({super.key});

  @override
  State<TimeBlocksScreen> createState() => _TimeBlocksScreenState();
}

class _TimeBlocksScreenState extends State<TimeBlocksScreen> {
  final _repository = ServiceLocator.instance.timeBlockRepository;
  final _timeFormat = DateFormat('HH:mm');
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
    _loadTimeBlocks();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadTimeBlocks() async {
    setState(() => _isLoading = true);
    try {
      final now = DateTime.now();
      DateTime targetDate;

      switch (_activeSection) {
        case 'tomorrow':
          targetDate = now.add(const Duration(days: 1));
          break;
        case 'upcoming':
          targetDate = now.add(const Duration(days: 2));
          break;
        default:
          targetDate = now;
      }

      debugPrint('Cargando timeblocks para: ${targetDate.toString()}');
      final blocks = await _repository.getTimeBlocksByDate(targetDate);
      debugPrint('Timeblocks encontrados: ${blocks.length}');
      for (var block in blocks) {
        debugPrint(
            'TimeBlock: ${block.title}, Start: ${block.startTime}, End: ${block.endTime}');
      }

      setState(() {
        _timeBlocks = blocks;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error cargando timeblocks: $e');
      setState(() => _isLoading = false);
    }
  }

  void _setActiveSection(String section) {
    setState(() {
      _activeSection = section;
    });
    _loadTimeBlocks();
  }

  void _handleTimeBlockTap(TimeBlockModel block) {
    Navigator.of(context).push(
      HeroPageTransition(
        heroTag: 'timeblock_${block.id}',
        page: Scaffold(
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
        ),
      ),
    );
  }

  void _handleTimeBlockDelete(TimeBlockModel block) async {
    final confirmed = await showDialog<bool>(
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

    if (confirmed == true) {
      try {
        await _repository.deleteTimeBlock(block.id);
        _loadTimeBlocks();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${block.title} eliminado'),
            backgroundColor: AppColors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al eliminar: $e'),
            backgroundColor: AppColors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.base,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
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
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface0,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => _setActiveSection('today'),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 8,
                                horizontal: 16,
                              ),
                              decoration: BoxDecoration(
                                color: _activeSection == 'today'
                                    ? AppColors.mauve
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'Today',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: _activeSection == 'today'
                                      ? Colors.white
                                      : AppColors.overlay0,
                                  fontWeight: _activeSection == 'today'
                                      ? FontWeight.w500
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: InkWell(
                            onTap: () => _setActiveSection('tomorrow'),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 8,
                                horizontal: 16,
                              ),
                              decoration: BoxDecoration(
                                color: _activeSection == 'tomorrow'
                                    ? AppColors.mauve
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'Tomorrow',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: _activeSection == 'tomorrow'
                                      ? Colors.white
                                      : AppColors.overlay0,
                                  fontWeight: _activeSection == 'tomorrow'
                                      ? FontWeight.w500
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: InkWell(
                            onTap: () => _setActiveSection('upcoming'),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 8,
                                horizontal: 16,
                              ),
                              decoration: BoxDecoration(
                                color: _activeSection == 'upcoming'
                                    ? AppColors.mauve
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'Upcoming',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: _activeSection == 'upcoming'
                                      ? Colors.white
                                      : AppColors.overlay0,
                                  fontWeight: _activeSection == 'upcoming'
                                      ? FontWeight.w500
                                      : FontWeight.normal,
                                ),
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
}
