import 'package:flutter/material.dart';
import '../../../../core/services/voice_command_service.dart';
import '../../activities/data/models/activity_model.dart';
import '../controllers/dashboard_controller.dart';

class VoiceCommandHandler {
  final BuildContext context;
  final DashboardController controller;

  VoiceCommandHandler({
    required this.context,
    required this.controller,
  });

  Future<void> handleCommand(VoiceCommand command) async {
    debugPrint('Manejando comando: ${command.type}');

    switch (command.type) {
      case VoiceCommandType.createActivity:
        await _handleCreateActivity(command);
        break;

      case VoiceCommandType.createTimeBlock:
        await _handleCreateTimeBlock(command);
        break;

      case VoiceCommandType.navigate:
        await _handleNavigate(command);
        break;

      case VoiceCommandType.markComplete:
        await _handleMarkComplete(command);
        break;

      case VoiceCommandType.delete:
        await _handleDelete(command);
        break;

      case VoiceCommandType.unknown:
        _showSnackBar(
            'No pude entender ese comando. ¿Podrías intentarlo de nuevo?');
        break;
    }
  }

  Future<void> _handleCreateActivity(VoiceCommand command) async {
    final title = command.parameters['title'] as String;
    final category = command.parameters['category'] as String;

    if (title.isEmpty) {
      _showSnackBar('Por favor, especifica un título para la actividad');
      return;
    }

    _showSnackBar(
      'Creando actividad: $title',
      action: SnackBarAction(
        label: 'Ir',
        onPressed: () {
          Navigator.of(context).pushNamed(
            '/create-activity',
            arguments: {
              'title': title,
              'category': category,
            },
          ).then((_) => controller.loadData());
        },
      ),
    );
  }

  Future<void> _handleCreateTimeBlock(VoiceCommand command) async {
    final title = command.parameters['title'] as String;
    final category = command.parameters['category'] as String;
    final time = command.parameters['time'] as String;

    if (title.isEmpty) {
      _showSnackBar('Por favor, especifica un título para el bloque de tiempo');
      return;
    }

    _showSnackBar(
      'Creando bloque: $title',
      action: SnackBarAction(
        label: 'Ir',
        onPressed: () {
          Navigator.of(context).pushNamed(
            '/create-timeblock',
            arguments: {
              'title': title,
              'category': category,
              'time': time,
            },
          ).then((_) => controller.loadData());
        },
      ),
    );
  }

  Future<void> _handleNavigate(VoiceCommand command) async {
    final destination = command.parameters['destination'] as String;
    debugPrint('Navegando a: $destination');

    switch (destination) {
      case 'activities':
        Navigator.of(context).pushNamed('/activities');
        break;
      case 'calendar':
        Navigator.of(context).pushNamed('/calendar');
        break;
      case 'timeblocks':
        Navigator.of(context).pushNamed('/timeblocks');
        break;
      case 'dashboard':
        // Ya estamos en el dashboard
        break;
      default:
        _showSnackBar('Destino no reconocido');
    }
  }

  Future<void> _handleMarkComplete(VoiceCommand command) async {
    final title = command.parameters['title'] as String;
    if (title.isEmpty) {
      _showSnackBar('Por favor, especifica el título de la actividad');
      return;
    }

    final matchingActivity = controller.activities.firstWhere(
      (activity) => activity.title.toLowerCase().contains(title.toLowerCase()),
      orElse: () => ActivityModel(
        id: '',
        title: '',
        description: '',
        isCompleted: false,
        startTime: DateTime.now(),
        endTime: DateTime.now(),
        category: '',
        priority: '',
      ),
    );

    if (matchingActivity.id.isNotEmpty) {
      controller.toggleActivityCompletion(matchingActivity.id);
      _showSnackBar(
          'Actividad "${matchingActivity.title}" marcada como completada');
    } else {
      _showSnackBar(
        'No se encontró la actividad "$title"',
        action: SnackBarAction(
          label: 'Ver todas',
          onPressed: () => Navigator.of(context).pushNamed('/activities'),
        ),
      );
    }
  }

  Future<void> _handleDelete(VoiceCommand command) async {
    final title = command.parameters['title'] as String;
    if (title.isEmpty) {
      _showSnackBar('Por favor, especifica el título de la actividad');
      return;
    }

    final activityToDelete = controller.activities.firstWhere(
      (activity) => activity.title.toLowerCase().contains(title.toLowerCase()),
      orElse: () => ActivityModel(
        id: '',
        title: '',
        description: '',
        isCompleted: false,
        startTime: DateTime.now(),
        endTime: DateTime.now(),
        category: '',
        priority: '',
      ),
    );

    if (activityToDelete.id.isNotEmpty) {
      controller.deleteActivity(activityToDelete.id);
      _showSnackBar('Actividad "${activityToDelete.title}" eliminada');
    } else {
      _showSnackBar(
        'No se encontró la actividad "$title"',
        action: SnackBarAction(
          label: 'Ver todas',
          onPressed: () => Navigator.of(context).pushNamed('/activities'),
        ),
      );
    }
  }

  void _showSnackBar(String message, {SnackBarAction? action}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        action: action,
      ),
    );
  }
}
