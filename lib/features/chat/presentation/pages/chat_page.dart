import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/chat_ai_controller.dart';
import '../../../../core/services/ollama_ai_service.dart';
import '../../../../services/google_ai_service.dart' show ChatResponse;
import '../../../../core/constants/app_styles.dart';
import '../../../../core/constants/app_colors.dart';

/// Página que muestra la interfaz de chat con IA
class ChatAIPage extends StatefulWidget {
  const ChatAIPage({super.key});

  @override
  State<ChatAIPage> createState() => _ChatAIPageState();
}

class _ChatAIPageState extends State<ChatAIPage> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<String> _quickPrompts = [
    '¿Qué actividades me recomiendas?',
    '¿Cómo puedo mejorar mi productividad?',
    '¿Qué tendencias ves en mis actividades?',
    '¿Puedes sugerirme un horario para mañana?',
  ];
  ChatAIController? _controller;

  @override
  void initState() {
    super.initState();
    _controller = ChatAIController(
      aiService: OllamaAIService(),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Siempre muestra la interfaz de chat IA
    return ChangeNotifierProvider.value(
      value: _controller,
      child: Scaffold(
        body: Column(
          children: [
            // Lista de mensajes
            Expanded(
              child: Consumer<ChatAIController>(
                builder: (context, controller, _) {
                  final messages = controller.messages;

                  // Si no hay mensajes, muestra un mensaje inicial y sugerencias
                  if (messages.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Haz una pregunta para comenzar la conversación',
                            style: AppStyles.bodyLarge.copyWith(
                              color: isDarkMode
                                  ? AppColors.getCatppuccinColor(context,
                                      colorName: 'subtext0')
                                  : AppColors.getCatppuccinColor(context,
                                      colorName: 'subtext0'),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 32),
                          Text(
                            'Sugerencias:',
                            style: AppStyles.bodyLarge.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            alignment: WrapAlignment.center,
                            children: _quickPrompts.map((prompt) {
                              return InkWell(
                                onTap: () {
                                  _textController.text = prompt;
                                  controller.sendMessage(prompt);
                                  _textController.clear();
                                },
                                borderRadius: BorderRadius.circular(20),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isDarkMode
                                        ? AppColors.getCatppuccinColor(context,
                                            colorName: 'surface1')
                                        : AppColors.getCatppuccinColor(context,
                                            colorName: 'surface1'),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    prompt,
                                    style: AppStyles.bodyMedium.copyWith(
                                      color: AppColors.getCatppuccinColor(
                                          context,
                                          colorName: 'text'),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    );
                  }

                  // Lista de mensajes
                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];

                      // Desplaza hacia abajo cuando se carga la vista
                      WidgetsBinding.instance
                          .addPostFrameCallback((_) => _scrollToBottom());

                      return _MessageBubble(message: message);
                    },
                  );
                },
              ),
            ),

            // Indicador de carga
            Consumer<ChatAIController>(
              builder: (context, controller, _) {
                if (controller.isLoading) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.0,
                          color: AppColors.getCatppuccinColor(context,
                              colorName: 'blue'),
                        ),
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),

            // Mostrar error si existe
            Consumer<ChatAIController>(
              builder: (context, controller, _) {
                if (controller.errorMessage != null) {
                  return Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    decoration: BoxDecoration(
                      color: isDarkMode
                          ? AppColors.getCatppuccinColor(context,
                                  colorName: 'red')
                              .withAlpha((255 * 0.2).toInt())
                          : AppColors.getCatppuccinColor(context,
                                  colorName: 'red')
                              .withAlpha((255 * 0.1).toInt()),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.getCatppuccinColor(context,
                                colorName: 'red')
                            .withAlpha((255 * 0.3).toInt()),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: AppColors.getCatppuccinColor(context,
                              colorName: 'red'),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            controller.errorMessage!,
                            style: AppStyles.bodyMedium.copyWith(
                              color: AppColors.getCatppuccinColor(context,
                                  colorName: 'red'),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.close,
                            color: AppColors.getCatppuccinColor(context,
                                colorName: 'red'),
                            size: 20,
                          ),
                          onPressed: () {
                            controller.clearConversation();
                          },
                        ),
                      ],
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),

            // Campo de entrada de texto
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: isDarkMode
                            ? AppColors.getCatppuccinColor(context,
                                colorName: 'surface0')
                            : AppColors.getCatppuccinColor(context,
                                colorName: 'surface0'),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: TextField(
                        controller: _textController,
                        decoration: InputDecoration(
                          hintText: 'Escribe tu mensaje...',
                          hintStyle: AppStyles.bodyMedium.copyWith(
                            color: isDarkMode
                                ? AppColors.getCatppuccinColor(context,
                                    colorName: 'overlay0')
                                : AppColors.getCatppuccinColor(context,
                                    colorName: 'overlay0'),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        minLines: 1,
                        maxLines: 4,
                        textCapitalization: TextCapitalization.sentences,
                        style: AppStyles.bodyMedium,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Consumer<ChatAIController>(
                    builder: (context, controller, _) {
                      return Container(
                        decoration: BoxDecoration(
                          color: controller.isLoading
                              ? AppColors.getCatppuccinColor(context,
                                      colorName: 'blue')
                                  .withAlpha((255 * 0.5).toInt())
                              : AppColors.getCatppuccinColor(context,
                                  colorName: 'blue'),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.send),
                          color: Colors.white,
                          onPressed: controller.isLoading
                              ? null
                              : () {
                                  final message = _textController.text.trim();
                                  if (message.isNotEmpty) {
                                    controller.sendMessage(message);
                                    _textController.clear();
                                  }
                                },
                        ),
                      );
                    },
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

/// Widget para mostrar un mensaje en la conversación
class _MessageBubble extends StatelessWidget {
  final ChatResponse message;

  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == 'user';
    final isError = message.role == 'error';
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    Color bubbleColor;
    if (isError) {
      bubbleColor = AppColors.getCatppuccinColor(context, colorName: 'red')
          .withAlpha((255 * 0.2).toInt());
    } else if (isUser) {
      bubbleColor = AppColors.getCatppuccinColor(context, colorName: 'blue')
          .withAlpha((255 * 0.15).toInt());
    } else {
      bubbleColor = isDarkMode
          ? AppColors.getCatppuccinColor(context, colorName: 'surface1')
          : AppColors.getCatppuccinColor(context, colorName: 'surface1');
    }

    Color textColor = isError
        ? AppColors.getCatppuccinColor(context, colorName: 'red')
        : AppColors.getCatppuccinColor(context, colorName: 'text');

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.circular(16),
          border: !isUser && !isError
              ? Border.all(
                  color: isDarkMode
                      ? AppColors.getCatppuccinColor(context,
                          colorName: 'surface2')
                      : AppColors.getCatppuccinColor(context,
                          colorName: 'surface2'),
                  width: 1,
                )
              : null,
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.text,
              style: AppStyles.bodyMedium.copyWith(
                color: textColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _formatTime(message.timestamp),
              style: AppStyles.bodySmall.copyWith(
                color: isDarkMode
                    ? AppColors.getCatppuccinColor(context,
                        colorName: 'subtext0')
                    : AppColors.getCatppuccinColor(context,
                        colorName: 'subtext0'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}
