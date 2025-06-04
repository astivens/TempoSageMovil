import 'dart:io';
import 'dart:math' as math;
import 'dart:async';
import 'dart:convert';

/// Aplicación de consola para ejecutar pruebas en TempoSage
///
/// Esta aplicación proporciona una interfaz amigable para ejecutar
/// diferentes tipos de pruebas en el proyecto TempoSage.
void main(List<String> args) async {
  final runner = TestRunner();

  // Verificar entorno de desarrollo
  await runner.verifyEnvironment();

  if (args.isNotEmpty) {
    // Modo de línea de comandos con argumentos
    await runner.runWithArgs(args);
  } else {
    // Modo interactivo
    await runner.runInteractive();
  }
}

/// Clase principal que maneja la ejecución de pruebas
class TestRunner {
  // Niveles de log
  static const int LOG_LEVEL_DEBUG = 0;
  static const int LOG_LEVEL_INFO = 1;
  static const int LOG_LEVEL_WARNING = 2;
  static const int LOG_LEVEL_ERROR = 3;

  // Nivel de log actual (puede cambiarse con variables de entorno)
  int _currentLogLevel = LOG_LEVEL_INFO;

  // Colores para la salida en consola
  static const String resetColor = '\x1B[0m';
  static const String redColor = '\x1B[31m';
  static const String greenColor = '\x1B[32m';
  static const String yellowColor = '\x1B[33m';
  static const String blueColor = '\x1B[34m';
  static const String magentaColor = '\x1B[35m';
  static const String cyanColor = '\x1B[36m';
  static const String whiteColor = '\x1B[37m';
  static const String grayColor = '\x1B[90m';
  static const String boldText = '\x1B[1m';
  static const String underlineText = '\x1B[4m';
  static const String blinkText = '\x1B[5m';

  // Símbolos para resultados
  static const String successSymbol = '✓';
  static const String failSymbol = '✗';
  static const String warnSymbol = '⚠';
  static const String pendingSymbol = '○';
  static const String runningSymbol = '⟳';
  static const String skippedSymbol = '⇝';
  static const String blockFilled = '█';
  static const String blockEmpty = '░';

  // Categorías de pruebas
  final Map<String, TestCategory> categories = {
    '1': TestCategory(
      name: 'Pruebas Unitarias',
      description: 'Pruebas de lógica y componentes individuales',
      options: {
        '1': TestOption(
          name: 'Todas las pruebas unitarias',
          command: 'flutter test test/unit/',
        ),
        '2': TestOption(
          name: 'Pruebas de modelos',
          command: 'flutter test test/unit/models/',
        ),
        '3': TestOption(
          name: 'Pruebas de repositorios',
          command: 'flutter test test/unit/repositories/',
        ),
        '4': TestOption(
          name: 'Pruebas de servicios',
          command: 'flutter test test/unit/services/',
        ),
        '5': TestOption(
          name: 'Pruebas de utilidades',
          command: 'flutter test test/unit/utils/',
        ),
        '6': TestOption(
          name: 'Suite de ejemplos (con fallos)',
          command: 'flutter test test/unit/example_test_suite.dart',
        ),
      },
    ),
    '2': TestCategory(
      name: 'Pruebas de Widget',
      description: 'Pruebas de componentes visuales',
      options: {
        '1': TestOption(
          name: 'Todas las pruebas de widgets',
          command: 'flutter test test/widget/',
        ),
      },
    ),
    '3': TestCategory(
      name: 'Pruebas de Rendimiento',
      description: 'Análisis de rendimiento y eficiencia',
      options: {
        '1': TestOption(
          name: 'Todas las pruebas de rendimiento',
          command: './run_tests.sh --performance',
        ),
        '2': TestOption(
          name: 'Rendimiento de repositorio',
          command:
              'flutter test test/performance/repository_benchmark_test.dart',
        ),
        '3': TestOption(
          name: 'Uso de memoria',
          command: 'flutter test test/performance/memory_test.dart',
        ),
      },
    ),
    '4': TestCategory(
      name: 'Pruebas de Integración',
      description: 'Pruebas end-to-end y de integración',
      options: {
        '1': TestOption(
          name: 'Todas las pruebas de integración',
          command: 'flutter test test/integration/',
        ),
        '2': TestOption(
          name: 'Pruebas de UI en dispositivo',
          command:
              'flutter drive --driver=test_driver/integration_test_driver.dart --target=integration_test/performance/ui_performance_test.dart --profile',
          requiresDevice: true,
        ),
      },
    ),
    '5': TestCategory(
      name: 'Pruebas de Sistemas',
      description: 'Verificación del comportamiento del sistema completo',
      options: {
        '1': TestOption(
          name: 'Todas las pruebas de sistemas',
          command: 'flutter test test/system/',
        ),
        '2': TestOption(
          name: 'Pruebas de seguridad',
          command: 'flutter test test/system/security/',
        ),
        '3': TestOption(
          name: 'Pruebas de portabilidad',
          command: 'flutter test test/system/portability/',
        ),
        '4': TestOption(
          name: 'Pruebas de usabilidad',
          command: 'flutter test test/system/usability/',
        ),
      },
    ),
    '6': TestCategory(
      name: 'Pruebas de Aceptación',
      description: 'Validación de requisitos con usuarios finales',
      options: {
        '1': TestOption(
          name: 'Todas las pruebas de aceptación',
          command: 'flutter test test/acceptance/',
        ),
        '2': TestOption(
          name: 'Pruebas de aceptación con Gherkin',
          command: 'flutter test test/acceptance/gherkin/',
        ),
      },
    ),
    '7': TestCategory(
      name: 'Pruebas Completas',
      description: 'Ejecutar todas las pruebas',
      options: {
        '1': TestOption(
          name: 'Todas las pruebas',
          command: './run_tests.sh',
        ),
        '2': TestOption(
          name: 'Todas las pruebas con cobertura',
          command: './run_tests.sh --coverage',
        ),
      },
    ),
    '8': TestCategory(
      name: 'Utilidades',
      description: 'Herramientas auxiliares para pruebas',
      options: {
        '1': TestOption(
          name: 'Limpiar proyecto',
          command: 'flutter clean && flutter pub get',
        ),
        '2': TestOption(
          name: 'Verificar dispositivos conectados',
          command: 'flutter devices',
        ),
        '3': TestOption(
          name: 'Generar informe de cobertura HTML',
          command:
              'flutter test --coverage && genhtml coverage/lcov.info -o coverage/html',
        ),
        '4': TestOption(
          name: 'Verificar entorno de desarrollo',
          command: 'flutter doctor -v',
        ),
      },
    ),
  };

  TestRunner() {
    // Inicializar nivel de log desde variable de entorno
    final logLevel = Platform.environment['TS_LOG_LEVEL'];
    if (logLevel != null) {
      switch (logLevel.toLowerCase()) {
        case 'debug':
          _currentLogLevel = LOG_LEVEL_DEBUG;
          break;
        case 'info':
          _currentLogLevel = LOG_LEVEL_INFO;
          break;
        case 'warning':
          _currentLogLevel = LOG_LEVEL_WARNING;
          break;
        case 'error':
          _currentLogLevel = LOG_LEVEL_ERROR;
          break;
      }
    }
  }

  /// Verifica el entorno de desarrollo
  Future<void> verifyEnvironment() async {
    _logDebug('Verificando entorno de desarrollo...');

    // Verificar Flutter
    try {
      final flutterResult = await Process.run('flutter', ['--version']);
      if (flutterResult.exitCode != 0) {
        _printError('Error: Flutter no está instalado o accesible en el PATH.');
        _printError(
            'Por favor, instale Flutter desde https://flutter.dev/docs/get-started/install');
        exit(1);
      } else {
        _logDebug(
            'Flutter instalado: ${flutterResult.stdout.toString().trim()}');
      }
    } catch (e) {
      _printError('Error: No se pudo verificar la instalación de Flutter.');
      _printError(
          'Por favor, asegúrese de que Flutter esté instalado y en el PATH.');
      exit(1);
    }

    // Verificar la existencia de directorios clave
    final directories = [
      'lib',
      'test',
      'test/unit',
      'test/widget',
      'test/integration',
    ];

    for (final dir in directories) {
      final dirExists = await Directory(dir).exists();
      if (!dirExists) {
        _logWarning('Advertencia: El directorio $dir no existe.');
      } else {
        _logDebug('Directorio $dir encontrado.');
      }
    }

    // Verificar archivos de prueba importantes
    final testFiles = [
      'run_tests.sh',
    ];

    for (final file in testFiles) {
      final fileExists = await File(file).exists();
      if (!fileExists) {
        _logWarning('Advertencia: El archivo $file no existe.');
      } else {
        _logDebug('Archivo $file encontrado.');
      }
    }

    _logDebug('Verificación de entorno completada.');
  }

  /// Ejecuta el runner en modo interactivo
  Future<void> runInteractive() async {
    _clearScreen();
    _printHeader();

    bool exit = false;
    while (!exit) {
      _printMainMenu();

      final option = stdin.readLineSync()?.trim() ?? '';

      if (option == 'q' || option == 'Q') {
        exit = true;
        continue;
      }

      if (categories.containsKey(option)) {
        await _handleCategorySelection(categories[option]!);
      } else {
        _printError('Opción no válida. Intente de nuevo.');
        await _waitForKeyPress();
      }
    }

    _printSuccess('¡Gracias por usar el Test Runner de TempoSage!');
  }

  /// Ejecuta comandos basados en argumentos de línea de comandos
  Future<void> runWithArgs(List<String> args) async {
    if (args.contains('--help') || args.contains('-h')) {
      _printUsage();
      return;
    }

    if (args.length < 2) {
      _printError('Error: Se requieren al menos 2 argumentos.');
      _printUsage();
      return;
    }

    final categoryKey = args[0];
    final optionKey = args[1];

    if (!categories.containsKey(categoryKey)) {
      _printError('Error: Categoría no válida: $categoryKey');
      _printAvailableCategories();
      return;
    }

    final category = categories[categoryKey]!;
    if (!category.options.containsKey(optionKey)) {
      _printError(
          'Error: Opción no válida: $optionKey para categoría $categoryKey');
      _printAvailableOptions(category);
      return;
    }

    final option = category.options[optionKey]!;
    await _executeTestOption(option);
  }

  /// Maneja la selección de una categoría
  Future<void> _handleCategorySelection(TestCategory category) async {
    bool backToMain = false;

    while (!backToMain) {
      _clearScreen();
      _printCategoryHeader(category);
      _printCategoryOptions(category);

      final option = stdin.readLineSync()?.trim() ?? '';

      if (option == 'b' || option == 'B') {
        backToMain = true;
        continue;
      }

      if (category.options.containsKey(option)) {
        await _executeTestOption(category.options[option]!);
        await _waitForKeyPress();
      } else {
        _printError('Opción no válida. Intente de nuevo.');
        await _waitForKeyPress();
      }
    }
  }

  /// Ejecuta una opción de prueba
  Future<void> _executeTestOption(TestOption option) async {
    _clearScreen();

    // Mostrar título de la prueba
    _printTestHeader(option.name);

    _printInfo('Comando: ${option.command}');
    print('');

    if (option.requiresDevice) {
      print(
          '${yellowColor}${runningSymbol} Verificando dispositivos conectados...${resetColor}');
      final hasDevice = await _checkForConnectedDevices();
      if (!hasDevice) {
        _printError('Error: Esta prueba requiere un dispositivo conectado.');
        return;
      }
      print(
          '${greenColor}${successSymbol} Dispositivo conectado detectado.${resetColor}\n');
    }

    try {
      _logDebug('[DEBUG] Iniciando ejecución del comando: ${option.command}');

      print(
          '${yellowColor}${runningSymbol} Ejecutando pruebas...${resetColor}');

      final stopwatch = Stopwatch()..start();

      // Crear un TestResult para almacenar información sobre los resultados
      final testResult = TestResult();
      testResult.startTime = DateTime.now();

      // Usar Process.start en lugar de Process.run para capturar la salida en tiempo real
      final process = await Process.start('bash', ['-c', option.command]);

      // Buffers para capturar la salida
      final outputBuffer = StringBuffer();
      final testLines = <String>[];

      // Variables para el seguimiento del progreso
      String currentTest = '';
      int passedCount = 0;
      int failedCount = 0;
      int skippedCount = 0;
      int totalCount = 0;
      bool inTestOutput = false;

      // Establecer un temporizador para actualizar el indicador de progreso cada 100ms
      Timer? progressTimer;
      progressTimer = Timer.periodic(Duration(milliseconds: 100), (timer) {
        if (currentTest.isNotEmpty) {
          _updateProgress(
              passedCount, failedCount, skippedCount, totalCount, currentTest);
        }
      });

      // Procesar stdout en tiempo real
      process.stdout.transform(utf8.decoder).listen((data) {
        outputBuffer.write(data);

        // Analizar líneas para extraer información de pruebas
        final lines = data.split('\n');
        for (final line in lines) {
          if (line.isEmpty) continue;

          testLines.add(line);

          // Detectar inicio de nueva prueba
          if (line.contains('test') && !inTestOutput) {
            final testNameMatch = RegExp(r'test (.*?)( \{|$)').firstMatch(line);
            if (testNameMatch != null) {
              currentTest = testNameMatch.group(1) ?? 'Test desconocido';
              totalCount++;
              inTestOutput = true;
              _updateProgress(passedCount, failedCount, skippedCount,
                  totalCount, currentTest);
            }
          }

          // Detectar resultado de prueba
          if (line.contains('✓') ||
              line.contains('PASS') ||
              line.contains('OK')) {
            passedCount++;
            inTestOutput = false;
          } else if (line.contains('✗') ||
              line.contains('FAIL') ||
              line.contains('ERROR')) {
            failedCount++;
            inTestOutput = false;
          } else if (line.contains('SKIP') || line.contains('IGNORED')) {
            skippedCount++;
            inTestOutput = false;
          }
        }
      });

      // Procesar stderr en tiempo real
      process.stderr.transform(utf8.decoder).listen((data) {
        outputBuffer.write(data);
      });

      // Esperar a que termine el proceso
      final exitCode = await process.exitCode;

      // Cancelar el temporizador de progreso
      progressTimer.cancel();
      progressTimer = null;

      // Limpiar la línea de progreso
      stdout.write('\r${' ' * _getTerminalWidth()}\r');

      stopwatch.stop();
      testResult.duration = stopwatch.elapsed;
      testResult.exitCode = exitCode;

      // Establecer número total de pruebas
      testResult.totalTests = totalCount;
      testResult.passedTests = passedCount;
      testResult.failedTests = failedCount;
      testResult.skippedTests = skippedCount;

      _logDebug(
          '[DEBUG] Comando completado en ${stopwatch.elapsed.inSeconds} segundos.');

      // Analizar la salida completa para obtener más detalles
      final output = outputBuffer.toString();
      _parseTestOutput(output, testResult);

      // Mostrar un resumen visual
      _printTestSummary(testResult);

      // Si hay fallos, mostrar los detalles específicos de los fallos
      if (testResult.failedTests > 0) {
        _printTestFailureDetails(output);
      }

      // Mostrar barra de resultado final
      _printResultBar(exitCode == 0);

      if (exitCode == 0) {
        _printSuccess(
            'Prueba completada exitosamente en ${_formatDuration(stopwatch.elapsed)}');
      } else {
        _printError(
            'La prueba falló con código ${exitCode} (${_formatDuration(stopwatch.elapsed)})');
      }

      // Mostrar estadísticas detalladas y lista completa de pruebas
      _printTestStatistics(testResult);

      // Guardar los resultados en un archivo si es extenso
      if (testResult.testDetails.length > 20) {
        await _saveTestResultsToFile(testResult, option.name);
      }
    } catch (e) {
      _printError('Error al ejecutar la prueba: $e');
    }
  }

  /// Actualiza la visualización del progreso de las pruebas en la consola
  void _updateProgress(
      int passed, int failed, int skipped, int total, String currentTest) {
    // Obtener el ancho de la terminal
    final width = _getTerminalWidth();

    // Calcular el progreso
    final completed = passed + failed + skipped;
    final progress = total > 0 ? completed / total : 0.0;

    // Crear barra de progreso
    final barWidth = width - 30;
    final completedWidth = (barWidth * progress).round();
    final barChars = StringBuffer();

    // Añadir sección completada con colores según el resultado
    for (int i = 0; i < completedWidth; i++) {
      if (i < passed) {
        barChars.write('${greenColor}${blockFilled}${resetColor}');
      } else if (i < passed + failed) {
        barChars.write('${redColor}${blockFilled}${resetColor}');
      } else {
        barChars.write('${yellowColor}${blockFilled}${resetColor}');
      }
    }

    // Añadir resto de la barra
    final remainingWidth = barWidth - completedWidth;
    barChars.write('${grayColor}${blockEmpty * remainingWidth}${resetColor}');

    // Crear información de progreso
    final progressInfo = '$completed/$total';

    // Truncar el nombre de la prueba si es demasiado largo
    String testName = currentTest;
    final maxTestNameLength = width - barWidth - progressInfo.length - 10;
    if (testName.length > maxTestNameLength) {
      testName = testName.substring(0, maxTestNameLength - 3) + '...';
    }

    // Imprimir la línea de progreso
    stdout.write(
        '\r${yellowColor}Ejecutando:${resetColor} $testName ${barChars.toString()} $progressInfo');
  }

  /// Analiza la salida de la prueba para extraer estadísticas
  void _parseTestOutput(String output, TestResult result) {
    // Extraer número total de pruebas
    final totalTestsRegex = RegExp(r'(\d+) tests?');
    final totalTestsMatch = totalTestsRegex.firstMatch(output);
    if (totalTestsMatch != null) {
      result.totalTests = int.parse(totalTestsMatch.group(1) ?? '0');
    }

    // Extraer pruebas pasadas
    final passedTestsRegex = RegExp(r'All tests passed!|(\d+) passing');
    final passedTestsMatch = passedTestsRegex.firstMatch(output);
    if (passedTestsMatch != null) {
      if (passedTestsMatch.group(0) == 'All tests passed!') {
        result.passedTests = result.totalTests;
      } else {
        result.passedTests = int.parse(passedTestsMatch.group(1) ?? '0');
      }
    }

    // Extraer pruebas fallidas
    final failedTestsRegex = RegExp(r'(\d+) (failed|failing)');
    final failedTestsMatch = failedTestsRegex.firstMatch(output);
    if (failedTestsMatch != null) {
      result.failedTests = int.parse(failedTestsMatch.group(1) ?? '0');
    } else {
      result.failedTests = result.totalTests - result.passedTests;
    }

    // Extraer pruebas omitidas
    final skippedTestsRegex = RegExp(r'(\d+) skipped');
    final skippedTestsMatch = skippedTestsRegex.firstMatch(output);
    if (skippedTestsMatch != null) {
      result.skippedTests = int.parse(skippedTestsMatch.group(1) ?? '0');
    }

    // Si no encontramos el total pero tenemos pasados y fallidos
    if (result.totalTests == 0 &&
        (result.passedTests > 0 || result.failedTests > 0)) {
      result.totalTests =
          result.passedTests + result.failedTests + result.skippedTests;
    }

    // Extraer detalles de todas las pruebas (no solo fallidas)
    _extractTestDetails(output, result);
  }

  /// Extrae los detalles de todas las pruebas individuales
  void _extractTestDetails(String output, TestResult result) {
    final lines = output.split('\n');

    // Buscar líneas que contengan descripciones de pruebas
    String currentGroup = '';

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].trim();

      // Detectar grupo de pruebas
      if (line.startsWith('group(') ||
          line.contains('Running suite:') ||
          line.contains('describe(')) {
        // Extraer nombre del grupo
        if (line.contains('Running suite:')) {
          currentGroup = line.replaceAll('Running suite:', '').trim();
        } else {
          // Buscar texto entre comillas
          final singleQuoteMatch = RegExp("'(.*?)'").firstMatch(line);
          final doubleQuoteMatch = RegExp('"(.*?)"').firstMatch(line);

          if (singleQuoteMatch != null) {
            currentGroup = singleQuoteMatch.group(1) ?? '';
          } else if (doubleQuoteMatch != null) {
            currentGroup = doubleQuoteMatch.group(1) ?? '';
          }
        }
        continue;
      }

      // Detectar prueba individual
      bool isPassed =
          line.contains('✓') || line.contains('[+]') || line.contains('PASSED');
      bool isFailed =
          line.contains('✗') || line.contains('[-]') || line.contains('FAILED');
      bool isSkipped = line.contains('○') ||
          line.contains('[~]') ||
          line.contains('SKIPPED');

      if (isPassed || isFailed || isSkipped) {
        TestInfo testInfo = TestInfo();
        testInfo.group = currentGroup;

        // Extraer descripción de la prueba
        final testNameRegex = RegExp(
            r'(?:✓|✗|○|\[\+\]|\[-\]|\[~\]|PASSED|FAILED|SKIPPED)\s*(.+?)(?:\s+\(\d+\:\d+\))?\s*$');
        final testNameMatch = testNameRegex.firstMatch(line);

        if (testNameMatch != null) {
          testInfo.name = testNameMatch.group(1)?.trim() ?? 'Prueba sin nombre';
        } else {
          testInfo.name = line.trim();
        }

        // Determinar estado
        if (isPassed) {
          testInfo.status = TestStatus.passed;
        } else if (isFailed) {
          testInfo.status = TestStatus.failed;

          // Buscar detalles del fallo en las líneas siguientes
          int j = i + 1;
          while (j < lines.length && j < i + 15) {
            final detailLine = lines[j].trim();

            if (detailLine.contains('Expected:')) {
              testInfo.expected =
                  detailLine.replaceFirst('Expected:', '').trim();
            } else if (detailLine.contains('Actual:')) {
              testInfo.actual = detailLine.replaceFirst('Actual:', '').trim();
            } else if (detailLine.contains('package:') ||
                detailLine.contains('at ')) {
              // Capturar la primera línea de stack trace como ubicación
              if (testInfo.location.isEmpty) {
                testInfo.location = detailLine.trim();
              }
            } else if (detailLine.contains('message:') ||
                (detailLine.startsWith('"') && detailLine.endsWith('"'))) {
              testInfo.message = detailLine.replaceFirst('message:', '').trim();
            }

            j++;
          }
        } else {
          testInfo.status = TestStatus.skipped;
        }

        // Tiempo de ejecución (si está disponible)
        final timeMatch = RegExp(r'\((\d+\.\d+)s\)').firstMatch(line);
        if (timeMatch != null) {
          final seconds = double.tryParse(timeMatch.group(1) ?? '0');
          if (seconds != null) {
            testInfo.duration =
                Duration(milliseconds: (seconds * 1000).round());
          }
        }

        // Guardar la información de la prueba
        result.testDetails.add(testInfo);
      }
    }

    // Si encontramos pruebas individuales pero no tenemos totales, actualizar los contadores
    if (result.totalTests == 0 && result.testDetails.isNotEmpty) {
      result.totalTests = result.testDetails.length;
      result.passedTests =
          result.testDetails.where((t) => t.status == TestStatus.passed).length;
      result.failedTests =
          result.testDetails.where((t) => t.status == TestStatus.failed).length;
      result.skippedTests = result.testDetails
          .where((t) => t.status == TestStatus.skipped)
          .length;
    }

    // Guardar los nombres de las pruebas fallidas (para compatibilidad)
    result.failedTestNames = result.testDetails
        .where((t) => t.status == TestStatus.failed)
        .map((t) => t.name)
        .toList();
  }

  /// Imprime un encabezado para la prueba
  void _printTestHeader(String testName) {
    final terminalWidth = _getTerminalWidth();
    final padding = math.max(0, (terminalWidth - testName.length - 10) ~/ 2);
    final paddingStr = ' ' * padding;

    print('');
    print(
        '${cyanColor}${boldText}${underlineText}$paddingStr$testName$paddingStr${resetColor}');
    print('');
  }

  /// Imprime un resumen visual de los resultados de la prueba
  void _printTestSummary(TestResult result) {
    if (result.totalTests == 0) {
      print(
          '\n${yellowColor}${warnSymbol} No se detectaron pruebas en la salida.${resetColor}');
      return;
    }

    print('\n${boldText}${cyanColor}Resumen de pruebas:${resetColor}');

    // Barra de progreso
    final terminalWidth = _getTerminalWidth() - 10;
    final barWidth = math.min(50, terminalWidth);

    if (result.totalTests > 0) {
      final passedWidth =
          (barWidth * result.passedTests / result.totalTests).round();
      final failedWidth =
          (barWidth * result.failedTests / result.totalTests).round();
      final skippedWidth =
          (barWidth * result.skippedTests / result.totalTests).round();
      final remainingWidth =
          barWidth - passedWidth - failedWidth - skippedWidth;

      final passedBar = passedWidth > 0
          ? '${greenColor}${blockFilled * passedWidth}${resetColor}'
          : '';
      final failedBar = failedWidth > 0
          ? '${redColor}${blockFilled * failedWidth}${resetColor}'
          : '';
      final skippedBar = skippedWidth > 0
          ? '${yellowColor}${blockFilled * skippedWidth}${resetColor}'
          : '';
      final remainingBar = remainingWidth > 0
          ? '${grayColor}${blockEmpty * remainingWidth}${resetColor}'
          : '';

      print('$passedBar$failedBar$skippedBar$remainingBar');

      // Resultados numéricos
      print(
          '${greenColor}${successSymbol} Pasadas: ${result.passedTests}/${result.totalTests} (${(result.passedTests / result.totalTests * 100).toStringAsFixed(1)}%)${resetColor}');

      if (result.failedTests > 0) {
        print(
            '${redColor}${failSymbol} Fallidas: ${result.failedTests}/${result.totalTests} (${(result.failedTests / result.totalTests * 100).toStringAsFixed(1)}%)${resetColor}');
      }

      if (result.skippedTests > 0) {
        print(
            '${yellowColor}${skippedSymbol} Omitidas: ${result.skippedTests}/${result.totalTests} (${(result.skippedTests / result.totalTests * 100).toStringAsFixed(1)}%)${resetColor}');
      }
    }

    print('');
  }

  /// Imprime detalles sobre las pruebas fallidas
  void _printTestFailureDetails(String output) {
    print('${boldText}${redColor}Detalles de fallos:${resetColor}');

    // Buscar líneas que contengan fallos de prueba
    final lines = output.split('\n');
    bool inFailureBlock = false;
    int contextLines = 0;

    for (final line in lines) {
      // Detectar inicio de bloque de fallo
      if (line.contains('✗') ||
          line.contains('FAILED') ||
          line.contains('Failure') ||
          line.contains('failed')) {
        inFailureBlock = true;
        contextLines = 0;
        print('  ${redColor}${line.trim()}${resetColor}');
        continue;
      }

      // Mostrar contexto del fallo
      if (inFailureBlock) {
        contextLines++;

        // Formatear diferentes partes del mensaje de error
        if (line.contains('Expected:')) {
          print('  ${greenColor}${line.trim()}${resetColor}');
        } else if (line.contains('Actual:')) {
          print('  ${redColor}${line.trim()}${resetColor}');
        } else if (line.contains('package:')) {
          print('  ${grayColor}${line.trim()}${resetColor}');
        } else if (line.trim().isEmpty) {
          print('');
        } else {
          print('  ${line.trim()}');
        }

        // Terminar bloque después de mostrar suficiente contexto
        if (contextLines > 5 && line.trim().isEmpty) {
          inFailureBlock = false;
          print('');
        }
      }
    }

    print('');
  }

  /// Imprime un resumen detallado de todas las pruebas ejecutadas
  void _printTestStatistics(TestResult result) {
    if (result.totalTests == 0) {
      return;
    }

    print('\n${boldText}${cyanColor}Estadísticas de ejecución:${resetColor}');
    print('  Tiempo total: ${_formatDuration(result.duration)}');

    if (result.totalTests > 0 && result.duration.inMilliseconds > 0) {
      final timePerTest = result.duration.inMilliseconds / result.totalTests;
      print(
          '  Tiempo promedio por prueba: ${(timePerTest / 1000).toStringAsFixed(2)}s');
    }

    // Mostrar hora de inicio y fin
    final endTime = result.startTime.add(result.duration);
    print('  Inicio: ${_formatDateTime(result.startTime)}');
    print('  Fin: ${_formatDateTime(endTime)}');

    // Mostrar detalles de cada prueba ejecutada
    if (result.testDetails.isNotEmpty) {
      _printAllTestDetails(result);
    }

    print('');
  }

  /// Imprime detalles de todas las pruebas ejecutadas
  void _printAllTestDetails(TestResult result) {
    print(
        '\n${boldText}${cyanColor}Detalles de todas las pruebas ejecutadas:${resetColor}');

    // Agrupar pruebas por grupo para mejor organización
    final groupedTests = <String, List<TestInfo>>{};

    for (final test in result.testDetails) {
      final group = test.group.isEmpty ? 'Sin grupo' : test.group;
      if (!groupedTests.containsKey(group)) {
        groupedTests[group] = [];
      }
      groupedTests[group]!.add(test);
    }

    // Imprimir cada grupo y sus pruebas
    groupedTests.forEach((group, tests) {
      print('\n${boldText}${cyanColor}Grupo: ${group}${resetColor}');

      // Ordenar pruebas: primero fallidas, luego pasadas, luego omitidas
      tests.sort((a, b) {
        if (a.status != b.status) {
          // Orden de prioridad: fallidas, pasadas, omitidas
          final statusOrder = {
            TestStatus.failed: 0,
            TestStatus.passed: 1,
            TestStatus.skipped: 2,
          };
          return statusOrder[a.status]!.compareTo(statusOrder[b.status]!);
        }
        return a.name.compareTo(b.name);
      });

      for (final test in tests) {
        // Determinar color e ícono según estado
        String icon;
        String color;

        switch (test.status) {
          case TestStatus.passed:
            icon = successSymbol;
            color = greenColor;
            break;
          case TestStatus.failed:
            icon = failSymbol;
            color = redColor;
            break;
          case TestStatus.skipped:
            icon = skippedSymbol;
            color = yellowColor;
            break;
        }

        // Mostrar nombre y estado de la prueba
        print(
            '  $color$icon ${test.name}${resetColor} ${_getDurationText(test.duration)}');

        // Para pruebas fallidas, mostrar detalles adicionales
        if (test.status == TestStatus.failed) {
          if (test.expected.isNotEmpty) {
            print('    ${greenColor}Esperado: ${test.expected}${resetColor}');
          }
          if (test.actual.isNotEmpty) {
            print('    ${redColor}Obtenido: ${test.actual}${resetColor}');
          }
          if (test.message.isNotEmpty) {
            print('    Mensaje: ${test.message}');
          }
          if (test.location.isNotEmpty) {
            print('    ${grayColor}Ubicación: ${test.location}${resetColor}');
          }
        }
      }
    });
  }

  /// Formatea el texto de duración de una prueba
  String _getDurationText(Duration duration) {
    if (duration == Duration.zero) {
      return '';
    }

    return '${grayColor}(${_formatDuration(duration)})${resetColor}';
  }

  /// Formatea una fecha y hora
  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year} '
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}';
  }

  /// Obtiene el ancho de la terminal
  int _getTerminalWidth() {
    try {
      return stdout.terminalColumns;
    } catch (e) {
      return 80; // Valor predeterminado si no se puede determinar
    }
  }

  /// Verifica si hay dispositivos conectados
  Future<bool> _checkForConnectedDevices() async {
    _logDebug('[DEBUG] Verificando dispositivos conectados...');

    final result = await Process.run('flutter', ['devices']);
    final output = result.stdout.toString();

    // Buscar dispositivos en la salida
    final lines =
        output.split('\n').where((line) => line.trim().isNotEmpty).toList();

    // Necesitamos al menos 3 líneas (encabezado, separador, y al menos un dispositivo)
    final hasDevices = lines.length > 2;

    _logDebug('[DEBUG] Dispositivos conectados: ${hasDevices ? 'Sí' : 'No'}');

    return hasDevices;
  }

  /// Registra un mensaje de depuración
  void _logDebug(String message) {
    if (_currentLogLevel <= LOG_LEVEL_DEBUG) {
      print('[DEBUG] $message');
    }
  }

  /// Registra un mensaje de advertencia
  void _logWarning(String message) {
    if (_currentLogLevel <= LOG_LEVEL_WARNING) {
      print('${yellowColor}[WARN] $message${resetColor}');
    }
  }

  /// Imprime el encabezado principal
  void _printHeader() {
    print(
        '${boldText}${cyanColor}╔═════════════════════════════════════════════════╗${resetColor}');
    print(
        '${boldText}${cyanColor}║                                                 ║${resetColor}');
    print(
        '${boldText}${cyanColor}║     ${greenColor}TempoSage - Ejecutor de Pruebas${cyanColor}            ║${resetColor}');
    print(
        '${boldText}${cyanColor}║                                                 ║${resetColor}');
    print(
        '${boldText}${cyanColor}╚═════════════════════════════════════════════════╝${resetColor}');
    print('');
  }

  /// Imprime el menú principal
  void _printMainMenu() {
    print(
        '${boldText}${yellowColor}Seleccione una categoría de pruebas:${resetColor}');
    print('');

    categories.forEach((key, category) {
      print(
          '${boldText}$key.${resetColor} ${category.name} - ${category.description}');
    });

    print('');
    print('${boldText}Q.${resetColor} Salir');
    print('');
    print('${yellowColor}Ingrese su selección: ${resetColor}');
  }

  /// Imprime el encabezado de una categoría
  void _printCategoryHeader(TestCategory category) {
    print(
        '${boldText}${cyanColor}╔═════════════════════════════════════════════════╗${resetColor}');
    print(
        '${boldText}${cyanColor}║     ${greenColor}${category.name}${cyanColor}${" " * (38 - category.name.length)}║${resetColor}');
    print(
        '${boldText}${cyanColor}╚═════════════════════════════════════════════════╝${resetColor}');
    print('');
    print('${category.description}');
    print('');
  }

  /// Imprime las opciones de una categoría
  void _printCategoryOptions(TestCategory category) {
    print(
        '${boldText}${yellowColor}Seleccione una prueba para ejecutar:${resetColor}');
    print('');

    category.options.forEach((key, option) {
      final deviceWarning = option.requiresDevice
          ? ' ${redColor}(Requiere dispositivo)${resetColor}'
          : '';
      print('${boldText}$key.${resetColor} ${option.name}$deviceWarning');
    });

    print('');
    print('${boldText}B.${resetColor} Volver al menú principal');
    print('');
    print('${yellowColor}Ingrese su selección: ${resetColor}');
  }

  /// Imprime un mensaje de error
  void _printError(String message) {
    print('${redColor}$message${resetColor}');
  }

  /// Imprime un mensaje de éxito
  void _printSuccess(String message) {
    print('${greenColor}$message${resetColor}');
  }

  /// Imprime un mensaje informativo
  void _printInfo(String message) {
    print('${blueColor}$message${resetColor}');
  }

  /// Imprime las instrucciones de uso
  void _printUsage() {
    print('${boldText}${yellowColor}Uso:${resetColor}');
    print('  dart run scripts/test_runner.dart [categoría] [opción]');
    print('');
    print('${boldText}${yellowColor}Ejemplo:${resetColor}');
    print(
        '  dart run scripts/test_runner.dart 3 2  # Ejecuta pruebas de rendimiento de repositorio');
    print('');
    print('${boldText}${yellowColor}Argumentos:${resetColor}');
    print('  --help, -h    Muestra esta ayuda');
    print('');
    _printAvailableCategories();
  }

  /// Imprime las categorías disponibles
  void _printAvailableCategories() {
    print('${boldText}${yellowColor}Categorías disponibles:${resetColor}');
    categories.forEach((key, category) {
      print('  $key - ${category.name}');
    });
  }

  /// Imprime las opciones disponibles para una categoría
  void _printAvailableOptions(TestCategory category) {
    print(
        '${boldText}${yellowColor}Opciones disponibles para ${category.name}:${resetColor}');
    category.options.forEach((key, option) {
      print('  $key - ${option.name}');
    });
  }

  /// Limpia la pantalla
  void _clearScreen() {
    if (Platform.isWindows) {
      // En Windows, no podemos limpiar directamente, así que imprimimos líneas vacías
      print('\n' * 100);
    } else {
      // En Unix/Linux/MacOS
      stdout.write('\x1B[2J\x1B[0;0H');
    }
  }

  /// Espera a que el usuario presione una tecla
  Future<void> _waitForKeyPress() async {
    print('');
    print('${yellowColor}Presione Enter para continuar...${resetColor}');
    stdin.readLineSync();
  }

  /// Guarda los resultados detallados de las pruebas en un archivo
  Future<void> _saveTestResultsToFile(
      TestResult result, String testName) async {
    try {
      // Crear directorio de informes si no existe
      final reportsDir = Directory('test-reports');
      if (!await reportsDir.exists()) {
        await reportsDir.create();
      }

      // Crear nombre de archivo con fecha y hora
      final now = DateTime.now();
      final dateStr =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}-${now.minute.toString().padLeft(2, '0')}';
      final fileName =
          'test-reports/informe_${testName.replaceAll(' ', '_').toLowerCase()}_$dateStr.txt';

      // Crear contenido del archivo
      final buffer = StringBuffer();

      buffer.writeln('======================================================');
      buffer.writeln('  INFORME DE PRUEBAS: $testName');
      buffer.writeln('  Fecha: ${_formatDateTime(now)}');
      buffer.writeln('======================================================');
      buffer.writeln();

      buffer.writeln('RESUMEN:');
      buffer.writeln('  Total pruebas: ${result.totalTests}');
      buffer.writeln('  Pruebas exitosas: ${result.passedTests}');
      buffer.writeln('  Pruebas fallidas: ${result.failedTests}');
      buffer.writeln('  Pruebas omitidas: ${result.skippedTests}');
      buffer.writeln('  Duración: ${_formatDuration(result.duration)}');
      buffer.writeln();

      // Detalles de pruebas agrupados
      final groupedTests = <String, List<TestInfo>>{};

      for (final test in result.testDetails) {
        final group = test.group.isEmpty ? 'Sin grupo' : test.group;
        if (!groupedTests.containsKey(group)) {
          groupedTests[group] = [];
        }
        groupedTests[group]!.add(test);
      }

      buffer.writeln('DETALLES POR GRUPO:');
      groupedTests.forEach((group, tests) {
        buffer.writeln();
        buffer.writeln('GRUPO: $group');

        for (final test in tests) {
          String statusText;
          switch (test.status) {
            case TestStatus.passed:
              statusText = 'PASÓ';
              break;
            case TestStatus.failed:
              statusText = 'FALLÓ';
              break;
            case TestStatus.skipped:
              statusText = 'OMITIDO';
              break;
          }

          buffer.writeln('  - ${test.name} [$statusText]');

          if (test.duration != Duration.zero) {
            buffer.writeln('    Duración: ${_formatDuration(test.duration)}');
          }

          if (test.status == TestStatus.failed) {
            if (test.expected.isNotEmpty) {
              buffer.writeln('    Esperado: ${test.expected}');
            }
            if (test.actual.isNotEmpty) {
              buffer.writeln('    Obtenido: ${test.actual}');
            }
            if (test.message.isNotEmpty) {
              buffer.writeln('    Mensaje: ${test.message}');
            }
            if (test.location.isNotEmpty) {
              buffer.writeln('    Ubicación: ${test.location}');
            }
          }
        }
      });

      // Escribir el archivo
      final file = File(fileName);
      await file.writeAsString(buffer.toString());

      print(
          '\n${greenColor}Informe detallado guardado en: ${fileName}${resetColor}');
    } catch (e) {
      _logWarning('No se pudo guardar el informe detallado: $e');
    }
  }

  /// Imprime una barra de resultado (éxito/fracaso)
  void _printResultBar(bool success) {
    final terminalWidth = _getTerminalWidth();
    final bar = '═' * (terminalWidth - 5);

    if (success) {
      print('\n${greenColor}╠${bar}╣${resetColor}');
      print(
          '${greenColor}║ ${successSymbol} PRUEBAS COMPLETADAS CON ÉXITO${' ' * (terminalWidth - 34)} ║${resetColor}');
      print('${greenColor}╚${bar}╝${resetColor}');
    } else {
      print('\n${redColor}╠${bar}╣${resetColor}');
      print(
          '${redColor}║ ${failSymbol} PRUEBAS FALLIDAS${' ' * (terminalWidth - 22)} ║${resetColor}');
      print('${redColor}╚${bar}╝${resetColor}');
    }
    print('');
  }

  /// Formatea una duración para mostrarla al usuario
  String _formatDuration(Duration duration) {
    if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes.remainder(60)}m ${duration.inSeconds.remainder(60)}s';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes}m ${duration.inSeconds.remainder(60)}s';
    } else if (duration.inSeconds > 0) {
      return '${duration.inSeconds}s ${duration.inMilliseconds.remainder(1000)}ms';
    } else {
      return '${duration.inMilliseconds}ms';
    }
  }
}

/// Clase que representa una categoría de pruebas
class TestCategory {
  final String name;
  final String description;
  final Map<String, TestOption> options;

  const TestCategory({
    required this.name,
    required this.description,
    required this.options,
  });
}

/// Clase que representa una opción de prueba
class TestOption {
  final String name;
  final String command;
  final bool requiresDevice;

  const TestOption({
    required this.name,
    required this.command,
    this.requiresDevice = false,
  });
}

/// Clase para almacenar los resultados de las pruebas
class TestResult {
  int totalTests = 0;
  int passedTests = 0;
  int failedTests = 0;
  int skippedTests = 0;
  Duration duration = Duration.zero;
  DateTime startTime = DateTime.now();
  int exitCode = 0;
  List<String> failedTestNames = [];
  List<TestInfo> testDetails = [];
}

/// Estado de una prueba individual
enum TestStatus {
  passed,
  failed,
  skipped,
}

/// Clase para almacenar información sobre una prueba individual
class TestInfo {
  String name = '';
  String group = '';
  TestStatus status = TestStatus.passed;
  Duration duration = Duration.zero;
  String expected = '';
  String actual = '';
  String message = '';
  String location = '';
}
