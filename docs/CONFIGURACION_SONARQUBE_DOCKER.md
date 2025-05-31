# Configuración de SonarQube con Docker para proyectos Flutter

Este documento describe los pasos para configurar SonarQube con Docker e integrar el plugin de Flutter para el análisis de calidad de código.

## Prerrequisitos

- Docker y Docker Compose instalados
- Git
- Flutter SDK

## Pasos para configurar SonarQube con Docker

### 1. Crear archivo docker-compose.yml

Crea un archivo `docker-compose.yml` con el siguiente contenido:

```yaml
version: '3'
services:
  sonarqube:
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
docker-compose up -d
```

### 3. Instalar el plugin de Flutter para SonarQube

Descarga el plugin de Flutter para SonarQube:

```bash
curl -L https://github.com/insideapp-oss/sonar-flutter/releases/download/0.5.2/sonar-flutter-plugin-0.5.2.jar -o sonar-flutter-plugin.jar
```

Copia el plugin al directorio de plugins de SonarQube en Docker:

```bash
docker cp sonar-flutter-plugin.jar sonarqube:/opt/sonarqube/extensions/plugins/
```

Reinicia el contenedor de SonarQube:

```bash
docker restart sonarqube
```

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

Para verificar que el plugin está instalado correctamente:

1. Inicia sesión en SonarQube
2. Ve a "Administration" > "Marketplace" > "Installed"
3. Deberías ver "SonarQube plugin for Flutter / Dart" en la lista

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

### Plugin no detectado

Si el plugin no aparece en la lista de plugins instalados:
1. Verifica que el archivo JAR se copió correctamente
2. Asegúrate de que el contenedor de SonarQube se reinició completamente
3. Comprueba los permisos del archivo JAR dentro del contenedor

### Errores en el análisis

Si encuentras errores durante el análisis:
1. Verifica que el token tiene los permisos correctos
2. Asegúrate de que el archivo sonar-project.properties está configurado correctamente
3. Revisa los logs del análisis para identificar problemas específicos 