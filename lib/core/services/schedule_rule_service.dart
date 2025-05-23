import 'package:device_calendar/device_calendar.dart';
import 'package:temposage/core/models/productive_block.dart';
import 'package:temposage/core/utils/logger.dart';

/// Modelo de datos para el contexto del usuario
class UserContext {
  final int priority;           // 1-5
  final double energyLevel;     // 0.0-1.0
  final double moodLevel;       // 0.0-1.0
  final String predictedCategory;
  
  const UserContext({
    this.priority = 3,
    this.energyLevel = 0.5,
    this.moodLevel = 0.5,
    this.predictedCategory = '',
  });
}

/// Clase para representar un bloque horario sugerido
class SuggestedTimeBlock {
  final DateTime dateTime;
  final ProductiveBlock block;
  
  SuggestedTimeBlock({
    required this.dateTime,
    required this.block,
  });
  
  @override
  String toString() {
    final days = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'];
    final day = days[dateTime.weekday - 1];
    final hour = dateTime.hour < 10 ? '0${dateTime.hour}:00' : '${dateTime.hour}:00';
    
    return '$day a las $hour';
  }
}

class ScheduleRuleService {
  final DeviceCalendarPlugin _calendarPlugin = DeviceCalendarPlugin();
  final Logger _logger = Logger('ScheduleRuleService');
  
  /// Sugiere el mejor bloque horario según las reglas híbridas
  Future<SuggestedTimeBlock?> suggestBlock({
    required List<ProductiveBlock> productiveBlocks,
    required DateTime referenceDate,
    UserContext userContext = const UserContext(),
  }) async {
    try {
      if (productiveBlocks.isEmpty) {
        _logger.w('No hay bloques productivos para sugerir');
        return null;
      }
      
      // Ordenar bloques por tasa de completado
      final sortedBlocks = ProductiveBlock.sortByCompletionRate(productiveBlocks);
      
      // Obtener calendario y eventos
      final calendarsResult = await _calendarPlugin.retrieveCalendars();
      if (calendarsResult.isSuccess && calendarsResult.data == null) {
        _logger.e('Error al obtener calendarios');
        return _fallbackSuggestion(sortedBlocks, referenceDate);
      }
      
      final calendars = calendarsResult.data ?? [];
      if (calendars.isEmpty) {
        _logger.w('No se encontraron calendarios');
        return _fallbackSuggestion(sortedBlocks, referenceDate);
      }
      
      // Iterar sobre bloques productivos
      for (final block in sortedBlocks) {
        // Calcular próximo día con el mismo día de la semana
        final daysAhead = (block.weekday - (referenceDate.weekday - 1)) % 7;
        final candidateDate = referenceDate.add(Duration(days: daysAhead));
        
        // Construir el bloque horario
        final slotStart = DateTime(
          candidateDate.year,
          candidateDate.month,
          candidateDate.day,
          block.hour,
          0,
        );
        final slotEnd = slotStart.add(const Duration(hours: 1));
        
        // Verificar si hay eventos en ese intervalo
        bool isSlotFree = true;
        
        for (final calendar in calendars) {
          final eventsResult = await _calendarPlugin.retrieveEvents(
            calendar.id,
            RetrieveEventsParams(
              startDate: slotStart,
              endDate: slotEnd,
            ),
          );
          
          if (eventsResult.isSuccess && eventsResult.data != null && eventsResult.data!.isNotEmpty) {
            isSlotFree = false;
            break;
          }
        }
        
        if (isSlotFree) {
          // Aplicar reglas de negocio
          
          // Regla 1: Si la tarea tiene prioridad alta (≥ 4), aceptar este bloque
          if (userContext.priority >= 4) {
            return SuggestedTimeBlock(dateTime: slotStart, block: block);
          }
          
          // Regla 2: Si la categoría es "Formación" y el nivel de ánimo es bajo, descartar
          if (userContext.predictedCategory.toLowerCase() == 'formación' && 
              userContext.moodLevel < 0.4) {
            continue;
          }
          
          // Regla 3: Si el nivel de energía es bajo y el bloque no es muy productivo, descartar
          if (userContext.energyLevel < 0.3 && block.completionRate < 0.8) {
            continue;
          }
          
          // En cualquier otro caso, aceptar el bloque
          return SuggestedTimeBlock(dateTime: slotStart, block: block);
        }
      }
      
      // Si no hay bloques disponibles en el Top 3
      _logger.w('No hay bloques disponibles en la lista de bloques productivos');
      return null;
      
    } catch (e) {
      _logger.e('Error al sugerir bloque: $e');
      return _fallbackSuggestion(productiveBlocks, referenceDate);
    }
  }
  
  /// Sugerencia de respaldo si no podemos acceder al calendario
  SuggestedTimeBlock? _fallbackSuggestion(List<ProductiveBlock> blocks, DateTime referenceDate) {
    if (blocks.isEmpty) return null;
    
    final block = blocks.first;
    final daysAhead = (block.weekday - (referenceDate.weekday - 1)) % 7;
    final candidateDate = referenceDate.add(Duration(days: daysAhead));
    
    final slotStart = DateTime(
      candidateDate.year,
      candidateDate.month,
      candidateDate.day,
      block.hour,
      0,
    );
    
    return SuggestedTimeBlock(dateTime: slotStart, block: block);
  }
} 