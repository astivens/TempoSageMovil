import 'package:integration_test/integration_test_driver.dart';
import 'dart:convert';
import 'dart:io';

Future<void> main() async {
  // Este driver captura las métricas de rendimiento
  await integrationDriver(
    responseDataCallback: (data) async {
      // Procesamos y guardamos los datos de rendimiento
      if (data != null) {
        print('Métricas capturadas: ${data.keys.length} datos');

        // Guardar datos en un archivo JSON para análisis posterior
        await File('performance_metrics.json').writeAsString(
          jsonEncode(data),
          flush: true,
        );

        print('Datos de rendimiento guardados en performance_metrics.json');
      }
    },
  );
}
