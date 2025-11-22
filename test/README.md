# Estructura de Pruebas - TempoSage

Este directorio contiene todas las pruebas del proyecto organizadas por tipo y categoría.

## 📁 Estructura de Directorios

```
test/
├── acceptance/          # Pruebas de aceptación (BDD, Gherkin)
├── integration/         # Pruebas de integración
│   ├── auth/           # Pruebas de autenticación
│   ├── services/       # Pruebas de servicios
│   └── performance/    # Pruebas de rendimiento
├── performance/        # Pruebas de rendimiento unitarias
├── system/            # Pruebas de sistema
│   ├── performance/   # Pruebas de rendimiento del sistema
│   ├── portability/   # Pruebas de portabilidad
│   ├── security/      # Pruebas de seguridad
│   └── usability/     # Pruebas de usabilidad
├── unit/              # Pruebas unitarias
│   ├── controllers/   # Controladores
│   ├── models/        # Modelos de datos
│   ├── repositories/  # Repositorios
│   ├── services/      # Servicios
│   ├── usecases/      # Casos de uso
│   └── utils/         # Utilidades
└── widget/            # Pruebas de widgets
```

## 🧪 Tipos de Pruebas

### Pruebas Unitarias (`test/unit/`)
Pruebas que verifican componentes individuales en aislamiento.

- **controllers/**: Controladores de estado (Riverpod, Cubit)
- **models/**: Modelos de datos y entidades
- **repositories/**: Repositorios de datos
- **services/**: Servicios de negocio
- **usecases/**: Casos de uso
- **utils/**: Utilidades y helpers

### Pruebas de Integración (`test/integration/`)
Pruebas que verifican la interacción entre múltiples componentes.

- **auth/**: Flujos de autenticación
- **services/**: Integración de servicios
- **performance/**: Pruebas de rendimiento de integración

### Pruebas de Aceptación (`test/acceptance/`)
Pruebas que verifican escenarios de usuario completos.

- Pruebas BDD con Gherkin
- Historias de usuario
- Flujos completos de la aplicación

### Pruebas de Sistema (`test/system/`)
Pruebas que verifican el sistema completo en diferentes aspectos.

- **performance/**: Rendimiento del sistema
- **portability/**: Portabilidad entre plataformas
- **security/**: Seguridad de datos
- **usability/**: Usabilidad de la interfaz

### Pruebas de Widgets (`test/widget/`)
Pruebas que verifican componentes de UI.

## 🚀 Ejecutar Pruebas

### Todas las pruebas
```bash
flutter test
```

### Solo pruebas unitarias
```bash
flutter test test/unit/
```

### Solo pruebas de integración
```bash
flutter test test/integration/
```

### Solo pruebas de aceptación
```bash
flutter test test/acceptance/
```

### Solo pruebas de sistema
```bash
flutter test test/system/
```

### Con cobertura
```bash
flutter test --coverage
```

## 📊 Cobertura Actual

- **Cobertura total**: ~21%
- **Objetivo**: 30% (Fase 1), 50% (Fase 2), 70%+ (Fase 3)

## 📝 Convenciones

1. **Nomenclatura**: Los archivos de prueba deben terminar en `_test.dart`
2. **Organización**: Cada archivo de prueba debe estar en el directorio correspondiente a su tipo
3. **Imports**: Usar imports relativos cuando sea posible
4. **Mocks**: Usar `mocktail` para crear mocks
5. **Setup/Teardown**: Usar `setUp()` y `tearDown()` para preparar y limpiar el entorno

## 🔧 Drivers de Pruebas

Los drivers para pruebas de integración están en `test_driver/`:
- `integration_test_driver.dart`: Driver principal para pruebas de integración

## 📚 Recursos

- [Documentación de pruebas de Flutter](https://docs.flutter.dev/testing)
- [Guía de pruebas unitarias](https://docs.flutter.dev/cookbook/testing/unit/introduction)
- [Guía de pruebas de widgets](https://docs.flutter.dev/cookbook/testing/widget/introduction)
- [Guía de pruebas de integración](https://docs.flutter.dev/testing/integration-tests)

