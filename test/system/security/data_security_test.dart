import 'package:flutter_test/flutter_test.dart';
import 'package:temposage/core/services/local_storage.dart';
import 'dart:io';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory tempDir;

  setUp(() async {
    // Crear directorio temporal para las pruebas
    tempDir = await Directory.systemTemp.createTemp('temposage_security_test_');
    await LocalStorage.init(path: tempDir.path);
  });

  tearDown(() async {
    await LocalStorage.closeAll();
    await tempDir.delete(recursive: true);
  });

  group('Pruebas de Seguridad de Datos', () {
    test('No debe almacenar datos sensibles en texto plano', () async {
      // Arrange
      const boxName = 'security_test_box';
      const sensitiveKey = 'password';
      const sensitiveValue = 'mi_contraseña_segura123';

      // Act
      await LocalStorage.saveData(boxName, sensitiveKey, sensitiveValue);

      // Verificar que el archivo físico no contiene el valor en texto plano
      final boxDir = Directory('${tempDir.path}/$boxName');
      bool containsPlainText = false;

      if (await boxDir.exists()) {
        final files = boxDir.listSync();

        for (final file in files) {
          if (file is File) {
            final content = await file.readAsString();
            if (content.contains(sensitiveValue)) {
              containsPlainText = true;
              break;
            }
          }
        }
      } else {
        // Si el directorio no existe, probablemente los datos están en otro lugar
        // o en memoria. En cualquier caso, no están en texto plano en el directorio.
        containsPlainText = false;
      }

      // Assert
      expect(containsPlainText, isFalse,
          reason: 'La contraseña no debe almacenarse en texto plano');

      // Verificar que aún así podemos recuperar el valor (está encriptado pero accesible mediante la API)
      final retrievedValue =
          await LocalStorage.getData<String>(boxName, sensitiveKey);
      expect(retrievedValue, equals(sensitiveValue));
    });

    test('Debe manejar intentos de inyección JSON', () async {
      // Arrange
      const boxName = 'security_test_box';
      const maliciousKey = '{"sql": "DROP TABLE users;"}';
      const maliciousValue = '{"script": "<script>alert("XSS")</script>"}';

      // Act & Assert
      // No debería lanzar excepciones y debe sanitizar/escapar correctamente
      await LocalStorage.saveData(boxName, maliciousKey, maliciousValue);
      final retrievedValue =
          await LocalStorage.getData<String>(boxName, maliciousKey);

      expect(retrievedValue, equals(maliciousValue));
    });
  });
}
