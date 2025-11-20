# Configuración de SonarQube con Docker para proyectos Flutter

Este documento describe los pasos para configurar SonarQube con Docker para el análisis de calidad de código en proyectos Flutter.

> **⚠️ IMPORTANTE:** Desde 2024, SonarQube 10.7+ incluye **soporte oficial nativo** para Dart y Flutter. **Ya no es necesario instalar plugins externos.**

## Prerrequisitos

- Docker y Docker Compose instalados
- Git
- Flutter SDK
- SonarQube 10.7 o superior (incluye soporte nativo para Dart/Flutter)

## Pasos para configurar SonarQube con Docker

### 1. Usar el archivo docker-compose.sonarqube.yml

El proyecto incluye un archivo `docker-compose.sonarqube.yml` configurado para usar SonarQube:

> **⚠️ IMPORTANTE:** El soporte oficial para Dart/Flutter requiere **Developer Edition o superior**. 
> La Community Edition no incluye soporte oficial, pero puedes usar SonarCloud (gratis para open source) 
> o el plugin externo para desarrollo local.

```yaml
version: '3'
services:
  sonarqube:
    # Usar LTS - para soporte oficial completo se requiere Developer Edition
    image: sonarqube:lts
    ports:
      - "9000:9000"
    volumes:
      - sonarqube_data:/opt/sonarqube/data
      - sonarqube_extensions:/opt/sonarqube/extensions
      - sonarqube_logs:/opt/sonarqube/logs
    environment:
      - SONAR_JDBC_URL=jdbc:postgresql://db:5432/sonar
      - SONAR_JDBC_USERNAME=sonar
      - SONAR_JDBC_PASSWORD=sonar
      - SONAR_ES_BOOTSTRAP_CHECKS_DISABLE=true
    depends_on:
      - db
  
  db:
    image: postgres:13
    environment:
      - POSTGRES_USER=sonar
      - POSTGRES_PASSWORD=sonar
      - POSTGRES_DB=sonar
    volumes:
      - postgresql_data:/var/lib/postgresql/data

volumes:
  sonarqube_data:
  sonarqube_extensions:
  sonarqube_logs:
  postgresql_data:
```

### 2. Iniciar los contenedores

```bash
docker-compose -f docker-compose.sonarqube.yml up -d
```

### 3. Verificar que SonarQube está funcionando

Espera unos momentos y verifica que SonarQube esté operativo:

```bash
# Esperar hasta que SonarQube esté listo
timeout 300 bash -c 'until curl -f http://localhost:9000/api/system/status; do sleep 5; done'
```

> **Nota:** 
> - Si usas **Developer Edition o superior**, el soporte para Dart/Flutter está incluido nativamente
> - Si usas **Community Edition**, necesitarás el plugin externo o usar SonarCloud
> - **SonarCloud** (gratis para proyectos open source) incluye soporte oficial completo

### 4. Acceder a SonarQube y configurar un proyecto

1. Abre http://localhost:9000 en tu navegador
2. Inicia sesión con las credenciales por defecto (admin/admin)
3. Sigue las instrucciones para cambiar la contraseña en el primer inicio de sesión
4. Crea un nuevo proyecto:
   - Ve a "Projects" > "Create Project" > "Manually"
   - Ingresa el nombre del proyecto "TempoSage Movil" y la clave "temposage-movil"
   - Haz clic en "Set Up"

### 5. Generar un token de autenticación

1. Ve a "My Account" > "Security"
2. En la sección "Generate Tokens", crea un nuevo token:
   - Name: temposage-analysis-token
   - Type: Project Analysis Token
   - Expiration: selecciona un período adecuado (recomendado: 30 días)
3. Haz clic en "Generate"
4. Guarda el token generado en un lugar seguro

### 6. Configurar el token para el análisis

En tu entorno de desarrollo, configura el token como variable de entorno:

```bash
export SONAR_HOST_URL="http://localhost:9000"
export SONAR_TOKEN="tu_token_generado"
```

## Verificación de la instalación

Para verificar que SonarQube está funcionando correctamente:

1. Abre http://localhost:9000 en tu navegador
2. Inicia sesión con las credenciales por defecto (admin/admin)
3. El soporte para Dart/Flutter está incluido nativamente - no necesitas verificar plugins

## Ejecución del análisis

Con todo configurado, puedes ejecutar el análisis desde la raíz de tu proyecto:

```bash
# Ejecutar pruebas y generar reportes
flutter test --machine --coverage > tests.output

# Ejecutar análisis de SonarQube
./scripts/run_sonarqube.sh
```

## Solución de problemas comunes

### El contenedor de SonarQube no inicia

Verifica los logs del contenedor:

```bash
docker logs sonarqube
```

Asegúrate de que tienes suficiente memoria disponible para Docker. SonarQube requiere al menos 2GB de RAM.

### Verificar versión de SonarQube

Si tienes problemas con el análisis de Dart/Flutter:
1. Verifica que estás usando SonarQube 10.7 o superior
2. Puedes verificar la versión en "Administration" > "System" > "Information"
3. Si usas una versión anterior, actualiza a 10.7+ para obtener soporte oficial

### Errores en el análisis

Si encuentras errores durante el análisis:
1. Verifica que el token tiene los permisos correctos
2. Asegúrate de que el archivo sonar-project.properties está configurado correctamente
3. Revisa los logs del análisis para identificar problemas específicos 