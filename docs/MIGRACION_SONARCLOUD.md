# Migración de SonarQube Local a SonarCloud

Esta guía te ayudará a migrar de SonarQube local a SonarCloud.

## 🎯 ¿Por qué migrar a SonarCloud?

- ✅ **Soporte oficial completo** para Dart/Flutter (sin limitaciones de edición)
- ✅ **Gratis para proyectos open source**
- ✅ **Sin mantenimiento de servidor** - todo en la nube
- ✅ **Análisis automático** en cada push y pull request
- ✅ **Siempre actualizado** - última versión automáticamente
- ✅ **Integración nativa** con GitHub/GitLab/Bitbucket

## 📋 Pasos de Migración

### 1. Configurar SonarCloud

Sigue la guía completa en [`CONFIGURACION_SONARCLOUD.md`](./CONFIGURACION_SONARCLOUD.md) para:
- Crear cuenta en SonarCloud
- Crear organización
- Crear proyecto
- Obtener token de análisis

### 2. Actualizar Configuración Local

#### Actualizar `sonar-project.properties`

El archivo ya está configurado para SonarCloud. Solo necesitas:

1. Reemplazar `your-org-key` con tu organización real:
   ```properties
   sonar.projectKey=tu-org-key:temposage-movil
   sonar.organization=tu-org-key
   ```

2. Configurar el token:
   ```bash
   export SONAR_TOKEN="tu_token_de_sonarcloud"
   ```

#### Verificar configuración

```bash
# Verificar que el archivo está configurado correctamente
grep "sonar.host.url" sonar-project.properties
# Debe mostrar: sonar.host.url=https://sonarcloud.io
```

### 3. Probar el Análisis Localmente

```bash
# 1. Generar cobertura
flutter test --coverage

# 2. Ejecutar análisis
./scripts/run_sonarqube.sh
```

El script detectará automáticamente que estás usando SonarCloud.

### 4. Configurar GitHub Actions (Opcional pero Recomendado)

#### Añadir el secreto SONAR_TOKEN

1. Ve a tu repositorio en GitHub
2. Settings > Secrets and variables > Actions
3. New repository secret
4. Name: `SONAR_TOKEN`
5. Value: Tu token de SonarCloud (obtenido en el paso 1)

#### El workflow ya está creado

El archivo `.github/workflows/sonarcloud.yml` ya está configurado y se ejecutará automáticamente en cada push y pull request.

### 5. Detener SonarQube Local (Opcional)

Si ya no necesitas SonarQube local:

```bash
# Detener contenedores
docker-compose -f docker-compose.sonarqube.yml down

# (Opcional) Eliminar volúmenes si quieres liberar espacio
docker-compose -f docker-compose.sonarqube.yml down -v
```

**Nota:** Puedes mantener ambos si quieres - no hay conflicto.

## 🔄 Comparación: Local vs SonarCloud

| Característica | SonarQube Local | SonarCloud |
|----------------|----------------|------------|
| **Soporte Dart/Flutter** | Requiere Developer Edition | ✅ Incluido (gratis para open source) |
| **Mantenimiento** | Tú lo mantienes | ✅ Automático |
| **Actualizaciones** | Manual | ✅ Automático |
| **Costo** | Gratis (Community) / Pago (Developer+) | ✅ Gratis (open source) |
| **Análisis en PRs** | Requiere configuración | ✅ Automático |
| **Recursos** | Requiere servidor | ✅ En la nube |

## ✅ Checklist de Migración

- [ ] Cuenta creada en SonarCloud
- [ ] Organización creada en SonarCloud
- [ ] Proyecto creado en SonarCloud
- [ ] Token de análisis obtenido
- [ ] `sonar-project.properties` actualizado con organización real
- [ ] `SONAR_TOKEN` configurado como variable de entorno
- [ ] Primer análisis ejecutado exitosamente
- [ ] GitHub Actions configurado (secreto `SONAR_TOKEN` añadido)
- [ ] Análisis automático funcionando en GitHub

## 🎉 ¡Migración Completada!

Una vez completados estos pasos:

1. **Análisis local**: Usa `./scripts/run_sonarqube.sh` cuando quieras
2. **Análisis automático**: Se ejecuta en cada push y pull request
3. **Dashboard**: Accede a [sonarcloud.io](https://sonarcloud.io) para ver resultados

## 📚 Recursos

- [Guía de configuración completa](./CONFIGURACION_SONARCLOUD.md)
- [Documentación oficial de SonarCloud](https://docs.sonarcloud.io/)
- [Soporte de Dart/Flutter en SonarCloud](https://docs.sonarcloud.io/languages/dart/)

## 🆘 Solución de Problemas

### El análisis falla con "Invalid project key"

- Verifica que `sonar.projectKey` tenga el formato: `organization_key:project_key`
- Asegúrate de que la organización y proyecto existan en SonarCloud

### El análisis falla con "Invalid authentication credentials"

- Verifica que `SONAR_TOKEN` esté configurado correctamente
- Asegúrate de que el token no haya expirado
- Verifica que el token tenga permisos de análisis

### GitHub Actions falla

- Verifica que el secreto `SONAR_TOKEN` esté configurado en GitHub
- Revisa los logs del workflow para más detalles
- Asegúrate de que el proyecto esté correctamente configurado en SonarCloud

