import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_styles.dart';
import '../../controllers/chat_ai_controller.dart';

/// Widget que muestra el estado de la integración ML-IA
class MLStatusIndicator extends StatelessWidget {
  final ChatAIController controller;

  const MLStatusIndicator({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final status = controller.getMLIntegrationStatus();
    final isMLEnabled = status['mlIntegrationEnabled'] as bool;
    final isContextLoaded = status['mlContextLoaded'] as bool;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isMLEnabled 
            ? AppColors.getBlue(isDarkMode).withOpacity(0.1)
            : AppColors.getSurface(isDarkMode),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isMLEnabled 
              ? AppColors.getBlue(isDarkMode).withOpacity(0.3)
              : AppColors.getSurface(isDarkMode),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isMLEnabled ? Icons.psychology : Icons.psychology_outlined,
            size: 16,
            color: isMLEnabled ? AppColors.getBlue(isDarkMode) : AppColors.getText(isDarkMode).withOpacity(0.6),
          ),
          const SizedBox(width: 6),
          Text(
            isMLEnabled ? 'ML Activo' : 'ML Básico',
            style: AppStyles.bodySmall.copyWith(
              color: isMLEnabled ? AppColors.getBlue(isDarkMode) : AppColors.getText(isDarkMode).withOpacity(0.6),
              fontWeight: FontWeight.w600,
            ),
          ),
          if (isContextLoaded) ...[
            const SizedBox(width: 4),
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: AppColors.getGreen(isDarkMode),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Widget expandible que muestra información detallada del estado ML-IA
class MLStatusExpanded extends StatelessWidget {
  final ChatAIController controller;

  const MLStatusExpanded({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final status = controller.getMLIntegrationStatus();

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.getSurface(isDarkMode),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.getSurface(isDarkMode),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: AppColors.getBlue(isDarkMode),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Estado de Integración ML-IA',
                style: AppStyles.titleMedium.copyWith(
                  color: AppColors.getText(isDarkMode),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          _buildStatusItem(
            'Integración ML-IA',
            status['mlIntegrationEnabled'] ? 'Habilitada' : 'Deshabilitada',
            status['mlIntegrationEnabled'] ? AppColors.getGreen(isDarkMode) : AppColors.getRed(isDarkMode),
            isDarkMode,
          ),
          
          _buildStatusItem(
            'Contexto ML',
            status['mlContextLoaded'] ? 'Cargado' : 'No cargado',
            status['mlContextLoaded'] ? AppColors.getGreen(isDarkMode) : AppColors.getRed(isDarkMode),
            isDarkMode,
          ),
          
          _buildStatusItem(
            'Servicio IA',
            status['aiServiceType'].toString().replaceAll('Instance of ', ''),
            AppColors.getBlue(isDarkMode),
            isDarkMode,
          ),
          
          _buildStatusItem(
            'Procesador ML',
            status['hasMLDataProcessor'] ? 'Disponible' : 'No disponible',
            status['hasMLDataProcessor'] ? AppColors.getGreen(isDarkMode) : AppColors.getRed(isDarkMode),
            isDarkMode,
          ),
          
          _buildStatusItem(
            'Servicio Integración',
            status['hasMLAIIntegrationService'] ? 'Disponible' : 'No disponible',
            status['hasMLAIIntegrationService'] ? AppColors.getGreen(isDarkMode) : AppColors.getRed(isDarkMode),
            isDarkMode,
          ),
          
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    controller.toggleMLIntegration(!controller.isMLIntegrationEnabled);
                  },
                  icon: Icon(
                    controller.isMLIntegrationEnabled ? Icons.toggle_on : Icons.toggle_off,
                    color: Colors.white,
                  ),
                  label: Text(
                    controller.isMLIntegrationEnabled ? 'Deshabilitar ML' : 'Habilitar ML',
                    style: AppStyles.bodyMedium.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: controller.isMLIntegrationEnabled ? AppColors.getRed(isDarkMode) : AppColors.getBlue(isDarkMode),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    controller.refreshMLIntegration();
                  },
                  icon: Icon(
                    Icons.refresh,
                    color: AppColors.getBlue(isDarkMode),
                  ),
                  label: Text(
                    'Actualizar',
                    style: AppStyles.bodyMedium.copyWith(
                      color: AppColors.getBlue(isDarkMode),
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppColors.getBlue(isDarkMode)),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusItem(String label, String value, Color valueColor, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppStyles.bodyMedium.copyWith(
              color: AppColors.getText(isDarkMode),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: valueColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              value,
              style: AppStyles.bodySmall.copyWith(
                color: valueColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
