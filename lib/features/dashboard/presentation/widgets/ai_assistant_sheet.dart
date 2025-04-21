import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../core/services/voice_command_service.dart';
import '../../../../core/constants/app_colors.dart';

class AIAssistantSheet extends StatefulWidget {
  final Function(VoiceCommand) onCommandRecognized;

  const AIAssistantSheet({
    super.key,
    required this.onCommandRecognized,
  });

  @override
  State<AIAssistantSheet> createState() => _AIAssistantSheetState();
}

class _AIAssistantSheetState extends State<AIAssistantSheet>
    with SingleTickerProviderStateMixin {
  late final VoiceCommandService _voiceService;
  String _partialText = '';
  String _lastCommand = '';
  String? _errorMessage;
  bool _isListening = false;
  late AnimationController _animationController;
  List<double> _soundLevels = List.filled(30, 0.0);
  bool _showHelp = false;

  @override
  void initState() {
    super.initState();
    _voiceService = VoiceCommandService();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();

    _voiceService.onPartialResult = (text) {
      setState(() {
        _partialText = text;
        _errorMessage = null;
      });
    };

    _voiceService.onCommandRecognized = (command) {
      setState(() {
        _lastCommand = 'Comando reconocido: ${_getCommandDescription(command)}';
        _errorMessage = null;
      });
      widget.onCommandRecognized(command);
    };

    _voiceService.onListeningStateChanged = (isListening) {
      setState(() => _isListening = isListening);
      if (isListening) {
        _startSoundAnimation();
      } else {
        _stopSoundAnimation();
      }
    };

    _voiceService.onError = (error) {
      setState(() => _errorMessage = error);
    };

    _voiceService.initialize();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  String _getCommandDescription(VoiceCommand command) {
    switch (command.type) {
      case VoiceCommandType.createActivity:
        return 'Crear actividad: ${command.parameters['title']}';
      case VoiceCommandType.createTimeBlock:
        return 'Crear bloque: ${command.parameters['title']}';
      case VoiceCommandType.markComplete:
        return 'Marcar como completa: ${command.parameters['title']}';
      case VoiceCommandType.delete:
        return 'Eliminar: ${command.parameters['title']}';
      case VoiceCommandType.navigate:
        return 'Navegar a: ${command.parameters['destination']}';
      case VoiceCommandType.unknown:
        return 'Comando no reconocido';
    }
  }

  void _startSoundAnimation() {
    _animationController.repeat();
    _updateSoundLevels();
  }

  void _stopSoundAnimation() {
    _animationController.stop();
    setState(() {
      _soundLevels = List.filled(30, 0.0);
    });
  }

  void _updateSoundLevels() {
    if (!_isListening) return;

    setState(() {
      for (int i = 0; i < _soundLevels.length - 1; i++) {
        _soundLevels[i] = _soundLevels[i + 1];
      }
      _soundLevels[_soundLevels.length - 1] =
          (0.5 + (0.5 * _animationController.value)) *
              (0.5 + 0.5 * _isListening.toString().length % 2);
    });

    Future.delayed(const Duration(milliseconds: 50), _updateSoundLevels);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppColors.surface0,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.surface2,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          _buildVoiceVisualization(),
          const SizedBox(height: 24),
          if (_errorMessage != null)
            Text(
              _errorMessage!,
              style: const TextStyle(
                color: AppColors.red,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            )
          else
            Text(
              _isListening ? _partialText : _lastCommand,
              style: const TextStyle(
                color: AppColors.text,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildMicButton(),
              const SizedBox(width: 16),
              IconButton(
                icon: Icon(
                  Icons.help_outline,
                  color: _showHelp ? AppColors.blue : AppColors.text,
                ),
                onPressed: () => setState(() => _showHelp = !_showHelp),
              ),
            ],
          ),
          if (_showHelp) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface1,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _voiceService.getHelpText(),
                style: const TextStyle(
                  color: AppColors.text,
                  fontSize: 14,
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildVoiceVisualization() {
    return SizedBox(
      height: 100,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(
          30,
          (index) => AnimatedContainer(
            duration: const Duration(milliseconds: 50),
            width: 4,
            height: 20 + (_soundLevels[index] * 80),
            margin: const EdgeInsets.symmetric(horizontal: 1),
            decoration: BoxDecoration(
              color: AppColors.blue.withOpacity(_isListening ? 1.0 : 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMicButton() {
    return GestureDetector(
      onTapDown: (_) async {
        if (!_isListening) {
          await _voiceService.startListening();
        }
      },
      onTapUp: (_) async {
        if (_isListening) {
          await _voiceService.stopListening();
        }
      },
      onTapCancel: () async {
        if (_isListening) {
          await _voiceService.stopListening();
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _isListening ? AppColors.blue : AppColors.surface1,
          boxShadow: [
            BoxShadow(
              color: _isListening
                  ? AppColors.blue.withOpacity(0.3)
                  : Colors.black.withOpacity(0.1),
              blurRadius: _isListening ? 16 : 8,
              spreadRadius: _isListening ? 4 : 0,
            ),
          ],
        ),
        child: Icon(
          _isListening ? Icons.mic : Icons.mic_none,
          color: _isListening ? Colors.white : AppColors.text,
          size: 32,
        ),
      ),
    );
  }
}

class SoundWavePainter extends CustomPainter {
  final List<double> soundLevels;
  final Color color;

  SoundWavePainter({required this.soundLevels, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    const maxRadius = 20.0;

    for (var i = 0; i < soundLevels.length; i++) {
      final radius = maxRadius * (1 + soundLevels[i] / 100);
      final angle = (i / soundLevels.length) * 2 * 3.14159;
      final x = center.dx + radius * cos(angle);
      final y = center.dy + radius * sin(angle);
      canvas.drawLine(center, Offset(x, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
