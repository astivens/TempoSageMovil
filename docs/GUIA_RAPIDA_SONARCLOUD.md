# Guía Rápida: Configuración de SonarCloud

Esta es una guía rápida para configurar SonarCloud en 5 minutos.

## 🚀 Configuración Automática (Recomendado)

Ejecuta el script de configuración:

```bash
./scripts/setup_sonarcloud.sh
```

El script te guiará paso a paso.

## 📝 Configuración Manual

### Paso 1: Crear cuenta y organización (2 min)

1. Ve a [https://sonarcloud.io](https://sonarcloud.io)
2. Inicia sesión con GitHub
3. Crea una organización:
   - Click en "Create Organization"
   - Elige un nombre (ej: `astivens` o `temposage`)
   - Selecciona plan "Free" (gratis para open source)

### Paso 2: Crear proyecto (1 min)

1. En SonarCloud, click en "Analyze a project"
2. Selecciona tu organización
3. Selecciona el repositorio: `astivens/TempoSageMovil`
4. SonarCloud detectará automáticamente que es Flutter/Dart

### Paso 3: Obtener token (1 min)

1. Ve a [https://sonarcloud.io/account/security](https://sonarcloud.io/account/security)
2. En "Generate Tokens", crea un nuevo token:
   - **Name**: `temposage-analysis-token`
   - **Type**: `Global Analysis Token`
   - **Expiration**: Sin expiración (para CI/CD)
3. **Copia el token** (no se mostrará nuevamente)

### Paso 4: Configurar proyecto local (1 min)

Edita `sonar-project.properties` y reemplaza `your-org-key`:

```properties
sonar.projectKey=tu-org-key:temposage-movil
sonar.organization=tu-org-key
```

**Ejemplo:** Si tu organización es `astivens`:
```properties
sonar.projectKey=astivens:temposage-movil
sonar.organization=astivens
```

### Paso 5: Configurar token localmente

```bash
export SONAR_TOKEN="tu_token_copiado"
```

Para que persista, añádelo a `~/.zshrc` o `~/.bashrc`:
```bash
echo 'export SONAR_TOKEN="tu_token_copiado"' >> ~/.zshrc
source ~/.zshrc
```

### Paso 6: Configurar GitHub Secrets (1 min)

1. Ve a: https://github.com/astivens/TempoSageMovil/settings/secrets/actions
2. Click en "New repository secret"
3. Name: `SONAR_TOKEN`
4. Value: El mismo token que copiaste antes
5. Click "Add secret"

## ✅ Verificar Configuración

### Probar análisis local

```bash
# 1. Generar cobertura
flutter test --coverage

# 2. Ejecutar análisis
./scripts/run_sonarqube.sh
```

### Verificar GitHub Actions

1. Haz un push a tu repositorio
2. Ve a la pestaña "Actions" en GitHub
3. Deberías ver el workflow "SonarCloud Analysis" ejecutándose

## 📊 Ver Resultados

Una vez completado el análisis:

- **Dashboard**: https://sonarcloud.io/project/overview?id=tu-org-key:temposage-movil
- **Issues**: Ver bugs, vulnerabilidades y code smells
- **Measures**: Métricas detalladas de calidad

## 🔧 Solución Rápida de Problemas

### "Invalid project key"
- Verifica que `sonar.projectKey` tenga formato: `org-key:project-key`
- Asegúrate de que el proyecto exista en SonarCloud

### "Invalid authentication credentials"
- Verifica que `SONAR_TOKEN` esté configurado
- Asegúrate de que el token no haya expirado

### GitHub Actions falla
- Verifica que el secreto `SONAR_TOKEN` esté configurado en GitHub
- Revisa los logs del workflow para más detalles

## 📚 Más Información

- [Guía completa](./CONFIGURACION_SONARCLOUD.md)
- [Migración desde SonarQube local](./MIGRACION_SONARCLOUD.md)
- [Documentación oficial de SonarCloud](https://docs.sonarcloud.io/)

## 🎉 ¡Listo!

Una vez completados estos pasos, tendrás:
- ✅ Análisis automático en cada push y pull request
- ✅ Dashboard en SonarCloud con métricas de calidad
- ✅ Soporte oficial completo para Dart/Flutter
- ✅ Todo gratis para proyectos open source

