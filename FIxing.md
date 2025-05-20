<!-- instrucciones.md -->
# Guía de actuación de la IA para corrección de errores Dart/Flutter

## 1. Cargar y parsear diagnósticos
1. Leer el JSON de `errores.md`.  
2. Transformar en lista de objetos:
   ```yaml
   [
     {
       code: string,           # p.ej. "deprecated_member_use"
       message: string,
       file: string,
       location: { line, column },
       replacement?: string
     },
     …
   ]
2. Agrupar por tipo de error
Construir un mapa:

js
Copiar
Editar
Map<String, List<Diagnostic>> agrupados;
agrupados[diag.code].add(diag);
3. Mapeo “error → acción”
Código	Acción
deprecated_member_use	dart fix --apply
prefer_const_declarations	Insertar const antes de la declaración indicada
prefer_const_constructors	Anteponer const en la llamada al constructor
sort_child_properties_last	Reordenar parámetros nombrados: child: siempre al final
await_only_futures	Eliminar await en llamadas no–Future o envolver en Future.value(...)
Otros	Invocar codemod personalizado vía script (AST-based transform)

4. Ejecución de las correcciones
Correcciones genéricas

bash
Copiar
Editar
dart analyze --fatal-warnings
dart fix --apply
Codemods específicos

bash
Copiar
Editar
node runCodemod.js --errorCode=<código> --files=<archivos>
5. Generación de diff y reporte
Calcular diff Git y construir resumen:

yaml
Copiar
Editar
• deprecated_member_use: 12 reemplazos
• prefer_const_*: 8 inserciones de const
• sort_child_properties_last: 3 reordenaciones
• await_only_futures: 5 awaits eliminados
• customCodemods: 4 transformaciones
6. Validación final
bash
Copiar
Editar
flutter clean && flutter pub get && flutter build
flutter test --coverage
dart analyze
Si hay errores nuevos, relanzar sólo los pasos necesarios.

7. Integración CI / pre-commit
Analizar y aplicar fixes

Ejecutar codemods

Compilar y testear

Generar PR con diff y reporte

php-template
Copiar
Editar

```markdown
<!-- rules.md -->
# Normas para evitar errores en Dart/Flutter

## 1. Configuración de linters
Añade al `analysis_options.yaml`:
```yaml
linter:
  rules:
    - prefer_const_constructors
    - prefer_const_declarations
    - sort_child_properties_last
    - await_only_futures
    - deprecated_member_use